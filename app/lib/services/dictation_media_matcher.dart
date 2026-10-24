import 'package:flutter/foundation.dart';

import '../data.dart';
import 'media_tree.dart';

/// Metadata-only selection: identity keys first, version preferences second
/// (the same separation used by beets' duplicates keys/tiebreak options).
/// Unknown editions and distinct bonus scopes are deliberately retained.
class DictationMediaMatcher {
  static final _media = RegExp(
    r'\.(mp3|ogg|opus|wav|aac|flac|webm|mp4|m4a|mka|aiff|wma|ape|mkv|avi|mov|wmv|flv|ts|m4v)$',
    caseSensitive: false,
  );
  static final _fullOff = RegExp(
    r'(?<![a-z])(?:no[ _-]*se|non[ _-]*se|se[ _-]*less)(?![a-z])|'
    r'(?:se[・\s]*(?:エフェクト|効果音)?|効果音|效果音|音效)[ _-]*(?:無し?|無し|なし|カット|off)|'
    r'(?:无|無)(?:se|効果音|效果音|音效)|(?:声|ボイス|voice)[ _-]*(?:のみ|only)',
  );
  static final _partialOff = RegExp(
    r'(?:環境音|环境音)[・&+](?:bgm)[ _-]*(?:なし|無し?|off)|'
    r'(?:射精|時計|オルゴール|魔法|環境|环境)(?:の)?(?:se|効果音|音效|音)?[ _-]*(?:なし|無し?|无|無)|'
    r'(?:无|無)(?:射精|魔法|環境|环境)(?:音效|音)?|(?:bgm)[ _-]*(?:なし|無し?|off)|'
    r'無オルゴール音|時計なし',
  );
  static final _soundOn = RegExp(
    r'(?:se|効果音|效果音|音效)[ _-]*(?:有り?|あり|on)|(?:有)(?:se|効果音|效果音|音效)|'
    r'(?<![a-z])se$|有オルゴール音|bgm[ _-]*(?:有り?|あり|on)',
  );
  static final _reduced = RegExp(
    r'(?<![a-z])(?:se[ _-]*(?:low|reduced|quiet)|(?:low|reduced)[ _-]*se)(?![a-z])',
  );
  static final _offTag = RegExp('(?:${_fullOff.pattern})(?:版|ver\\.?)?');
  static final _partialTag = RegExp('(?:${_partialOff.pattern})(?:版|ver\\.?)?');
  static final _onTag = RegExp('(?:${_soundOn.pattern})(?:版|ver\\.?)?');
  static final _reducedTag = RegExp('(?:${_reduced.pattern})(?:版|ver\\.?)?');
  static final _bitDepth = RegExp(r'(?<!\d)(16|24|32)[ _-]*bit');
  static final _bitSuffix = RegExp(r'[_ -](16|24|32)$');
  static final _trailingSe = RegExp(r'(?<![a-z])se$');
  static final _bonusNumber = RegExp(r'特典[①-⑳\d]*');
  static final _skipNote = RegExp(r'スキップ可');
  static final _versionEnd = RegExp(r'(?:version|ver\.?)$');
  static final _numberOnly = RegExp(r'^\d+$');
  static final _format = RegExp(
    r'(?<![a-z])(?:mp3|wav(?:e)?|flac|ogg|opus|m4a|aac|aiff|wma|ape)(?![a-z])',
  );
  static final _decoration = RegExp(r'[\s_\-.,:：;()（）\[\]【】{}「」・★☆]+');
  static final _ordinal = RegExp(r'^\d+[\s_.\-]*');
  static final _quality = RegExp(
    r'\d+(?:kbps|bit|khz)|最高品質|高音質版?|ハイレゾ|ロスレス形式|圧縮形式|'
    r'軽量版|全\d+パターン|おすすめ|推奨|通常|ノーマル|normal|standard|'
    r'本編|音声|データ|ファイル|形式|バージョン|(?<![a-z])(?:version|ver\.?)(?![a-z])|版',
  );
  static final _bonus = RegExp(
    r'特典|おまけ|オマケ|omake|bonus|フリートーク|キャストトーク|free[ _-]*talk|prtalk|^ex(?:\d|データ|トラック)',
  );
  static final _talk = RegExp(r'フリートーク|キャストトーク|free[ _-]*talk|prtalk');
  static final _promo = RegExp(
    r'体験版|サンプル|宣伝|告知|^(?:\d+[ _.-]*)?(?:sample|preview|demo|cm|pr|pv)(?:$|[ _.-])|'
    r'(?:^|[_ -])(?:cm|pv)(?:$|[_. -])',
  );
  static final _soundOnly = RegExp(
    r'^(?:作品)?bgm$|^(?:se|効果音|效果音|音效)素材$|^効果音集$',
  );
  static final _noSpeech = RegExp(
    r'(?:无|無)(?:人[声聲]|对白|對白|台[词詞]|语音|語音)|'
    r'(?:ボイス|人声|人聲|セリフ|台詞)[ _-]*(?:なし|無し?|off|カット)|'
    r'(?:^|[ _\[【(（])声(?:なし|無し?|off)|'
    r'(?<![a-z])(?:no[ _-]*(?:voice|vocals?|speech|dialogue)|non[ _-]*(?:voice|vocal)|'
    r'(?:voice|vocals?|speech|dialogue)[ _-]*off)(?![a-z])|'
    r'(?:環境音|环境音|雨音|波音|心音|寝息|呼吸音|吐息|耳かき|耳舐め)(?:する)?(?:のみ|だけ)|'
    r'(?:纯|純)(?:环境音|環境音|音效)',
  );
  static final _pureSound = RegExp(
    r'^(?:(?:tr(?:ack)?|ex|トラック)?\d+)?'
    r'(?:寝息|呼吸音|吐息|環境音|环境音|雨音|波音|焚き火|bgm)'
    r'(?:\d+|ループ|loop)?$|の寝息(?:ループ|loop)?$',
  );
  static final _pureBonusSound = RegExp(
    r'^(?:(?:tr(?:ack)?|ex|トラック)?\d+)?(?:耳かき|耳舐め)(?:\d+)?$',
  );
  static final _materialFolder = RegExp(r'音源|素材');
  static final _soundMaterialClip = RegExp(
    r'^(?:優しい)?(?:鼻息)?(?:耳舐め|耳かき|フェラ)(?:[_ -][^\s]+)+$',
  );
  static final _speechLabel = RegExp(
    r'ボイス|セリフ|台詞|囁き|ささやき|会話|对白|對白|台词|语音|語音|'
    r'(?<![a-z])(?:voice|speech|dialogue)(?![a-z])',
  );
  static final _earlyEdition = RegExp(
    r'(?:(?:早期|初期|先行)(?:購入|購買|购买|购入)?|初回(?:限定)?)'
    r'(?:特典(?:付き|付|同梱))?(?:版|ver(?:sion)?\.?)|初版|'
    r'(?<![a-z])(?:early|first)[ _-]*(?:purchase[ _-]*)?(?:edition|version|release|ver\.?)(?![a-z])',
  );
  static final _earlyBonus = RegExp(r'(?:早期|初期|初回)(?:購入|購買|购买|购入)?特典');
  static final _regularEdition = RegExp(
    r'(?:通常|普通|常规|常規|标准|標準)(?:版|ver(?:sion)?\.?)|'
    r'(?<![a-z])(?:regular|standard|normal)[ _-]*(?:edition|version|ver\.?)(?![a-z])',
  );
  static final _editionHearts = RegExp(r'^[♡♥❤]*$');
  static final _combined = RegExp(
    r'通し|ぶっ通し|連結|一括|全パート|全編|フルバージョン|full[ _-]*track',
  );
  static const _languageNames = {
    '日本語': 0,
    '日文': 0,
    '日语': 0,
    '日語': 0,
    'japanese': 0,
    'ja': 0,
    'jp': 0,
    '简体中文': 1,
    '簡體中文': 1,
    '简体': 1,
    '簡體': 1,
    'zhcn': 1,
    'zhhans': 1,
    'simplifiedchinese': 1,
    '繁體中文': 2,
    '繁体中文': 2,
    '繁體': 2,
    '繁体': 2,
    'zhtw': 2,
    'zhhant': 2,
    'traditionalchinese': 2,
  };
  static final _chapter = RegExp(
    r'^(?:(?:tr(?:ack)?|トラック|音轨|音軌)[ _.-]*)?(\d+)(?=$|[^a-z0-9])',
  );
  static final _prefixedChapter = RegExp(r'^[a-z]+\d+[_-](\d+)(?=$|[^a-z0-9])');

