import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kikoeta_app/subpage_swipe.dart';

void main() {
  const area = ValueKey('swipe-area');

  Future<void> show(
    WidgetTester tester, {
    int initial = 0,
    int count = 3,
    TextDirection direction = TextDirection.ltr,
    Widget? child,
    ValueChanged<int>? onChanged,
  }) async {
    var index = initial;
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: direction,
          child: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => SubpageSwipe(
                index: index,
                count: count,
                onChanged: (next) {
                  onChanged?.call(next);
                  setState(() => index = next);
                },
                child: SizedBox.expand(
                  key: area,
                  child: child ?? Center(child: Text('page $index')),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('swipes advance adjacent tabs and stop at both boundaries', (
    tester,
  ) async {
    final changes = <int>[];
    await show(tester, onChanged: changes.add);
    Future<void> drag(double dx) async {
      await tester.drag(find.byKey(area), Offset(dx, 0));
      await tester.pump();
    }

    await drag(200);
    expect(changes, isEmpty);
    await drag(-200);
    expect(find.text('page 1'), findsOneWidget);
    await drag(-200);
    expect(find.text('page 2'), findsOneWidget);
    await drag(-200);
    expect(changes, [1, 2]);
    await drag(200);
    await drag(200);
    expect(changes, [1, 2, 1, 0]);
  });

  testWidgets('slow swipes work but small adjustments and cancels do not', (
    tester,
  ) async {
    final changes = <int>[];
    await show(tester, onChanged: changes.add);
    final start = tester.getCenter(find.byKey(area));
    var gesture = await tester.startGesture(start);
    await gesture.moveBy(const Offset(-24, 0));
    await gesture.moveBy(const Offset(-10, 0));
    await tester.pump(const Duration(seconds: 1));
    await gesture.up();
    expect(changes, isEmpty);

    gesture = await tester.startGesture(start);
    await gesture.moveBy(const Offset(-24, 0));
    await gesture.moveBy(const Offset(-120, 0));
    await gesture.cancel();
    expect(changes, isEmpty);

    gesture = await tester.startGesture(start);
    await gesture.moveBy(const Offset(-24, 0));
    await gesture.moveBy(const Offset(-80, 0));
    await tester.pump(const Duration(seconds: 1));
    await gesture.up();
    await tester.pump();
    expect(changes, [1]);
  });

  testWidgets('vertical scrolling and pull to refresh keep their gestures', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    var refreshes = 0;
    final changes = <int>[];
    await show(
      tester,
      onChanged: changes.add,
      child: RefreshIndicator(
        onRefresh: () async => refreshes++,
        child: ListView.builder(
          controller: controller,
          physics: const AlwaysScrollableScrollPhysics(),
          itemExtent: 60,
          itemCount: 50,
          itemBuilder: (_, index) => Text('row $index'),
        ),
      ),
    );
    await tester.drag(find.byKey(area), const Offset(0, -250));
    await tester.pumpAndSettle();
    expect(controller.offset, greaterThan(0));
    controller.jumpTo(0);
    await tester.pump();
    await tester.drag(find.byKey(area), const Offset(0, 400));
    await tester.pumpAndSettle();
    expect(refreshes, 1);
    expect(changes, isEmpty);
    await tester.drag(find.byKey(area), const Offset(-200, 0));
    await tester.pumpAndSettle();
    expect(changes, [1]);
  });

  testWidgets('nested horizontal controls and taps remain interactive', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    var taps = 0;
    final changes = <int>[];
    await show(
      tester,
      onChanged: changes.add,
      child: Column(
        children: [
          TextButton(onPressed: () => taps++, child: const Text('tap')),
          SizedBox(
            height: 100,
            child: ListView(
              key: const ValueKey('horizontal-control'),
              controller: controller,
              scrollDirection: Axis.horizontal,
              children: const [SizedBox(width: 2000)],
            ),
          ),
        ],
      ),
    );
    await tester.tap(find.text('tap'));
    await tester.drag(
      find.byKey(const ValueKey('horizontal-control')),
      const Offset(-200, 0),
    );
    await tester.pumpAndSettle();
    expect(taps, 1);
    expect(controller.offset, greaterThan(0));
    expect(changes, isEmpty);
  });

  testWidgets('supports desktop mouse drags and RTL order', (tester) async {
    final changes = <int>[];
    await show(
      tester,
      count: 2,
      direction: TextDirection.rtl,
      onChanged: changes.add,
    );
    await tester.drag(
      find.byKey(area),
      const Offset(200, 0),
      kind: PointerDeviceKind.mouse,
    );
    await tester.pump();
    expect(changes, [1]);
    await tester.drag(find.byKey(area), const Offset(-200, 0));
    await tester.pump();
    expect(changes, [1, 0]);
  });
}
