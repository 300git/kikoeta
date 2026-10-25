import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
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
/// 只接管鼠标滚轮和纵向滚动；触控板、横向滚动、Ctrl/Shift 等组合键都不注册，
/// 交回系统原有处理（它们本身就是连续增量，再缓动会发飘）。
class SmoothWheelDriver {
  SmoothWheelDriver({
    required this.vsync,
    this.factor = 0.3,
    this.restThreshold = 0.5,
  });

  final TickerProvider vsync;

  /// 每帧向目标推进的比例（按 60fps 归一，实际按帧间隔换算）
  final double factor;

  /// 与目标距离小于该值即落位并停止
  final double restThreshold;

  Ticker? _ticker;
  ScrollableState? _scrollable;
  double? _target;
  double _lastPushed = 0;
  Duration _lastTick = Duration.zero;

  /// 处理一个指针信号事件；返回 true 表示这次事件已被本驱动接管。
  bool handle(PointerSignalEvent event, ScrollableState scrollable) {
    if (event is! PointerScrollEvent) return false;
    if (event.kind != PointerDeviceKind.mouse) return false;
    final position = scrollable.position;
    if (!position.hasContentDimensions) return false;
    if (position.axis != Axis.vertical) return false;
    // 与内建逻辑一致：NeverScrollableScrollPhysics 等不接受用户滚动的视图不接管，
    // 让事件继续冒泡给外层滚动容器。
    if (!position.physics.shouldAcceptUserOffset(position)) return false;
    final delta = position.axisDirection == AxisDirection.up
        ? -event.scrollDelta.dy
        : event.scrollDelta.dy;
    if (delta == 0) return false;
    final current = position.pixels;
    // 已到边界就不注册，交回内建逻辑（它会继续向外层滚动视图转发）
    final target = (current + delta).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    if (target == current) return false;

    GestureBinding.instance.pointerSignalResolver.register(event, (event) {
      final scroll = event as PointerScrollEvent;
      // 与内建实现一致：告知引擎这次滚动已被处理（避免父级再滚一次）
      scroll.respond(allowPlatformDefault: false);
      _scrollable = scrollable;
      // 目标累加不在这里夹取：懒加载列表的 maxScrollExtent 是估算值，
      // 会随内容布局而增长，夹取推迟到每帧（见 _onTick）。
      _target = (_target ?? current) + delta;
      _lastPushed = current;
      _lastTick = Duration.zero;
      _ticker ??= vsync.createTicker(_onTick);
      if (!_ticker!.isActive) _ticker!.start();
    });
    return true;
  }

  void _onTick(Duration elapsed) {
    final rawTarget = _target;
    final scrollable = _scrollable;
    if (rawTarget == null || scrollable == null || !scrollable.mounted) {
      _stop();
      return;
    }
    final position = scrollable.position;
    if (!position.hasContentDimensions) {
      _stop();
      return;
    }
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

/// 让最近的 [Scrollable] 的鼠标滚轮变成逐帧缓动。
///
/// 必须放在滚动视图**内部**（命中路径比内建 `Scrollable` 更靠内，才能在
/// `pointerSignalResolver` 里抢先注册）。本项目里通常不用手写：[SmoothListView]、
/// [SmoothCustomScrollView]、[SmoothGridView]、[SmoothSingleChildScrollView]
/// 会自动插入。手写滚动视图时把它套在内容外面即可。
class SmoothWheelScope extends StatefulWidget {
  const SmoothWheelScope({super.key, required this.child});

  final Widget child;

  @override
  State<SmoothWheelScope> createState() => _SmoothWheelScopeState();
}

class _SmoothWheelScopeState extends State<SmoothWheelScope>
    with SingleTickerProviderStateMixin {
  late final SmoothWheelDriver _wheel = SmoothWheelDriver(vsync: this);
  ScrollableState? _scrollable;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollable = Scrollable.maybeOf(context);
  }

  void _onPointerSignal(PointerSignalEvent event) {
    final scrollable = _scrollable;
    if (scrollable == null) return;
    _wheel.handle(event, scrollable);
  }

  @override
  void dispose() {
    _wheel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerSignal: _onPointerSignal,
      child: widget.child,
    );
  }
}