  /// Large collections run off the UI isolate on Flutter's native platforms.
  static Future<List<MediaNode>> selectForDictation(
    MediaTreeIndex index,
  ) async {
    if (index.rows.length <= 512) return select(index);
    return compute(select, index, debugLabel: 'dictation-media-matching');
  }

  /// Runs once when opening dictation, never during build/scroll. [index] can
  /// reuse the work page's full tree, independent of the visible media filter.
  static List<MediaNode> select(MediaTreeIndex index) {
    final scopes = List<String>.filled(index.rows.length, '');
    final ranks = List<int>.filled(index.rows.length, 0);
    final excluded = List<bool>.filled(index.rows.length, false);
    final bonuses = List<bool>.filled(index.rows.length, false);
    final bits = List<int>.filled(index.rows.length, 0);
    final earlyEditions = List<bool>.filled(index.rows.length, false);
    final speechless = List<bool>.filled(index.rows.length, false);
    final soundMaterials = List<bool>.filled(index.rows.length, false);
    final spokenScopes = List<bool>.filled(index.rows.length, false);
    final languages = <int, int>{};
    final languageSiblings = <int, Set<int>>{};
    final winners = <String, _Candidate>{};
    for (final row in index.rows) {
      final node = row.node;
      final parent = row.parentIndex;
      final name = _widthFold(node.title);
      if (!node.isDir && (!_media.hasMatch(name) || !hasSource(node))) continue;
      final early =
          (parent != null && earlyEditions[parent]) ||
          _earlyEdition.hasMatch(name) ||
          _earlyBonus.hasMatch(name);
      final stem = node.isDir ? name : name.replaceFirst(_media, '');
      final bitDepth =
          int.tryParse(_bitDepth.firstMatch(name)?.group(1) ?? '') ??
          (name.contains('ハイレゾ') ? 24 : (parent == null ? 0 : bits[parent]));
      final inheritedRank = parent == null ? 0 : ranks[parent];
      final rank = _rank(name, inheritedRank);
      final bonus =
          (parent != null && bonuses[parent]) || _bonus.hasMatch(name);
      final material =
          (parent != null && soundMaterials[parent]) ||
          (node.isDir && _materialFolder.hasMatch(name));
      final spoken =
          (parent != null && spokenScopes[parent]) ||
          (node.isDir && (_speechLabel.hasMatch(name) || _talk.hasMatch(name)));
      final compactStem = _compact(stem);
      final noSpeech =
          (parent != null && speechless[parent]) ||
          _noSpeech.hasMatch(stem) ||
          _pureSound.hasMatch(compactStem) ||
          (bonus && !spoken && _pureBonusSound.hasMatch(compactStem)) ||
          (!node.isDir &&
              material &&
              !spoken &&
              _soundMaterialClip.hasMatch(stem) &&
              !_talk.hasMatch(stem) &&
              !_speechLabel.hasMatch(stem));
      final blocked =
          (parent != null && excluded[parent]) ||
          _promo.hasMatch(name) ||
          _soundOnly.hasMatch(_compact(name));
      if (node.isDir) {
        final scope = _folderKey(name);
        final language = _languageNames[scope];
        if (language != null) {
          languages[row.index] = language;
          (languageSiblings[parent ?? -1] ??= {}).add(language);
        }
        final parentScope = parent == null ? '' : scopes[parent];
        scopes[row.index] = scope.isEmpty
            ? parentScope
            : '${parentScope.isEmpty ? '' : '$parentScope/'}$scope';
        ranks[row.index] = rank;
        excluded[row.index] = blocked;
        bonuses[row.index] = bonus;
        bits[row.index] = bitDepth;
        earlyEditions[row.index] = early;
        speechless[row.index] = noSpeech;
        soundMaterials[row.index] = material;
        spokenScopes[row.index] = spoken;
        continue;
      }
      if (noSpeech || (blocked && !_talk.hasMatch(name))) {
        continue;
      }
      final titleKey = _titleKey(stem, bitDepth);
      // Empty/format-only titles cannot establish identity (e.g. MP3.mp3).
      final scope = parent == null ? '' : scopes[parent];
      final namedEdition =
          _fullOff.hasMatch(stem) ||
          _partialOff.hasMatch(stem) ||
          _reduced.hasMatch(stem) ||
          _soundOn.hasMatch(stem);
      final key = titleKey.isEmpty && !namedEdition
          ? node.path
          : '$scope|$titleKey';
      final candidate = _Candidate(
        node,
        rank,
        early,
        bonus,
        row.index,
        scope,
        bitDepth,
        _combined.hasMatch(name) ||
            (parent != null &&
                _combined.hasMatch(_widthFold(index.rows[parent].node.title))),
      );
      final current = winners[key];
      if (current == null || candidate.preferredTo(current)) {
        winners[key] = candidate;
      }
    }

    final selected = winners.values.toList();
    // Only remove a named full track when chapters in the same semantic scope
    // cover its duration. Missing metadata or an uncertain sum retains both.
    final chapters = <String, (int, int)>{};
    for (final item in selected) {
      if (item.bonus || item.combined || item.node.duration <= 0) continue;
      final previous = chapters[item.scope] ?? (0, 0);
      chapters[item.scope] = (
        previous.$1 + 1,
        previous.$2 + item.node.duration,
      );
    }
    selected.removeWhere((item) {
      if (!item.combined || item.bonus || item.node.duration <= 0) return false;
      final parts = chapters[item.scope];
      return parts != null &&
          parts.$1 >= 2 &&
          (parts.$2 - item.node.duration).abs() <= parts.$1 + 2;
    });
    _deduplicateLanguages(selected, index, scopes, languages, languageSiblings);
    selected.sort((a, b) => a.order.compareTo(b.order));
    return selected.map((item) => item.node).toList();
  }

