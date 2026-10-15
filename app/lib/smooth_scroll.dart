import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// 鼠标滚轮平滑滚动驱动。
///
/// Flutter 的滚轮是「一格一次瞬跳」：`Scrollable` 收到 `PointerScrollEvent` 后
/// 通过 `pointerSignalResolver` 注册回调，最终执行 `ScrollPosition.pointerScroll`
/// （内部直接 jumpTo）。Windows 上连续滚轮因此一截一截地跳、手感很硬。
///
/// 这里沿用 smooth_scroll / extended_smooth_scroll 这类成熟实现的机制：
/// 1. 把滚动视图**内容层**的 `Listener` 接到的滚轮事件抢先注册进
///    `pointerSignalResolver`（命中路径由内向外派发、先注册者生效），内建
///    `Scrollable` 位于更外层，于是放弃这次滚动，改由本驱动接管；
/// 2. 把滚轮增量累积成目标偏移，并夹在可滚动范围内；
/// 3. 用 ticker 每帧把当前位置按指数缓动逼近目标，滚轮停下时自然收尾。
///
/// 只接管鼠标滚轮；触控板等设备不注册，交回系统原有处理（它们本身就是连续
/// 增量，再缓动会发飘）。
class SmoothWheelDriver {
  SmoothWheelDriver({
    required this.vsync,
    required this.controller,
    this.factor = 0.3,
    this.restThreshold = 0.5,
  });

  final TickerProvider vsync;
  final ScrollController controller;

  /// 每帧向目标推进的比例（按 60fps 归一，实际按帧间隔换算）
  final double factor;

  /// 与目标距离小于该值即落位并停止
  final double restThreshold;

  Ticker? _ticker;
  double? _target;
  double _lastPushed = 0;
  Duration _lastTick = Duration.zero;

  /// 处理一个指针信号事件；返回 true 表示这次事件已被本驱动接管。
  bool handle(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return false;
    if (event.kind != PointerDeviceKind.mouse) return false;
    if (!controller.hasClients) return false;
    final position = controller.position;
    GestureBinding.instance.pointerSignalResolver.register(event, (event) {
      final scroll = event as PointerScrollEvent;
      // 与内建实现一致：告知引擎这次滚动已被处理（避免父级再滚一次）
      scroll.respond(allowPlatformDefault: false);
      // 目标累加不在这里夹取：懒加载列表的 maxScrollExtent 是估算值，
      // 会随内容布局而增长，夹取推迟到每帧（见 _onTick）。
      _target = (_target ?? position.pixels) + scroll.scrollDelta.dy;
      _lastPushed = position.pixels;
      _lastTick = Duration.zero;
      _ticker ??= vsync.createTicker(_onTick);
      if (!_ticker!.isActive) _ticker!.start();
    });
    return true;
  }

  void _onTick(Duration elapsed) {
    final rawTarget = _target;
    if (rawTarget == null || !controller.hasClients) {
      _stop();
      return;
    }
    final position = controller.position;
    // 位置被别处改动（用户拖拽、程序跳转、下拉刷新…）就放弃缓动，不跟用户抢
    if ((position.pixels - _lastPushed).abs() > 2) {
      _stop();
      return;
    }
    // 每帧按当前可滚动范围夹取，懒加载列表的范围是逐步变准的
    final target = rawTarget.clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    final dtMs = _lastTick == Duration.zero
        ? 16.7
        : (elapsed - _lastTick).inMicroseconds / 1000;
    _lastTick = elapsed;
    final remaining = target - position.pixels;
    if (remaining.abs() <= restThreshold) {
      _push(position, target);
      _stop();
      return;
    }
    // 按帧间隔换算推进比例，高刷屏与 60Hz 手感一致
    final steps = (dtMs / 16.7).clamp(0.1, 4.0);
    final k = 1 - math.pow(1 - factor, steps).toDouble();
    _push(position, position.pixels + remaining * k);
  }

  void _push(ScrollPosition position, double value) {
    _lastPushed = value;
    position.jumpTo(value);
  }

  void _stop() {
    _target = null;
    if (_ticker?.isActive ?? false) _ticker!.stop();
  }

  void dispose() {
    _ticker?.dispose();
    _ticker = null;
  }
}
