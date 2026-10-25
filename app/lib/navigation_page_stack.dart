import 'package:flutter/material.dart';

/// Keeps navigation pages mounted while animating only the selected page in.
class NavigationPageStack extends StatefulWidget {
  const NavigationPageStack({
    super.key,
    required this.index,
    required this.children,
  });

  final int index;
  final List<Widget> children;

  @override
  State<NavigationPageStack> createState() => _NavigationPageStackState();
}

class _NavigationPageStackState extends State<NavigationPageStack>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
    value: 1,
  );
  late final _progress = _controller.drive(
    CurveTween(curve: Curves.easeOutCubic),
  );
  late final _scale = _progress.drive(Tween<double>(begin: .985, end: 1));
  bool _disableAnimations = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _disableAnimations = MediaQuery.disableAnimationsOf(context);
    if (_disableAnimations) _controller.value = 1;
  }

  @override
  void didUpdateWidget(covariant NavigationPageStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      if (_disableAnimations) {
        _controller.value = 1;
      } else {
        _controller.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Pass the stable page subtree through Flutter's render-level transitions;
    // animation ticks do not rebuild page contents or recreate their state.
    return FadeTransition(
      opacity: _progress,
      child: ScaleTransition(
        scale: _scale,
        child: IndexedStack(index: widget.index, children: widget.children),
      ),
    );
  }
}
