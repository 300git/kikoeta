import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 文件夹选择结果。
///
/// [path] 为 null 表示用户取消。Android 上 [fileCount] 是镜像出来的歌词文件数，
/// 桌面端为 -1（数量交给导入流程自己扫描，避免多读一遍目录）。
class LyricsFolderSelection {
  const LyricsFolderSelection(this.path, {this.fileCount = -1});

  const LyricsFolderSelection.cancelled() : this(null);

  final String? path;
  final int fileCount;
}

/// 选择歌词文件夹，并解决 Android 分区存储读不到用户目录的问题。
///
/// file_picker 的 `getDirectoryPath` 只能把 SAF 的 tree URI 反解成
/// `/storage/emulated/0/...` 这样的路径。Android 10 起应用无法按路径读取用户
/// 目录里的非媒体文件（.lrc/.ass 等），本应用也没有申请存储权限，因此文件夹
/// 导入在 Android 上必然失败（桌面端不受影响）。
///
/// 这里在 Android 上改用 SAF 授权：原生侧直接读取用户选中的目录树，把歌词文件
/// 镜像到应用缓存目录，再交给与桌面端完全相同的导入流程。
class LyricsFolderImport {
  LyricsFolderImport._();

  static const channel = MethodChannel('kikoeta/storage');

  /// 与 `LyricsLibraryService.supportedExtensions` 一致。原生侧只镜像歌词/字幕
  /// 文件，避免把整个目录（含音频、封面）复制进缓存。
  static const lyricExtensions = ['lrc', 'txt', 'srt', 'vtt', 'ass', 'ssa'];

  /// widget 测试用它覆盖平台判断；运行时由 [Platform.isAndroid] 决定。
  @visibleForTesting
  static bool? debugForceAndroid;

  static bool get usesSaf => debugForceAndroid ?? Platform.isAndroid;

  /// 打开系统文件夹选择器。Android 上返回的是原生创建的缓存镜像目录。
  static Future<LyricsFolderSelection> pickDirectory({
    String? dialogTitle,
  }) async {
    if (!usesSaf) {
      final path = await FilePicker.getDirectoryPath(dialogTitle: dialogTitle);
      return LyricsFolderSelection(path);
    }
    final selection = await channel.invokeMapMethod<String, Object?>(
      'pickLyricsFolder',
      {'extensions': lyricExtensions},
    );
    if (selection == null) return const LyricsFolderSelection.cancelled();
    return LyricsFolderSelection(
      selection['path'] as String?,
      fileCount: (selection['fileCount'] as num?)?.toInt() ?? 0,
    );
  }

  /// 删除 [pickDirectory] 在 Android 上创建的缓存镜像。原生侧在下次选择文件夹时
  /// 也会清理，这里及时删除以免缓存堆积。
  static Future<void> releaseDirectory(String? path) async {
    if (path == null || !usesSaf) return;
    try {
      await channel.invokeMethod<void>('releaseLyricsFolder', {'path': path});
    } catch (_) {
      // 缓存清理失败不影响导入结果，系统也会自行回收缓存目录。
    }
  }
}
