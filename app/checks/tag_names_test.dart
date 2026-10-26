import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kikoeta_app/data.dart';
import 'package:kikoeta_app/l10n/generated/app_localizations.dart';
import 'package:kikoeta_app/l10n/tag_names.dart';
import 'package:kikoeta_app/services/api_service.dart';
import 'package:kikoeta_app/services/download_service.dart';
import 'package:kikoeta_app/theme.dart';
import 'package:kikoeta_app/widgets.dart';

Work parseWork() => ApiService.parseWorks(
  jsonEncode({
    'works': [
      {
        'id': 123456,
        'title': 'Title',
        'tags': [
          {'id': 496, 'name': '环绕音', 'voteStatus': 1},
          {
            'id': 503,
            'name': '低语',
            'voteStatus': 0,
            'i18n': {
              'en-us': {'name': 'Whispering'},
              'ja-jp': {'name': 'ささやき'},
              'zh-cn': {'name': '低语'},
            },
          },
          {'id': 1, 'name': 'Rejected tag', 'voteStatus': 2},
        ],
      },
    ],
  }),
).works.single;

void main() {
  test(
    'ONE aliases use its English/Japanese names and DLsite Traditional names',
    () {
      final work = parseWork();
      expect(work.tags, ['环绕音', '低语']);
      expect(work.grayTags, ['低语']);
      expect(work.tagLabel('环绕音', const Locale('en')), 'Binaural');
      expect(work.tagLabel('低语', const Locale('en')), 'Whispering');
      expect(work.tagLabel('环绕音', const Locale('ja')), 'バイノーラル/ダミヘ');
      expect(work.tagLabel('环绕音', const Locale('zh', 'TW')), '環繞音');
      expect(
        work.tagLabel(
          '环绕音',
          const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
        ),
        '環繞音',
      );
      expect(work.tagLabel('环绕音', const Locale('zh', 'HK')), '環繞音');
      expect(work.tagLabel('环绕音', const Locale('ru')), 'Binaural');
    },
  );

  test(
    'missing and empty translations fall back to English, then original',
    () {
      const names = {'en-us': 'English name', 'zh-tw': ''};
      expect(
        TagNames.display(
          'original',
          const Locale('zh', 'TW'),
          translations: names,
        ),
        'English name',
      );
      expect(
        TagNames.display('original', const Locale('ru'), translations: names),
        'English name',
      );
      expect(TagNames.display('Custom tag', const Locale('en')), 'Custom tag');
      expect(
        TagNames.fromApi({'id': 496, 'name': 'Unrelated custom tag'}),
        isEmpty,
      );
      expect(
        TagNames.fromApi({
          'name': 'Custom',
          'i18n': {
            'en-us': {'name': null},
          },
        }),
        isEmpty,
      );
    },
  );

  test(
    'legacy cached tag names still localize without stored translations',
    () {
      expect(TagNames.display('环绕音', const Locale('en')), 'Binaural');
      expect(TagNames.display('低语', const Locale('zh', 'TW')), '低語');
      final names = TagNames.fromJson(
        jsonDecode(jsonEncode(parseWork().tagNames)),
      );
      expect(
        TagNames.display('低语', const Locale('ja'), translations: names['低语']),
        'ささやき',
      );
    },
  );

  test('advanced filter labels localize while search keys stay original', () {
    final entry = AdvancedFilterEntry(
      id: '496',
      name: '环绕音',
      count: 10,
      tagNames: TagNames.fromApi({'id': 496, 'name': '环绕音'}),
    );
    expect(entry.label(const Locale('en')), 'Binaural');
    expect(entry.name, '环绕音');
    const voiceActor = AdvancedFilterEntry(id: '1', name: '低语', count: 1);
    expect(voiceActor.label(const Locale('en')), '低语');
  });

  test('playback snapshots retain per-work tag translations', () {
    final saved = <String, String>{};
    final app = AppState(
      playbackSettingsWriter: (key, value) => saved[key] = value,
    );
    addTearDown(app.dispose);
    app.currentWork = parseWork();
    app.queue = [
      const MediaNode(title: 'audio', type: 'file', path: 'audio.mp3'),
    ];
    app.savePlayState();
    app.restorePlayState(saved['play_state']);
    expect(app.currentWork!.tagNames, parseWork().tagNames);
    expect(app.currentWork!.tagLabel('低语', const Locale('en')), 'Whispering');
  });

  test(
    'download records preserve custom translations and read legacy tags',
    () {
      final record = VoiceDownload.fromJson({
        'id': 'download',
        'server': 'https://example.com',
        'voiceRoot': 'downloads',
        'work': {
          'rj': 'RJ123456',
          'tags': ['Custom tag'],
          'tagNames': {
            'Custom tag': {'en-us': 'Custom English', 'ja-jp': '独自タグ'},
          },
        },
      });
      final restored = VoiceDownload.fromJson(record.toJson());
      expect(restored.work.tagLabel('Custom tag', const Locale('ja')), '独自タグ');
      final legacy = VoiceDownload.fromJson({
        ...record.toJson(),
        'work': {
          'rj': 'RJ123456',
          'tags': ['环绕音'],
        },
      });
      expect(legacy.work.tagLabel('环绕音', const Locale('en')), 'Binaural');
    },
  );

  testWidgets(
    'cached cards relabel on locale changes without replacing works',
    (tester) async {
      final work = parseWork();
      final locale = ValueNotifier(const Locale('en'));
      addTearDown(locale.dispose);
      await tester.pumpWidget(
        ValueListenableBuilder(
          valueListenable: locale,
          builder: (_, value, _) => MaterialApp(
            locale: value,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: buildTheme(Brightness.light),
            home: Scaffold(
              body: SizedBox(
                width: 240,
                child: WorkCard(work: work, index: 0, onTap: () {}),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Binaural'), findsOneWidget);
      expect(find.text('Whispering'), findsOneWidget);
      locale.value = const Locale('zh', 'CN');
      await tester.pumpAndSettle();
      expect(find.text('低语'), findsOneWidget);
      expect(find.text('Whispering'), findsNothing);
      locale.value = const Locale.fromSubtags(
        languageCode: 'zh',
        scriptCode: 'Hant',
      );
      await tester.pumpAndSettle();
      expect(find.text('環繞音'), findsOneWidget);
      expect(find.text('低語'), findsOneWidget);
      expect(work.tags, ['环绕音', '低语']);
      expect(tester.takeException(), isNull);
    },
  );
}
