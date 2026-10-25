import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kikoeta_app/navigation_page_stack.dart';

void main() {
  testWidgets(
    'retains page state through rapid navigation without frame rebuilds',
    (tester) async {
      var builds = 0;
      final pages = List.generate(
        3,
        (index) => Builder(
          builder: (_) {
            builds++;
            return TextField(key: ValueKey(index));
          },
        ),
      );
      Future<void> show(int index, {bool reduceMotion = false}) =>
          tester.pumpWidget(
            MaterialApp(
              home: MediaQuery(
                data: MediaQueryData(disableAnimations: reduceMotion),
                child: Scaffold(
                  body: NavigationPageStack(index: index, children: pages),
                ),
              ),
            ),
          );

      await show(0);
      await tester.enterText(find.byKey(const ValueKey(0)), 'retained');
      final originalState = tester.state(find.byKey(const ValueKey(0)));
      await show(1);
      await tester.pump(const Duration(milliseconds: 60));
      await show(2);
      await tester.pump(const Duration(milliseconds: 40));
      await show(0);
      final buildsBeforeFrames = builds;
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 150));
      expect(builds, buildsBeforeFrames);
      expect(tester.state(find.byKey(const ValueKey(0))), same(originalState));
      expect(find.text('retained'), findsOneWidget);
      expect(find.byKey(const ValueKey(1)), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'skips initial animation and respects reduced motion mid-transition',
    (tester) async {
      Future<void> show(int index, {bool reduceMotion = false}) =>
          tester.pumpWidget(
            MaterialApp(
              home: MediaQuery(
                data: MediaQueryData(disableAnimations: reduceMotion),
                child: NavigationPageStack(
                  index: index,
                  children: const [Text('home'), Text('favorites')],
                ),
              ),
            ),
          );
      double opacity() => tester
          .widget<FadeTransition>(
            find.descendant(
              of: find.byType(NavigationPageStack),
              matching: find.byType(FadeTransition),
            ),
          )
          .opacity
          .value;

      await show(0);
      expect(opacity(), 1);
      await show(1);
      await tester.pump(const Duration(milliseconds: 70));
      expect(opacity(), inExclusiveRange(0, 1));
      await show(1, reduceMotion: true);
      expect(opacity(), 1);
      await show(0, reduceMotion: true);
      expect(opacity(), 1);
      expect(tester.takeException(), isNull);
    },
  );
}