/// 给 [ScrollView] 的视口套一层 [SmoothWheelScope]。
///
/// 视口是 `Scrollable` 内部的唯一子层，包在这里既比内建 `Scrollable` 靠内，
/// 又能一次性覆盖所有 sliver，不需要在每张卡片上挂 Listener。
mixin SmoothWheelScrollView on ScrollView {
  @override
  Widget buildViewport(
    BuildContext context,
    ViewportOffset offset,
    AxisDirection axisDirection,
    List<Widget> slivers,
  ) {
    return SmoothWheelScope(
      child: super.buildViewport(context, offset, axisDirection, slivers),
    );
  }
}

class SmoothListView extends ListView with SmoothWheelScrollView {
  SmoothListView({
    super.key,
    super.scrollDirection,
    super.reverse,
    super.controller,
    super.primary,
    super.physics,
    super.shrinkWrap,
    super.padding,
    super.itemExtent,
    super.prototypeItem,
    super.addAutomaticKeepAlives,
    super.addRepaintBoundaries,
    super.addSemanticIndexes,
    super.semanticChildCount,
    super.dragStartBehavior,
    super.keyboardDismissBehavior,
    super.restorationId,
    super.clipBehavior,
    super.children,
  });

  SmoothListView.builder({
    super.key,
    super.scrollDirection,
    super.reverse,
    super.controller,
    super.primary,
    super.physics,
    super.shrinkWrap,
    super.padding,
    super.itemExtent,
    super.prototypeItem,
    super.addAutomaticKeepAlives,
    super.addRepaintBoundaries,
    super.addSemanticIndexes,
    super.semanticChildCount,
    super.dragStartBehavior,
    super.keyboardDismissBehavior,
    super.restorationId,
    super.clipBehavior,
    required super.itemBuilder,
    super.itemCount,
  }) : super.builder();

  SmoothListView.separated({
    super.key,
    super.scrollDirection,
    super.reverse,
    super.controller,
    super.primary,
    super.physics,
    super.shrinkWrap,
    super.padding,
    super.addAutomaticKeepAlives,
    super.addRepaintBoundaries,
    super.addSemanticIndexes,
    super.dragStartBehavior,
    super.keyboardDismissBehavior,
    super.restorationId,
    super.clipBehavior,
    required super.itemBuilder,
    required super.itemCount,
    required super.separatorBuilder,
  }) : super.separated();
}

class SmoothCustomScrollView extends CustomScrollView with SmoothWheelScrollView {
  SmoothCustomScrollView({
    super.key,
    super.scrollDirection,
    super.reverse,
    super.controller,
    super.primary,
    super.physics,
    super.shrinkWrap,
    super.center,
    super.anchor,
    super.semanticChildCount,
    super.dragStartBehavior,
    super.keyboardDismissBehavior,
    super.restorationId,
    super.clipBehavior,
    super.slivers,
  });
}

class SmoothGridView extends GridView with SmoothWheelScrollView {
  SmoothGridView.builder({
    super.key,
    super.scrollDirection,
    super.reverse,
    super.controller,
    super.primary,
    super.physics,
    super.shrinkWrap,
    super.padding,
    required super.gridDelegate,
    required super.itemBuilder,
    super.itemCount,
    super.addAutomaticKeepAlives,
    super.addRepaintBoundaries,
    super.addSemanticIndexes,
    super.semanticChildCount,
    super.dragStartBehavior,
    super.keyboardDismissBehavior,
    super.restorationId,
    super.clipBehavior,
  }) : super.builder();
}

/// [SingleChildScrollView] 版本：它的内容只有一个 child，把 child 包进
/// [SmoothWheelScope] 即可（padding 一并搬进去，滚轮落在留白上也生效）。
class SmoothSingleChildScrollView extends SingleChildScrollView {
  SmoothSingleChildScrollView({
    super.key,
    super.scrollDirection,
    super.reverse,
    EdgeInsetsGeometry? padding,
    super.primary,
    super.physics,
    super.controller,
    Widget? child,
    super.dragStartBehavior,
    super.clipBehavior,
    super.hitTestBehavior,
    super.restorationId,
    super.keyboardDismissBehavior,
  }) : super(padding: null, child: _wrap(padding, child));

  static Widget? _wrap(EdgeInsetsGeometry? padding, Widget? child) {
    if (child == null) return null;
    final content = padding == null
        ? child
        : Padding(padding: padding, child: child);
    return SmoothWheelScope(child: content);
  }
}
