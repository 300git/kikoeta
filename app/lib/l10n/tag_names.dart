import 'package:flutter/widgets.dart';

import 'tag_names_data.dart';

/// Display names only. Original tag names remain the search/blacklist keys.
class TagNames {
  TagNames._();

  static Map<String, String> fromApi(Map tag) {
    final name = tag['name']?.toString().trim() ?? '';
    // Custom servers may use unrelated numeric IDs; match an alias first.
    final id = tagIdsByAlias[name];
    final names = <String, String>{...?tagNamesById[id]};
    final translations = tag['i18n'];
    if (translations is Map) {
      for (final entry in translations.entries) {
        final value = entry.value;
        final translated = value is Map ? value['name'] : null;
        if (translated is String && translated.trim().isNotEmpty) {
          names[entry.key.toString().toLowerCase().replaceAll('_', '-')] =
              translated.trim();
        }
      }
    }
    return names;
  }

  static Map<String, Map<String, String>> fromJson(Object? raw) {
    if (raw is! Map) return const {};
    return {
      for (final entry in raw.entries)
        if (entry.key is String && entry.value is Map)
          entry.key as String: {
            for (final name in (entry.value as Map).entries)
              if (name.key is String && name.value is String)
                name.key as String: name.value as String,
          },
    };
  }

  static String display(
    String original,
    Locale locale, {
    Map<String, String>? translations,
  }) {
    final names = translations ?? tagNamesById[tagIdsByAlias[original]];
    if (names == null) return original;
    final language = switch (locale.languageCode) {
      'zh' =>
        locale.scriptCode == 'Hant' ||
                const ['TW', 'HK', 'MO'].contains(locale.countryCode)
            ? 'zh-tw'
            : 'zh-cn',
      'ja' => 'ja-jp',
      'ko' => 'ko-kr',
      _ => 'en-us',
    };
    final translated = names[language];
    if (translated != null && translated.trim().isNotEmpty) return translated;
    final english = names['en-us'];
    return english != null && english.trim().isNotEmpty ? english : original;
  }
}
