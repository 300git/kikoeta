import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../src/rust/api/kikoeru_api.dart';
import 'app_paths.dart';

/// 封面字节的磁盘缓存，跨进程生效。
///
/// 机制对齐 `flutter_cache_manager`（cached_network_image 的底层）：
/// - URL 的稳定哈希作为文件名，命中直接读盘，不再走网络；
/// - 先写 `.tmp` 再改名，避免读到写了一半的文件；
/// - 同一 URL 的并发请求合并为一次；
/// - 按「最旧访问时间」做 LRU 清理（总大小上限 + 最大闲置时长）。
///
/// 封面必须经 Rust 网络层获取（规避 dart:io 的 TLS 问题），因此不能直接换成
/// cached_network_image，这里只搬它的机制。
class CoverCache {
  CoverCache({
    required this.root,
    required this.fetch,
    this.maxBytes = 200 * 1024 * 1024,
    this.maxIdle = const Duration(days: 30),
    this.pruneInterval = const Duration(days: 1),
  });

  /// 缓存目录名（位于应用数据目录下，见 [AppPaths]）
  static const dirName = 'cover_cache';

  /// 命中后超过该时长才刷新访问时间，避免每次读盘都写元数据
  static const _touchInterval = Duration(days: 1);

  static CoverCache? _instance;

  final Directory root;

  /// 网络取字节实现（默认经 Rust 网络层，测试可注入）
  final Future<Uint8List> Function(String url) fetch;

  /// 缓存总大小上限，超出后按最旧访问时间淘汰
  final int maxBytes;

  /// 超过该时长未访问的条目直接淘汰
  final Duration maxIdle;

  /// 两次清理之间的最小间隔（用标记文件记录，避免每次启动都遍历目录）
  final Duration pruneInterval;

  final Map<String, Future<Uint8List>> _inflight = {};
  final Map<String, Future<void>> _writes = {};

  /// 进程级单例：首次调用解析数据目录，并异步做一次过期清理。
  static Future<CoverCache> instance() async {
    final cached = _instance;
    if (cached != null) return cached;
    final dir = Directory(
      '${await AppPaths.dataDir()}${Platform.pathSeparator}$dirName',
    );
    final cache = CoverCache(root: dir, fetch: (url) => apiGetBytes(url: url));
    _instance = cache;
    unawaited(cache.pruneIfStale());
    return cache;
  }

  /// 图片加载路径的统一入口：缓存不可用（目录无法解析等）时退化为直接请求，
  /// 但**不吞掉网络错误**——网络失败直接向上抛，避免同一张图重复请求两次。
  static Future<Uint8List> fetchWithCache(String url) async {
    CoverCache cache;
    try {
      cache = await instance();
    } catch (_) {
      return apiGetBytes(url: url);
    }
    return cache.bytes(url);
  }

  /// 取封面字节：命中磁盘直接返回，否则请求网络并落盘。
  Future<Uint8List> bytes(String url) {
    final running = _inflight[url];
    if (running != null) return running;
    final task = _load(url);
    _inflight[url] = task;
    return task.whenComplete(() => _inflight.remove(url));
  }

  Future<Uint8List> _load(String url) async {
    final file = _fileFor(url);
    var hit = await _readIfPresent(file);
    if (hit == null) {
      // 上一次同 URL 的写入可能还在进行（落盘是异步的），等它完成后再读一次，
      // 否则短时间内重复进入同一页会重复请求网络。
      final writing = _writes[url];
      if (writing != null) {
        await writing;
        hit = await _readIfPresent(file);
      }
    }
    if (hit != null) {
      unawaited(_touch(file));
      return hit;
    }
    final fresh = await fetch(url);
    if (fresh.isNotEmpty) {
      final write = _store(file, fresh);
      _writes[url] = write;
      unawaited(
        write.whenComplete(() {
          if (identical(_writes[url], write)) _writes.remove(url);
        }),
      );
    }
    return fresh;
  }

  Future<Uint8List?> _readIfPresent(File file) async {
    try {
      final bytes = await file.readAsBytes();
      return bytes.isEmpty ? null : bytes;
    } catch (_) {
      return null; // 未命中或读盘失败：交由调用方走网络
    }
  }

  Future<void> _store(File file, Uint8List data) async {
    File? tmp;
    try {
      await root.create(recursive: true);
      tmp = File('${file.path}.tmp$pid');
      await tmp.writeAsBytes(data, flush: true);
      await tmp.rename(file.path);
    } catch (_) {
      // 缓存写入失败不影响本次显示
      try {
        await tmp?.delete();
      } catch (_) {}
    }
  }

  Future<void> _touch(File file) async {
    try {
      final st = await file.stat();
      if (DateTime.now().difference(st.modified) > _touchInterval) {
        await file.setLastModified(DateTime.now());
      }
    } catch (_) {}
  }

  /// 距上次清理超过 [pruneInterval] 才真正清理（标记文件记时间戳）。
  Future<void> pruneIfStale() async {
    try {
      final now = DateTime.now();
      final marker = File(
        '${root.path}${Platform.pathSeparator}.last_prune',
      );
      if (await marker.exists()) {
        final st = await marker.stat();
        if (now.difference(st.modified) < pruneInterval) return;
      }
      await root.create(recursive: true);
      await prune();
      await marker.writeAsString('${now.millisecondsSinceEpoch}', flush: true);
    } catch (_) {}
  }

  /// 等待在途写入落盘（退出前、清理前或测试中用来让磁盘状态确定）。
  Future<void> flush() async {
    while (_writes.isNotEmpty) {
      await Future.wait(_writes.values.toList());
    }
  }

  /// 按最旧访问时间淘汰：超过 [maxBytes] 或闲置超过 [maxIdle] 的条目被删除。
  Future<void> prune() async {
    try {
      if (!await root.exists()) return;
      await flush(); // 先等在途写入结束，避免把刚写入的条目当成空文件删掉
      final now = DateTime.now();
      final entries = <(File, DateTime, int)>[];
      var total = 0;
      await for (final e in root.list(followLinks: false)) {
        if (e is! File) continue;
        final name = e.uri.pathSegments.last;
        if (name.startsWith('.')) continue; // 清理标记文件
        try {
          final st = await e.stat();
          if (st.size == 0) {
            // 可能是其它实例正在写入的临时文件：只有确认过期才当垃圾删掉
            if (now.difference(st.modified) > const Duration(hours: 1)) {
              await e.delete();
            }
            continue;
          }
          entries.add((e, st.modified, st.size));
          total += st.size;
        } catch (_) {
          // 单个文件读不到/被占用不影响整体清理
        }
      }
      entries.sort((a, b) => a.$2.compareTo(b.$2)); // 最旧在前
      for (final (file, modified, size) in entries) {
        if (total <= maxBytes && now.difference(modified) <= maxIdle) break;
        total -= size;
        try {
          await file.delete();
        } catch (_) {}
      }
    } catch (_) {}
  }

  File _fileFor(String url) =>
      File('${root.path}${Platform.pathSeparator}${cacheFileName(url)}');

  /// 文件名：FNV-1a 64 位哈希（取低 63 位保证十六进制为正数）。
  /// 不能用 `String.hashCode`——它只保证同一次运行内稳定，重启后可能变化。
  static String cacheFileName(String url) {
    var hash = 0xcbf29ce484222325;
    for (final b in utf8.encode(url)) {
      hash = (hash ^ b) * 0x100000001b3;
    }
    return '${hash.toUnsigned(63).toRadixString(16).padLeft(16, '0')}.img';
  }
}
