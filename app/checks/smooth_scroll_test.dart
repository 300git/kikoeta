import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kikoeta_app/smooth_scroll.dart';

Widget _app(Widget scrollView) {
  return MaterialApp(
    home: Scaffold(body: scrollView),
  );
}

Widget _list() {
  return SmoothListView.builder(
    itemCount: 100,
    itemBuilder: (_, i) => SizedBox(height: 40, child: Text('item $i')),
  );
}

void main() {
  testWidgets('鼠标滚轮被接管为逐帧缓动，而不是一格瞬跳', (tester) async {
    await tester.pumpWidget(_app(_list()));
    final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
    expect(scrollable.position.pixels, 0);

    await tester.sendEventToBinding(
      PointerScrollEvent(
        position: tester.getCenter(find.byType(SmoothListView)),
        scrollDelta: const Offset(0, 120),
        kind: PointerDeviceKind.mouse,
        device: 1,
      ),
    );

    // 第一帧只推进一部分：说明内建 Scrollable 的 jumpTo 被接管了
    await tester.pump();
    final firstFrame = scrollable.position.pixels;
    expect(firstFrame, greaterThan(0));
    expect(firstFrame, lessThan(120));

    // 缓动收敛到滚轮目标
    await tester.pumpAndSettle();
    expect(scrollable.position.pixels, moreOrLessEquals(120, epsilon: 1));
  });

  testWidgets('只接管鼠标滚轮：触控板等仍走内建逻辑', (tester) async {
    await tester.pumpWidget(_app(_list()));
    final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));

    await tester.sendEventToBinding(
      PointerScrollEvent(
        position: tester.getCenter(find.byType(SmoothListView)),
        scrollDelta: const Offset(0, 120),
        kind: PointerDeviceKind.trackpad,
        device: 2,
      ),
    );

    // 内建逻辑同步落位，没有缓动
    expect(scrollable.position.pixels, moreOrLessEquals(120, epsilon: 0.5));
  });
}
