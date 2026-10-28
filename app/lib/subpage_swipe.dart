import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

/// Adds adjacent-tab swipes to views backed by a single filtered data set.
/// Flutter's horizontal recognizer arbitrates with nested vertical scrolling.
class SubpageSwipe extends StatefulWidget {
  const SubpageSwipe({
    super.key,
    required this.index,
    required this.count,
    required this.onChanged,
    required this.child,
  }) : assert(count > 0),
       assert(index >= 0 && index < count);

  final int index;
  final int count;
  final ValueChanged<int> onChanged;
  final Widget child;

  @override
  State<SubpageSwipe> createState() => _SubpageSwipeState();
}

class _SubpageSwipeState extends State<SubpageSwipe> {
  double _distance = 0;
  int? _startIndex;

  void _reset() {
    _distance = 0;
    _startIndex = null;
  }

  void _onEnd(DragEndDetails details) {
    final distance = _distance;
    final startIndex = _startIndex;
    _reset();
    if (startIndex != widget.index) return;

    final velocity = details.primaryVelocity ?? 0;
    // Ignore small adjustments, but allow a deliberate short fling.
    final double direction;
    if (velocity.abs() >= kMinFlingVelocity && distance.abs() >= kTouchSlop) {
      direction = velocity;
    } else if (distance.abs() >= 48) {
      direction = distance;
    } else {
      return;
    }

    final forward = Directionality.of(context) == TextDirection.ltr ? -1 : 1;
    final next = widget.index + (direction.sign == forward ? 1 : -1);
    if (next >= 0 && next < widget.count) widget.onChanged(next);
  }

  @override
  void didUpdateWidget(covariant SubpageSwipe oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index || oldWidget.count != widget.count) {
      _reset();
    }
  }

  @override
  Widget build(BuildContext context) => Listener(
    // An accepted Flutter drag ends even for PointerCancelEvent.
    onPointerCancel: (_) => _reset(),
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: (_) {
        _distance = 0;
        _startIndex = widget.index;
      },
      onHorizontalDragUpdate: (details) =>
          _distance += details.primaryDelta ?? 0,
      onHorizontalDragEnd: _onEnd,
      onHorizontalDragCancel: _reset,
      child: widget.child,
    ),
  );
}
