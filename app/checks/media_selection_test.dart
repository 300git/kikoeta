import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kikoeta_app/data.dart';
import 'package:kikoeta_app/l10n/generated/app_localizations.dart';
import 'package:kikoeta_app/pages/work_page.dart';
import 'package:kikoeta_app/services/download_service.dart';
import 'package:kikoeta_app/services/media_selection.dart';
import 'package:kikoeta_app/services/media_tree.dart';
import 'package:kikoeta_app/theme.dart';

MediaNode file(String path) =>
    MediaNode(title: path.split('/').last, type: 'file', path: path);

MediaNode folder(String path, List<MediaNode> children) =>
    MediaNode(title: path, type: 'folder', path: path, children: children);

void main() {
  test('flat root files support select all and invert', () {
    final roots = [file('1.mp3'), file('2.mp3'), file('3.mp3')];
    final selection = MediaSelection();
    selection.toggle(roots.first, roots);
    selection.invert(roots);
    expect(selection.paths, {'2.mp3', '3.mp3'});
    selection.selectAll(roots);
    expect(selection.paths, {'1.mp3', '2.mp3', '3.mp3'});
    selection.invert(roots);
    expect(selection.paths, isEmpty);
    expect(selection.projects, isEmpty);
  });

  test(
    'bulk selection synchronizes nested folder states and compact projects',
    () {
      final a = file('disc/1.mp3');
      final b = file('disc/sub/2.mp3');
      final sub = folder('disc/sub', [b]);
      final disc = folder('disc', [a, sub]);
      final roots = [disc, file('3.mp3')];
      final selection = MediaSelection()..bindTree(roots);
      selection.setSelected(a, true, roots);
      expect(selection.state(disc), isNull);
      selection.invert(roots);
      expect(selection.state(disc), isNull);
      expect(selection.state(sub), isTrue);
      expect(selection.paths, {'disc/sub', 'disc/sub/2.mp3', '3.mp3'});
      selection.selectAll(roots);
      expect(selection.state(disc), isTrue);
      expect(selection.projects, {'disc', '3.mp3'});
      selection.invert(roots);
      expect(selection.state(disc), isFalse);
      expect(selection.paths, isEmpty);
    },
  );

  test(
    'filtered bulk operations preserve hidden files and update copied folders',
    () {
      final audio = file('disc/1.mp3');
      final text = file('disc/readme.txt');
      final disc = folder('disc', [audio, text]);
      final roots = [disc];
      final filtered = folder('disc', [audio]);
      final scope = MediaTreeIndex([filtered]);
      final selection = MediaSelection()..bindTree(roots);
      selection.setSelected(text, true, roots);
      expect(selection.state(filtered), isFalse);
      selection.selectAll(roots, scope: scope);
      expect(selection.state(filtered), isTrue);
      expect(selection.state(disc), isTrue);
      expect(selection.projects, {'disc'});
      selection.invert(roots, scope: scope);
      expect(selection.paths, {'disc/readme.txt'});
      expect(selection.state(filtered), isFalse);
      expect(selection.state(disc), isNull);
    },
  );

  test('select all in a filtered tree does not select hidden siblings', () {
    final audio = file('disc/1.mp3');
    final text = file('disc/readme.txt');
    final roots = [
      folder('disc', [audio, text]),
    ];
    final scope = MediaTreeIndex([
      folder('disc', [audio]),
    ]);
    final selection = MediaSelection();
    selection.selectAll(roots, scope: scope);
    expect(selection.paths, {'disc/1.mp3'});
    expect(selection.state(roots.first), isNull);
    selection.setSelected(text, true, roots);
    expect(selection.state(roots.first), isTrue);
  });

  test(
    'drag snapshot restoration remains consistent after bulk operations',
    () {
      final a = file('disc/1.mp3');
      final b = file('disc/2.mp3');
      final disc = folder('disc', [a, b]);
      final roots = [disc];
      final selection = MediaSelection()..bindTree(roots);
      selection.setSelected(a, true, roots);
      final beforeDrag = Set<String>.of(selection.paths);
      selection.selectAll(roots);
      selection.restorePaths(beforeDrag);
      expect(selection.paths, beforeDrag);
      expect(selection.state(disc), isNull);
      selection.setSelected(b, true, roots);
      expect(selection.projects, {'disc'});
      selection.invert(roots);
      expect(selection.paths, isEmpty);
    },
  );

  test('empty trees and empty folders retain consistent selection states', () {
    final selection = MediaSelection();
    selection.selectAll([]);
    selection.invert([]);
    expect(selection.paths, isEmpty);
    final empty = folder('empty', []);
    final roots = [empty];
    selection.selectAll(roots);
    expect(selection.state(empty), isTrue);
    selection.invert(roots);
    expect(selection.paths, isEmpty);
  });

  Future<void> showWork(WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final app = AppState()..initialPathBehavior = 'root';
    addTearDown(app.dispose);
    const work = Work(
      rj: 'RJ000001',
      title: 'Selection test',
      circle: '',
      va: '',
      age: Age.all,
      dur: '00:03',
      tags: [],
      grad: 0,
    );
    final item = VoiceDownload(
      id: 'selection-test',
      server: 'https://example.invalid',
      voiceRoot: '/selection-test',
      work: work,
      tree: [file('1.mp3'), file('2.mp3'), file('3.mp3')],
      selectedPaths: {},
    );
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh', 'CN'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: buildTheme(Brightness.light),
        home: WorkPage(app: app, work: work, downloadItem: item),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'top actions appear only after checking a box and operate on the tree',
    (tester) async {
      await showWork(tester);
      expect(find.byTooltip('全选'), findsNothing);
      expect(find.byTooltip('反选'), findsNothing);
      final boxes = find.byType(Checkbox);
      await tester.ensureVisible(boxes.first);
      await tester.tap(boxes.first);
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byTooltip('全选'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byTooltip('反选'),
        ),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.select_all), findsOneWidget);
      expect(find.byIcon(Icons.flip_to_back), findsOneWidget);
      await tester.tap(find.byTooltip('全选'));
      await tester.pumpAndSettle();
      expect(
        tester.widgetList<Checkbox>(boxes).every((box) => box.value == true),
        isTrue,
      );
      await tester.tap(find.byTooltip('反选'));
      await tester.pumpAndSettle();
      expect(
        tester.widgetList<Checkbox>(boxes).every((box) => box.value == false),
        isTrue,
      );
      expect(find.byTooltip('全选'), findsNothing);
      expect(find.byTooltip('反选'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('existing mouse drag selection also activates the top actions', (
    tester,
  ) async {
    await showWork(tester);
    final boxes = find.byType(Checkbox);
    await tester.ensureVisible(boxes.first);
    final gesture = await tester.startGesture(
      tester.getCenter(boxes.at(0)),
      kind: PointerDeviceKind.mouse,
    );
    await gesture.moveTo(tester.getCenter(boxes.at(1)));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
    expect(tester.widget<Checkbox>(boxes.at(0)).value, isTrue);
    expect(tester.widget<Checkbox>(boxes.at(1)).value, isTrue);
    expect(find.byTooltip('全选'), findsOneWidget);
    expect(find.byTooltip('反选'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
