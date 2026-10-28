import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kikoeta_app/l10n/generated/app_localizations.dart';
import 'package:kikoeta_app/pages/lyrics_library_page.dart';
import 'package:kikoeta_app/services/lyrics_library_service.dart';
import 'package:kikoeta_app/subpage_swipe.dart';
import 'package:kikoeta_app/widgets.dart';

class _LibraryService implements LyricsLibraryService {
  final entries = const [
    LyricsLibraryRecord(workId: 'RJ100001', relativePath: 'local'),
    LyricsLibraryRecord(
      workId: 'RJ200002',
      relativePath: 'online',
      online: true,
    ),
  ];

  @override
  Future<List<LyricsLibraryRecord>> records() async => entries;

  @override
  Future<List<LyricsLibraryRecord>> refresh({
    bool deep = false,
    bool Function()? shouldCancel,
  }) async => entries;

  @override
  Future<Map<String, int>> countFilesForWorks(Iterable<String> workIds) async =>
      {for (final id in workIds) id: 1};

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('library swipes and tab taps share the source selection', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh', 'CN'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: LyricsLibraryPage(service: _LibraryService()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('RJ100001'), findsOneWidget);
    expect(find.text('RJ200002'), findsNothing);

    await tester.drag(find.byType(SubpageSwipe), const Offset(-200, 0));
    await tester.pumpAndSettle();
    expect(find.text('RJ100001'), findsNothing);
    expect(find.text('RJ200002'), findsOneWidget);
    final tabs = tester.widgetList<Pill>(find.byType(Pill)).toList();
    expect(tabs.map((tab) => tab.selected), [false, true]);

    await tester.tap(find.byType(Pill).first);
    await tester.pumpAndSettle();
    expect(find.text('RJ100001'), findsOneWidget);
    await tester.drag(find.byType(SubpageSwipe), const Offset(-200, 0));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(SubpageSwipe), const Offset(200, 0));
    await tester.pumpAndSettle();
    expect(find.text('RJ100001'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
