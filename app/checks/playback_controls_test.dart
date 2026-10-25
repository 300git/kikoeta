import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kikoeta_app/data.dart';
import 'package:kikoeta_app/l10n/generated/app_localizations.dart';
import 'package:kikoeta_app/pages/settings_page.dart';
import 'package:kikoeta_app/services/audio_effects.dart';
import 'package:kikoeta_app/sheets.dart';
import 'package:kikoeta_app/theme.dart';
import 'package:kikoeta_app/widgets.dart';

void main() {
  Future<void> showSheet(
    WidgetTester tester,
    AppState app,
    Future<void> Function(BuildContext, AppState) open,
  ) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: buildTheme(Brightness.light),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => open(context, app),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('playback settings exposes the speed switch and resets speed', (
    tester,
  ) async {
    final saved = <String, String>{};
    final app = AppState(
      playbackSettingsWriter: (key, value) => saved[key] = value,
    );
    addTearDown(app.dispose);
    await tester.pumpWidget(
      ListenableBuilder(
        listenable: app,
        builder: (context, _) => MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: buildTheme(Brightness.light),
          home: SettingsPage(app: app, sectionKey: 'playback'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final speedSwitch = find.descendant(
      of: find
          .ancestor(of: find.text('显示倍速入口'), matching: find.byType(Row))
          .first,
      matching: find.byType(Switch),
    );
    await tester.ensureVisible(speedSwitch);
    expect(tester.widget<Switch>(speedSwitch).value, isFalse);
    await tester.tap(speedSwitch);
    await tester.pumpAndSettle();
    expect(app.playbackSpeedEnabled, isTrue);
    app.setPlaybackRate(3);
    await tester.pumpAndSettle();
    await tester.tap(speedSwitch);
    await tester.pumpAndSettle();
    expect(app.playbackRate, 1);
    expect(saved['playback_rate'], '1.0');
    expect(tester.takeException(), isNull);
  });

  testWidgets('speed sheet offers exactly five presets at phone width', (
    tester,
  ) async {
    final saved = <String, String>{};
    final app = AppState(
      playbackSettingsWriter: (key, value) => saved[key] = value,
    )..setPlaybackSpeedEnabled(true);
    addTearDown(app.dispose);
    await showSheet(tester, app, showPlaybackSpeedSheet);
    expect(find.byType(Pill), findsNWidgets(5));
    for (final label in ['0.5×', '1×', '1.5×', '2×', '3×']) {
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      final pill = tester.widget<Pill>(
        find.ancestor(of: find.text(label), matching: find.byType(Pill)),
      );
      expect(pill.selected, isTrue);
    }
    expect(app.playbackRate, 3);
    expect(saved['playback_rate'], '3.0');
    expect(tester.takeException(), isNull);
  });

  testWidgets('channel modes can switch and restore independently of speed', (
    tester,
  ) async {
    final app = AppState(playbackSettingsWriter: (_, _) {});
    addTearDown(app.dispose);
    await showSheet(tester, app, showAudioChannelSheet);
    for (final selection in {
      '左右反转': AudioChannelMode.swap,
      '声道合并': AudioChannelMode.mono,
      '原始声道': AudioChannelMode.stereo,
    }.entries) {
      await tester.tap(find.text(selection.key));
      await tester.pumpAndSettle();
      expect(app.audioChannelMode, selection.value);
      expect(app.playbackSpeedEnabled, isFalse);
      expect(app.playbackRate, 1);
    }
    expect(tester.takeException(), isNull);
  });
}