  static bool hasSource(MediaNode node) =>
      (node.downloadUrl?.isNotEmpty ?? false) ||
      (node.url?.isNotEmpty ?? false);

  /// Translated filenames cannot share a title key. Only explicit sibling
  /// language editions may instead share a numbered chapter + duration key.
  /// Unknown scopes, unnumbered files and ambiguous chapter numbers survive.
  static void _deduplicateLanguages(
    List<_Candidate> selected,
    MediaTreeIndex index,
    List<String> scopes,
    Map<int, int> languages,
    Map<int, Set<int>> siblings,
  ) {
    if (!siblings.values.any((codes) => codes.length >= 2)) return;

    final editions = List<({int group, int language, String prefix})?>.filled(
      index.rows.length,
      null,
    );
    for (final row in index.rows) {
      final parent = row.parentIndex;
      final language = languages[row.index];
      editions[row.index] =
          language != null && siblings[parent ?? -1]!.length >= 2
          ? (group: parent ?? -1, language: language, prefix: scopes[row.index])
          : (parent == null ? null : editions[parent]);
    }
    final groups = <(int, String, String), List<_Candidate>>{};
    for (final item in selected) {
      final edition = editions[item.order];
      if (edition == null || item.node.duration <= 0) continue;
      final title = _widthFold(item.node.title);
      final chapter =
          (_chapter.firstMatch(title) ?? _prefixedChapter.firstMatch(title))
              ?.group(1);
      if (chapter == null) continue;
      final number = int.tryParse(chapter);
      if (number == null) continue;
      final relativeScope = item.scope.substring(edition.prefix.length);
      final key = (edition.group, relativeScope, number.toString());
      (groups[key] ??= []).add(item);
    }
    final removed = <int>{};
    for (final group in groups.values) {
      final codes = <int>{};
      // Two candidates with the same number in one language may be different
      // scenes/parts. Do not guess which one corresponds to another language.
      if (group.any((item) => !codes.add(editions[item.order]!.language))) {
        continue;
      }
      group.sort((a, b) => a.node.duration.compareTo(b.node.duration));
      final kept = <({int minDuration, int maxDuration, _Candidate winner})>[];
      for (final item in group) {
        final duration = item.node.duration;
        final duplicate = kept.indexWhere(
          (other) =>
              duration >= other.maxDuration - 1 &&
              duration <= other.minDuration + 1,
        );
        if (duplicate < 0) {
          kept.add((
            minDuration: duration,
            maxDuration: duration,
            winner: item,
          ));
          continue;
        }
        final bucket = kept[duplicate];
        final other = bucket.winner;
        final preferred =
            item.preferredTo(other) ||
            (!other.preferredTo(item) &&
                editions[item.order]!.language <
                    editions[other.order]!.language);
        removed.add(preferred ? other.order : item.order);
        kept[duplicate] = (
          minDuration: duration < bucket.minDuration
              ? duration
              : bucket.minDuration,
          maxDuration: duration > bucket.maxDuration
              ? duration
              : bucket.maxDuration,
          winner: preferred ? item : other,
        );
      }
    }
    selected.removeWhere((item) => removed.contains(item.order));
  }

