import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kikoeta_app/data.dart';
import 'package:kikoeta_app/l10n/generated/app_localizations.dart';
import 'package:kikoeta_app/widgets.dart';

const _work = Work(
  rj: 'RJ100001',
  title: 'Queue boundary test',
  circle: '',
  va: '',
  age: Age.all,
  dur: '',
  tags: [],
  grad: 0,
);

List<MediaNode> _queue(int count) => List.generate(
  count,
  (index) => MediaNode(title: '${index + 1}', type: 'file', path: '$index.mp3'),
);

void main() {
  test('manual queue boundaries apply to every playback mode', () {
    final app = AppState();
    addTearDown(app.dispose);
    for (final mode in [0, 1, 2]) {
      app.playMode = mode;
      app.queue = _queue(5);
      app.trackIdx = 0;
      expect(app.hasPreviousTrack, isFalse);
      expect(app.hasNextTrack, isTrue);
      app.trackIdx = 2;
      expect(app.hasPreviousTrack, isTrue);
      expect(app.hasNextTrack, isTrue);
      app.trackIdx = 4;
      expect(app.hasPreviousTrack, isTrue);
      expect(app.hasNextTrack, isFalse);

      app.queue = _queue(1);
      app.trackIdx = 0;
      expect(app.hasPreviousTrack, isFalse);
      expect(app.hasNextTrack, isFalse);
      app.queue = [];
      expect(app.hasPreviousTrack, isFalse);
      expect(app.hasNextTrack, isFalse);
    }
  });

  for (final count in [1, 5]) {
    testWidgets('mini player stops at the end of a $count-track queue', (
      tester,
    ) async {
      final app = AppState()
        ..currentWork = _work
        ..queue = _queue(count)
        ..trackIdx = count - 1
        ..resumePosition = 42;
      addTearDown(app.dispose);
      var notifications = 0;
      app.addListener(() => notifications++);
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('zh', 'CN'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Center(child: MiniPlayer(app: app)),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final next = find.byIcon(Icons.skip_next);
      for (final playing in [false, true]) {
        app.playing = playing;
        await tester.tap(next);
        await tester.pump();
        expect(app.trackIdx, count - 1);
        expect(app.playing, playing);
        expect(app.resumePosition, 42);
        expect(notifications, 0);
        expect(find.text('已经是最后一首'), findsOneWidget);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      if (count > 1) {
        app.trackIdx = 0;
        await tester.tap(next);
        await tester.pump();
        expect(app.trackIdx, 1);
        expect(notifications, 1);
      }
      expect(tester.takeException(), isNull);
    });
  }
}
