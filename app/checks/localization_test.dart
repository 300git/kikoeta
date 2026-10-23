import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kikoeta_app/data.dart';
import 'package:kikoeta_app/l10n/app_language.dart';
import 'package:kikoeta_app/l10n/generated/app_localizations.dart';
import 'package:kikoeta_app/l10n/strings.dart';
import 'package:kikoeta_app/pages/settings_page.dart';
import 'package:kikoeta_app/theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => AppLanguage.setPreference(AppLanguage.system));
  tearDown(() => AppLanguage.setPreference(AppLanguage.system));

  test(
    'system default falls back to the available simplified Chinese resources',
    () {
      expect(AppLanguage.preference, 'system');
      expect(AppLanguage.localeOverride, isNull);
      for (final locale in const [
        Locale('en', 'US'),
        Locale('ru'),
        Locale('ja'),
        Locale('zh', 'TW'),
      ]) {
        final resolved = AppLanguage.resolveLocale([locale]);
        final strings = lookupAppLocalizations(resolved);
        expect(strings.languageAndTranslation, '语言与翻译');
        expect(strings.simplifiedChinese, '简体中文');
      }
      expect(AppLanguage.resolveLocale([]), const Locale('zh', 'CN'));
      expect(
        AppLocalizations.supportedLocales.every((l) => l.languageCode == 'zh'),
        isTrue,
      );
    },
  );

  test(
    'language preferences persist and unavailable languages are rejected',
    () {
      final saved = <String, String>{};
      final app = AppState(
        languageSettingsWriter: (key, value) => saved[key] = value,
      );
      addTearDown(app.dispose);
      var notifications = 0;
      app.addListener(() => notifications++);

      for (final value in ['en', 'ru', 'ja', 'zh-TW', 'invalid']) {
        app.setUiLanguage(value);
      }
      expect(saved, isEmpty);
      expect(app.uiLanguage, 'system');
      app.setUiLanguage('zh-CN');
      expect(saved, {'ui_language': 'zh-CN'});
      expect(AppLanguage.localeOverride, const Locale('zh', 'CN'));
      expect(notifications, 1);
      app.setUiLanguage('zh-CN');
      expect(notifications, 1);
    },
  );

  test(
    'background import workers can read localized progress messages',
    () async {
      expect(await Isolate.run(() => appL10n.confirm), '确定');
    },
  );

  testWidgets(
    'follow UI resolves the effective language instead of the unsupported system locale',
    (tester) async {
      tester.binding.platformDispatcher.localesTestValue = const [
        Locale('en', 'US'),
      ];
      addTearDown(tester.binding.platformDispatcher.clearLocalesTestValue);
      final saved = <String, String>{};
      final app = AppState(
        languageSettingsWriter: (key, value) => saved[key] = value,
      );
      addTearDown(app.dispose);
      app.setTranslationTarget('ui');
      expect(saved['translation_target'], 'ui');
      expect(app.translationTarget, 'ui');
      expect(app.resolvedTranslationTarget, 'zh-CN');
      app.setUiLanguage('zh-CN');
      expect(app.resolvedTranslationTarget, 'zh-CN');
      app.setTranslationTarget('en');
      expect(app.resolvedTranslationTarget, 'en');
      app.setTranslationTarget('zh-TW');
      expect(app.resolvedTranslationTarget, 'zh-TW');
      app.setTranslationTarget('invalid');
      expect(app.translationTarget, 'zh-TW');
    },
  );

  Future<void> showSettings(
    WidgetTester tester,
    AppState app, {
    String? section = 'translation',
  }) async {
    await tester.pumpWidget(
      AnimatedBuilder(
        animation: app,
        builder: (context, _) => MaterialApp(
          locale: AppLanguage.localeOverride,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: buildTheme(Brightness.light),
          home: SettingsPage(app: app, sectionKey: section),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'language menu is first and only simplified Chinese is selectable',
    (tester) async {
      final saved = <String, String>{};
      final app = AppState(
        languageSettingsWriter: (key, value) => saved[key] = value,
      );
      addTearDown(app.dispose);
      await showSettings(tester, app);
      expect(find.text('语言与翻译'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('界面语言')).dy,
        lessThan(tester.getTopLeft(find.text('翻译引擎')).dy),
      );
      expect(find.text('跟随系统'), findsOneWidget);

      await tester.tap(find.byTooltip('界面语言'));
      await tester.pumpAndSettle();
      final entries = tester
          .widgetList<PopupMenuItem<String>>(find.byType(PopupMenuItem<String>))
          .where((entry) => entry.value != null)
          .toList();
      expect(entries.map((entry) => entry.value), [
        'system',
        'zh-CN',
        'zh-TW',
        'ja',
        'en',
        'ru',
      ]);
      expect(
        entries.where((entry) => entry.enabled).map((entry) => entry.value),
        ['zh-CN'],
      );
      for (final label in ['繁体中文', '日本語', 'English', 'Русский']) {
        expect(find.text(label), findsOneWidget);
      }
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      expect(app.uiLanguage, 'system');
      expect(saved, isEmpty);
      await tester.tap(find.text('简体中文'));
      await tester.pumpAndSettle();
      expect(app.uiLanguage, 'zh-CN');
      expect(saved['ui_language'], 'zh-CN');
      expect(find.text('简体中文'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'translation menu offers follow UI and retains explicit targets',
    (tester) async {
      final saved = <String, String>{};
      final app = AppState(
        languageSettingsWriter: (key, value) => saved[key] = value,
      );
      addTearDown(app.dispose);
      await showSettings(tester, app);
      await tester.tap(find.byTooltip('翻译目标语言'));
      await tester.pumpAndSettle();
      for (final code in ['ui', 'zh-CN', 'zh-TW', 'en']) {
        expect(
          tester
              .widget<PopupMenuItem<String>>(
                find.byWidgetPredicate(
                  (widget) =>
                      widget is PopupMenuItem<String> && widget.value == code,
                ),
              )
              .enabled,
          isTrue,
        );
      }
      await tester.tap(find.text('跟随界面语言'));
      await tester.pumpAndSettle();
      expect(app.translationTarget, 'ui');
      expect(app.resolvedTranslationTarget, 'zh-CN');
      expect(saved['translation_target'], 'ui');
      expect(find.textContaining('日语 → 跟随界面语言'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