  static int _rank(String name, int inherited) {
    final partial = _partialOff.hasMatch(name);
    // 射精SEなし must not be mistaken for complete SE removal.
    final withoutPartial = name.replaceAll(_partialOff, '');
    if (_fullOff.hasMatch(withoutPartial)) return 3;
    if (partial) {
      if (inherited == 3) return 3;
      return name.contains('bgm') &&
              !name.contains('環境') &&
              !name.contains('环境')
          ? 1
          : 2;
    }
    if (_reduced.hasMatch(name)) return inherited > 1 ? inherited : 1;
    if (_soundOn.hasMatch(name)) return 0;
    return inherited;
  }

  static String _stripVersions(String name) => name
      .replaceAll(_earlyEdition, '')
      .replaceAll(_regularEdition, '')
      .replaceAll(_reducedTag, '')
      .replaceAll(_partialTag, '')
      .replaceAll(_offTag, '')
      .replaceAll(_onTag, '')
      .replaceAll(_trailingSe, '')
      .replaceAll(_format, '');

  static String _folderKey(String name) {
    if (_numberOnly.hasMatch(_compact(name))) return _compact(name);
    var key = _stripVersions(name);
    // Some publishers distribute the main no-SE edition as a numbered bonus.
    if (name.contains('本編')) key = key.replaceAll(_bonusNumber, '');
    key = _compact(key.replaceAll(_quality, '').replaceFirst(_ordinal, ''));
    if (_editionHearts.hasMatch(key)) return '';
    if (key == 'main' || key == '差分') return '';
    return key;
  }

