import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/widgets.dart';

import 'generated/app_localizations.dart';

/// UI 语言偏好与可用资源。未开放的语言不参与系统语言匹配。
class AppLanguage {
  AppLanguage._();

  static const system = 'system';
  static const simplifiedChinese = 'zh-CN';
  static const selectablePreferences = [system, simplifiedChinese];
  static String _preference = system;

  static String get preference => _preference;

  static void setPreference(String value) {
    if (selectablePreferences.contains(value)) _preference = value;
  }

  static Locale? get localeOverride =>
      _preference == system ? null : const Locale('zh', 'CN');

  static Locale resolveLocale(List<Locale> systemLocales) =>
      basicLocaleListResolution(
        localeOverride == null ? systemLocales : [localeOverride!],
        AppLocalizations.supportedLocales,
      );

  static Locale get resolvedLocale =>
      resolveLocale(PlatformDispatcher.instance.locales);

  static String get translationTarget {
    final locale = resolvedLocale;
    if (locale.languageCode == 'zh') {
      return locale.scriptCode == 'Hant' ||
              const ['TW', 'HK', 'MO'].contains(locale.countryCode)
          ? 'zh-TW'
          : 'zh-CN';
    }
    return locale.languageCode;
  }

  static AppLocalizations? _cachedStrings;
  static Locale? _cachedLocale;

  /// 无 BuildContext 的服务提示使用同一套已解析的 UI 语言。
  static AppLocalizations get strings {
    final locale = resolvedLocale;
    if (_cachedLocale != locale || _cachedStrings == null) {
      _cachedLocale = locale;
      _cachedStrings = lookupAppLocalizations(locale);
    }
    return _cachedStrings!;
  }
}
