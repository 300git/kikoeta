import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kikoeta_app/data.dart';
import 'package:kikoeta_app/l10n/generated/app_localizations.dart';
import 'package:kikoeta_app/pages/dictation_translation_page.dart';
import 'package:kikoeta_app/services/dictation_queue.dart';
import 'package:kikoeta_app/src/rust/frb_generated.dart';
import 'package:kikoeta_app/widgets/dictation_queue_list.dart';

Work work(String id) => Work(
  rj: id,
  title: 'Title $id',
  circle: '',
  va: '',
  age: Age.all,
  dur: '',
  tags: const [],
  grad: 0,
);

DictationQueueEntry enqueue(DictationQueue queue, String id) => queue.enqueue(
  work: work(id),
  tracks: [
    MediaNode(
      title: '$id.mp3',
      type: 'file',
      path: '$id.mp3',
      url: 'https://example.com/$id.mp3',
    ),
  ],
);

void main() {
  setUpAll(() => RustLib.initMock(api: _SettingsApi()));
  test(
    'newest imports display first, repeated works have stable batch labels',
    () {
      final queue = DictationQueue();
      addTearDown(queue.dispose);
      final first = enqueue(queue, 'RJ111111');
      final second = enqueue(queue, 'RJ111111');
      enqueue(queue, 'RJ123456');
      enqueue(queue, 'RJ123123');
      expect(queue.entries.map((e) => e.label), [
        'RJ123123',
        'RJ123456',
        'RJ111111-1',
        'RJ111111',
      ]);
      queue.remove(second);
      queue.remove(first);
      expect(enqueue(queue, 'RJ111111').label, 'RJ111111-2');
    },
  );

  test('batches capture tracks and source credentials at import', () {
    final queue = DictationQueue();
    addTearDown(queue.dispose);
    final tracks = [const MediaNode(title: 'one', type: 'file', path: 'one')];
    final headers = {'Authorization': 'Bearer first'};
    final entry = queue.enqueue(
      work: work('RJ1'),
      tracks: tracks,
      sourceHeaders: headers,
    );
    tracks.clear();
    headers['Authorization'] = 'Bearer second';
    expect(entry.tracks.single.path, 'one');
    expect(entry.sourceHeaders['Authorization'], 'Bearer first');
  });

  test(
    'serial runner picks oldest pending, observes live imports and reorders',
    () async {
      final queue = DictationQueue();
      addTearDown(queue.dispose);
      final a = enqueue(queue, 'A');
      final b = enqueue(queue, 'B');
      final c = enqueue(queue, 'C');
      final release = Completer<DictationQueueStatus>();
      final processed = <String>[];
      final run = queue.run((entry) async {
        processed.add(entry.label);
        if (entry == a) return release.future;
        return DictationQueueStatus.completed;
      });
      expect(processed, ['A']);
      expect(queue.remove(a), isFalse);
      final d = enqueue(queue, 'D');
      queue.reorder(d, b); // D now runs after A, before B and C.
      queue.reorder(a, c); // Running entries cannot move.
      queue.reorder(c, a); // Pending entries cannot cross a started entry.
      await queue.run((_) async => throw StateError('duplicate runner'));
      expect(processed, ['A']);
      release.complete(DictationQueueStatus.completed);
      await run;
      expect(processed, ['A', 'D', 'B', 'C']);
      expect(
        queue.entries.every((e) => e.status == DictationQueueStatus.completed),
        isTrue,
      );
      expect(queue.running, isFalse);
    },
  );

  test(
    'reorder in both directions changes execution, stale drag targets are ignored',
    () async {
      final queue = DictationQueue();
      addTearDown(queue.dispose);
      final a = enqueue(queue, 'A');
      final b = enqueue(queue, 'B');
      final c = enqueue(queue, 'C');
      queue.reorder(a, c);
      expect(queue.entries.map((e) => e.label), ['A', 'C', 'B']);
      queue.reorder(a, b);
      expect(queue.entries.map((e) => e.label), ['C', 'B', 'A']);
      queue.remove(b);
      queue.reorder(c, b);
      expect(queue.entries.map((e) => e.label), ['C', 'A']);
      final processed = <String>[];
      await queue.run((e) async {
        processed.add(e.label);
        return DictationQueueStatus.completed;
      });
      expect(processed, ['A', 'C']);
    },
  );

  test(
    'jump pauses the active batch and resumes it after the selected batch',
    () async {
      final queue = DictationQueue();
      addTearDown(queue.dispose);
      final a = enqueue(queue, 'A');
      final b = enqueue(queue, 'B');
      enqueue(queue, 'C');
      final paused = Completer<DictationQueueStatus>();
      final processed = <String>[];
      final run = queue.run((entry) async {
        processed.add(entry.label);
        if (entry == a && processed.length == 1) return paused.future;
        expect(queue.preemptRequested, isFalse);
        return DictationQueueStatus.completed;
      });
      expect(queue.jumpAhead(a), isFalse);
      expect(queue.jumpAhead(b), isTrue);
      expect(queue.preemptRequested, isTrue);
      expect(a.status, DictationQueueStatus.running);
      expect(processed, ['A']);
      paused.complete(DictationQueueStatus.pending);
      await run;
      expect(processed, ['A', 'B', 'A', 'C']);
      expect(a.status, DictationQueueStatus.completed);
      expect(queue.preemptRequested, isFalse);
    },
  );

  test(
    'repeated jumps select the latest target and cancellation blocks jumps',
    () async {
      final queue = DictationQueue();
      addTearDown(queue.dispose);
      final a = enqueue(queue, 'A');
      final b = enqueue(queue, 'B');
      final c = enqueue(queue, 'C');
      final paused = Completer<DictationQueueStatus>();
      final processed = <String>[];
      final run = queue.run((entry) async {
        processed.add(entry.label);
        if (entry == a && processed.length == 1) return paused.future;
        return DictationQueueStatus.completed;
      });
      queue.jumpAhead(b);
      queue.jumpAhead(c);
      expect(queue.entries.last, same(c));
      queue.cancelling = true;
      expect(queue.jumpAhead(b), isFalse);
      queue.cancelling = false;
      paused.complete(DictationQueueStatus.pending);
      await run;
      expect(processed, ['A', 'C', 'B', 'A']);
    },
  );

  test(
    'cancel pauses remaining entries; resume skips finished and cancelled batches',
    () async {
      final queue = DictationQueue();
      addTearDown(queue.dispose);
      final a = enqueue(queue, 'A');
      final b = enqueue(queue, 'B');
      await queue.run((_) async => DictationQueueStatus.cancelled);
      expect(a.status, DictationQueueStatus.cancelled);
      expect(b.status, DictationQueueStatus.pending);
      final processed = <String>[];
      await queue.run((e) async {
        processed.add(e.label);
        return DictationQueueStatus.completed;
      });
      expect(processed, ['B']);
    },
  );

  test(
    'delete running entry waits for processor to stop, retains pending batches',
    () async {
      final queue = DictationQueue();
      addTearDown(queue.dispose);
      final a = enqueue(queue, 'A');
      final b = enqueue(queue, 'B');
      final release = Completer<DictationQueueStatus>();
      final run = queue.run((_) => release.future);
      queue.update(() {
        queue.stopRequested = true;
        queue.deleteOnFinish = true;
      });
      expect(queue.entries, contains(a));
      release.complete(DictationQueueStatus.cancelled);
      await run;
      expect(queue.entries, [b]);
      expect(queue.current, isNull);
      expect(b.status, DictationQueueStatus.pending);
    },
  );

  test(
    'failed batches advance, unexpected processor errors stop and unlock queue',
    () async {
      final queue = DictationQueue();
      addTearDown(queue.dispose);
      final a = enqueue(queue, 'A');
      final b = enqueue(queue, 'B');
      await queue.run(
        (entry) async => entry == a
            ? DictationQueueStatus.failed
            : DictationQueueStatus.completed,
      );
      expect(a.status, DictationQueueStatus.failed);
      expect(b.status, DictationQueueStatus.completed);
      final c = enqueue(queue, 'C');
      final d = enqueue(queue, 'D');
      await expectLater(
        queue.run((_) async => throw StateError('lost connection')),
        throwsStateError,
      );
      expect(queue.running, isFalse);
      expect(c.status, DictationQueueStatus.failed);
      expect(d.status, DictationQueueStatus.pending);
    },
  );

  test(
    'clear removes idle batches without deleting logs or reusing batch labels',
    () async {
      final queue = DictationQueue();
      addTearDown(queue.dispose);
      enqueue(queue, 'A');
      await queue.run((_) async => DictationQueueStatus.completed);
      enqueue(queue, 'B');
      queue.appendLog('saved result');
      var changes = 0;
      queue.addListener(() => changes++);
      queue.clear();
      expect(queue.entries, isEmpty);
      expect(queue.current, isNull);
      expect(queue.logs, ['saved result']);
      expect(changes, 1);
      expect(enqueue(queue, 'A').label, 'A-1');
    },
  );

  test(
    'clear retains running entry until cancelled and preserves later imports',
    () async {
      final queue = DictationQueue();
      addTearDown(queue.dispose);
      final a = enqueue(queue, 'A');
      enqueue(queue, 'B');
      final release = Completer<DictationQueueStatus>();
      final run = queue.run((_) => release.future);
      queue.clear();
      expect(queue.entries, [a]);
      queue.update(() {
        queue.stopRequested = true;
        queue.deleteOnFinish = true;
      });
      final c = enqueue(queue, 'C');
      release.complete(DictationQueueStatus.cancelled);
      await run;
      expect(queue.entries, [c]);
      expect(queue.current, isNull);
      expect(c.status, DictationQueueStatus.pending);
    },
  );

  Future<void> showQueue(
    WidgetTester tester,
    DictationQueue queue, {
    ValueChanged<DictationQueueEntry>? onDelete,
    ValueChanged<DictationQueueEntry>? onJump,
  }) => tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SizedBox(
          width: 520,
          child: ListenableBuilder(
            listenable: queue,
            builder: (_, _) => DictationQueueList(
              queue: queue,
              onDelete: onDelete ?? queue.remove,
              onJump: onJump,
            ),
          ),
        ),
      ),
    ),
  );

  testWidgets('pending batch action invokes jump without deleting the batch', (
    tester,
  ) async {
    final queue = DictationQueue();
    addTearDown(queue.dispose);
    final entry = enqueue(queue, 'RJ111111');
    DictationQueueEntry? requested;
    await showQueue(tester, queue, onJump: (entry) => requested = entry);
    await tester.longPress(find.text(entry.label));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, '插队'));
    await tester.pumpAndSettle();
    expect(requested, same(entry));
    expect(queue.entries, [entry]);
  });

  testWidgets(
    'one batch expands tracks immediately; long press shows disabled left action and delete',
    (tester) async {
      final queue = DictationQueue();
      addTearDown(queue.dispose);
      final entry = enqueue(queue, 'RJ111111');
      await showQueue(tester, queue);
      await tester.pumpAndSettle();
      expect(find.text('RJ111111.mp3'), findsOneWidget);
      expect(find.textContaining('已自动匹配'), findsNothing);
      await tester.longPress(find.text(entry.label));
      await tester.pumpAndSettle();
      expect(find.text('你想对 RJ111111 执行的操作'), findsOneWidget);
      final jump = tester.widget<TextButton>(
        find.widgetWithText(TextButton, '插队'),
      );
      expect(jump.onPressed, isNull);
      expect(
        tester.getCenter(find.text('插队')).dx,
        lessThan(tester.getCenter(find.text('删除')).dx),
      );
      await tester.tap(find.text('删除'));
      await tester.pumpAndSettle();
      expect(queue.entries, isEmpty);
    },
  );

  testWidgets(
    'multiple batches collapse, expand on tap, and drag using their handle',
    (tester) async {
      final queue = DictationQueue();
      addTearDown(queue.dispose);
      enqueue(queue, 'A');
      enqueue(queue, 'B');
      enqueue(queue, 'C');
      await showQueue(tester, queue);
      await tester.pumpAndSettle();
      expect(find.text('A.mp3'), findsNothing);
      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();
      expect(find.text('A.mp3'), findsOneWidget);
      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();
      final from = tester.getCenter(
        find.byType(ReorderableDragStartListener).first,
      );
      final to = tester.getCenter(
        find.byType(ReorderableDragStartListener).last,
      );
      final gesture = await tester.startGesture(from);
      for (var step = 1; step <= 10; step++) {
        await gesture.moveTo(
          Offset.lerp(from, to + const Offset(0, 30), step / 10)!,
        );
        await tester.pump(const Duration(milliseconds: 50));
      }
      await gesture.up();
      await tester.pumpAndSettle();
      expect(queue.entries.map((e) => e.label), ['B', 'A', 'C']);
      expect(find.byType(AlertDialog), findsNothing);
    },
  );

  testWidgets(
    'imports and processing transitions cancel an active drag safely',
    (tester) async {
      final queue = DictationQueue();
      addTearDown(queue.dispose);
      final a = enqueue(queue, 'A');
      enqueue(queue, 'B');
      await showQueue(tester, queue);
      await tester.pumpAndSettle();
      var gesture = await tester.startGesture(
        tester.getCenter(find.byType(ReorderableDragStartListener).first),
      );
      await gesture.moveBy(const Offset(0, 20));
      await tester.pump();
      enqueue(queue, 'C');
      await tester.pumpAndSettle();
      await gesture.up();
      await tester.pumpAndSettle();
      expect(queue.entries.map((e) => e.label), ['C', 'B', 'A']);
      gesture = await tester.startGesture(
        tester.getCenter(find.byType(ReorderableDragStartListener).last),
      );
      await gesture.moveBy(const Offset(0, -20));
      await tester.pump();
      final release = Completer<DictationQueueStatus>();
      final run = queue.run((_) => release.future);
      await tester.pumpAndSettle();
      await gesture.up();
      await tester.pumpAndSettle();
      expect(queue.current, same(a));
      expect(find.byType(ReorderableDragStartListener), findsNWidgets(2));
      expect(tester.takeException(), isNull);
      release.complete(DictationQueueStatus.cancelled);
      await run;
    },
  );

  testWidgets(
    'page reentry retains imports and new selections become distinct batches',
    (tester) async {
      final app = AppState();
      addTearDown(app.dispose);
      final navigator = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigator,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(),
        ),
      );
      Future<void> open(String? id) async {
        unawaited(
          navigator.currentState!.push(
            MaterialPageRoute<void>(
              builder: (_) => DictationTranslationPage(
                app: app,
                work: id == null ? null : work(id),
                tracks: id == null
                    ? const []
                    : [
                        MediaNode(
                          title: '$id.mp3',
                          type: 'file',
                          path: '$id.mp3',
                          url: 'https://example.com/$id.mp3',
                        ),
                      ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      Future<void> back() async {
        navigator.currentState!.pop();
        await tester.pumpAndSettle();
      }

      await open('RJ111111');
      expect(find.text('RJ111111.mp3'), findsOneWidget);
      await back();
      await open('RJ123456');
      expect(find.text('RJ111111'), findsOneWidget);
      expect(find.text('RJ123456'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('RJ123456')).dy,
        lessThan(tester.getTopLeft(find.text('RJ111111')).dy),
      );
      await back();
      await open(null);
      expect(find.byType(ExpansionTile), findsNWidgets(2));
      await back();
      await open('RJ111111');
      expect(find.text('RJ111111-1'), findsOneWidget);
      expect(find.text('RJ111111'), findsOneWidget);
      expect(find.byType(ExpansionTile), findsNWidgets(3));
      expect(find.textContaining('新导入在上方'), findsNothing);
      await tester.ensureVisible(find.widgetWithText(TextButton, '清空列表'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, '清空列表'));
      await tester.pumpAndSettle();
      expect(find.text('暂无任务'), findsOneWidget);
      expect(find.byType(ExpansionTile), findsNothing);
      expect(
        tester
            .widget<TextButton>(find.widgetWithText(TextButton, '清空列表'))
            .onPressed,
        isNull,
      );
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.text('日志'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'running batches have no drag handle; long press still offers delete',
    (tester) async {
      final queue = DictationQueue();
      addTearDown(queue.dispose);
      final a = enqueue(queue, 'A');
      enqueue(queue, 'B');
      final release = Completer<DictationQueueStatus>();
      final run = queue.run((_) => release.future);
      DictationQueueEntry? requested;
      await showQueue(tester, queue, onDelete: (entry) => requested = entry);
      await tester.pumpAndSettle();
      expect(find.byType(ReorderableDragStartListener), findsOneWidget);
      await tester.longPress(find.text('A'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('删除'));
      await tester.pumpAndSettle();
      expect(requested, same(a));
      release.complete(DictationQueueStatus.cancelled);
      await run;
      await tester.pumpAndSettle();
    },
  );
}

class _SettingsApi extends RustLibApi {
  @override
  String? crateApiSimpleGetSetting({required String key}) => null;

  @override
  String? crateApiSimpleGetToken({required String base}) => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