  static String _titleKey(String name, int bitDepth) {
    final suffix = _bitSuffix.firstMatch(name);
    if (suffix != null && suffix.group(1) == bitDepth.toString()) {
      name = name.substring(0, suffix.start);
    }
    return _compact(
      _stripVersions(
        name,
      ).replaceAll(_skipNote, '').replaceAll(_versionEnd, ''),
    );
  }

  static String _compact(String value) => value.replaceAll(_decoration, '');

  /// Match fullwidth SE/Latin/digits without changing display names or paths.
  static String _widthFold(String value) => String.fromCharCodes(
    value.runes.map(
      (c) => c >= 0xff01 && c <= 0xff5e ? c - 0xfee0 : (c == 0x3000 ? 32 : c),
    ),
  ).toLowerCase();
}

class _Candidate {
  final MediaNode node;
  final int rank;
  final bool early;
  final bool bonus;
  final int order;
  final String scope;
  final int bitDepth;
  final bool combined;
  const _Candidate(
    this.node,
    this.rank,
    this.early,
    this.bonus,
    this.order,
    this.scope,
    this.bitDepth,
    this.combined,
  );

  bool preferredTo(_Candidate other) {
    if (early != other.early) return early;
    if (rank != other.rank) return rank > other.rank;
    // Dictation caches source media: prefer small compressed audio over PCM.
    const formats = [
      'mp3',
      'aac',
      'm4a',
      'opus',
      'ogg',
      'wma',
      'flac',
      'ape',
      'wav',
      'aiff',
    ];
    int quality(MediaNode node) {
      final ext = node.title.split('.').last.toLowerCase();
      final index = formats.indexOf(ext);
      return index < 0 ? formats.length : index;
    }

    final formatOrder = quality(node).compareTo(quality(other.node));
    if (formatOrder != 0) return formatOrder < 0;
    return bitDepth > 0 && other.bitDepth > 0 && bitDepth < other.bitDepth;
  }
}
