import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kikoeta_app/data.dart';
import 'package:kikoeta_app/services/dictation_media_matcher.dart';
import 'package:kikoeta_app/services/media_tree.dart';

MediaNode file(String path, {int duration = 0, bool source = true}) =>
    MediaNode(
      title: path.split('/').last,
      type: 'audio',
      path: path,
      url: source ? 'https://example.invalid/audio' : null,
      duration: duration,
    );

MediaNode folder(String name, List<MediaNode> children) =>
    MediaNode(title: name, type: 'folder', path: name, children: children);

List<MediaNode> select(List<MediaNode> roots) =>
    DictationMediaMatcher.select(MediaTreeIndex(roots));

List<Map<String, dynamic>> samples() =>
    (jsonDecode(
              utf8.decode(
                gzip.decode(
                  File(
                    'checks/fixtures/dictation_media_samples.json.gz',
                  ).readAsBytesSync(),
                ),
              ),
            )
            as List)
        .cast<Map<String, dynamic>>();

List<MediaNode> tree(List raw, [String parent = '']) => raw.map((value) {
  final path = parent.isEmpty
      ? value['title'] as String
      : '$parent/${value['title']}';
  return MediaNode(
    title: value['title'],
    type: value['type'],
    path: path,
    duration: value['duration'] ?? 0,
    children: tree(value['children'] ?? [], path),
    url: value['type'] == 'folder' ? null : 'https://example.invalid/audio',
  );
}).toList();

void main() {
  test('duration tolerance cannot chain different recordings together', () {
    final roots = [
      folder('繁體中文', [file('繁體中文/01_第一段.mp3', duration: 60)]),
      folder('简体中文', [file('简体中文/01_第二段.mp3', duration: 61)]),
      folder('日本語', [file('日本語/01_第三段.mp3', duration: 62)]),
    ];
    final chosen = select(roots);
    expect(chosen.length, 2);
    expect(
      select(roots.reversed.toList()).map((n) => n.path).toSet(),
      chosen.map((n) => n.path).toSet(),
    );
  });

  test('RJ01709662 translated filenames select six Japanese MP3 tracks', () {
    final raw =
        jsonDecode(
              utf8.decode(
                gzip.decode(
                  File(
                    'checks/fixtures/RJ01709662-tracks.json.gz',
                  ).readAsBytesSync(),
                ),
              ),
            )
            as List;
    final chosen = select(tree(raw));
    expect(chosen.length, 6);
    expect(chosen.every((node) => node.path.startsWith('日本語/MP3/')), isTrue);
    expect(
      select(tree(raw.reversed.toList())).map((node) => node.path),
      chosen.map((node) => node.path),
    );
  });

  test(
    'language copies retain missing chapters and independent bonus audio',
    () {
      final chosen = select([
        folder('简体中文', [
          file('简体中文/01_中文.mp3', duration: 60),
          file('简体中文/02_日文版缺少.mp3', duration: 70),
          folder('特典', [file('简体中文/特典/01_独立内容.mp3', duration: 60)]),
        ]),
        folder('日本語', [file('日本語/Tr01_挨拶.mp3', duration: 60)]),
      ]);
      expect(chosen.map((node) => node.path), [
        '简体中文/02_日文版缺少.mp3',
        '简体中文/特典/01_独立内容.mp3',
        '日本語/Tr01_挨拶.mp3',
      ]);
    },
  );

  test(
    'language metadata alone cannot collapse different or ambiguous tracks',
    () {
      expect(
        select([
          folder('简体中文', [
            file('简体中文/01_中文.mp3', duration: 60),
            file('简体中文/02_不同内容.mp3', duration: 70),
            file('简体中文/03_分支A.mp3', duration: 80),
            file('简体中文/03_分支B.mp3', duration: 80),
            file('简体中文/未编号.mp3', duration: 90),
          ]),
          folder('日本語', [
            file('日本語/01_挨拶.mp3', duration: 0),
            file('日本語/02_別の内容.mp3', duration: 75),
            file('日本語/03_挨拶.mp3', duration: 80),
            file('日本語/番号なし.mp3', duration: 90),
          ]),
        ]).length,
        9,
      );
    },
  );

  test(
    'language matching keeps SE rank then compressed format preferences',
    () {
      expect(
        select([
          folder('简体中文', [file('简体中文/01_问候_no-se.wav', duration: 60)]),
          folder('日本語', [file('日本語/01_挨拶.mp3', duration: 60)]),
        ]).single.path,
        '简体中文/01_问候_no-se.wav',
      );
      expect(
        select([
          folder('简体中文', [file('简体中文/01_问候.mp3', duration: 60)]),
          folder('日本語', [file('日本語/01_挨拶.wav', duration: 60)]),
        ]).single.path,
        '简体中文/01_问候.mp3',
      );
    },
  );

  test(
    'language matching preserves voice scopes and separate work parents',
    () {
      final editions = [
        folder('简体中文', [
          folder('声優A', [file('01_中文.mp3', duration: 60)]),
        ]),
        folder('日本語', [
          folder('声優B', [file('01_挨拶.mp3', duration: 60)]),
        ]),
      ];
      expect(select(editions).length, 2);
      expect(
        select([
          folder('作品A', editions),
          folder('作品B', [
            folder('日本語', [file('01_挨拶.mp3', duration: 60)]),
          ]),
        ]).length,
        3,
      );
    },
  );

  test(
    'whole-work per-track matching keeps extras and incomplete editions',
    () {
      final chosen = select([
        folder('mp3', [file('mp3/01.mp3'), file('mp3/02.mp3')]),
        folder('WAV(SEなし)', [file('WAV(SEなし)/01.wav')]),
        folder('特典音声', [file('特典音声/01.wav', duration: 3)]),
      ]);
      expect(chosen.map((n) => n.path), [
        'mp3/02.mp3',
        'WAV(SEなし)/01.wav',
        '特典音声/01.wav',
      ]);
    },
  );

  test('fullwidth SE and filename suffixes match across nested formats', () {
    expect(
      select([
        folder('1.本編-ＳＥあり', [
          folder('wav-SEあり', [file('01_挨拶-wav-SEあり.wav')]),
        ]),
        folder('2.本編-SEなし', [
          folder('mp3-SEなし', [file('01_挨拶-mp3-SEなし.mp3')]),
        ]),
      ]).single.title,
      '01_挨拶-mp3-SEなし.mp3',
    );
  });

  test('main edition packaged as bonus replaces the regular edition', () {
    expect(
      select([
        file('A-1_ご挨拶.mp3'),
        folder('【特典③】本編SEなしver', [file('A-1_ご挨拶.mp3')]),
      ]).length,
      1,
    );
  });

  test('complete SE removal outranks partial removal and file format', () {
    expect(
      select([
        folder('WAV', [file('01_挨拶.wav')]),
        folder('射精SEなし', [file('01_挨拶_射精SEなし.wav')]),
        folder('MP3SEなし', [file('01_挨拶_SEなし.mp3')]),
      ]).single.title,
      '01_挨拶_SEなし.mp3',
    );
  });

  test('partial removal is used when a fully clean edition is absent', () {
    expect(
      select([
        file('01_挨拶.wav'),
        folder('時計の音なしver', [file('01_挨拶（時計なし）.wav')]),
      ]).single.title,
      '01_挨拶（時計なし）.wav',
    );
  });

  test('SE substrings in English names do not imply sound effects', () {
    expect(select([file('house.mp3'), file('01_no_cut_scene.wav')]).length, 2);
  });

  test('different voices, discs, counts and bonus scenes retain identity', () {
    expect(
      select([
        folder('Disc1', [file('Disc1/01.wav')]),
        folder('Disc2', [file('Disc2/01.wav')]),
        folder('1', [file('1/01.wav')]),
        folder('2', [file('2/01.wav')]),
        folder('声優A', [file('声優A/01.wav')]),
        folder('声優B', [file('声優B/01.wav')]),
        folder('カウント有り', [file('カウント有り/01.wav')]),
        file('01.wav'),
      ]).length,
      8,
    );
  });

  test('self PR in a scene title is not a promotional asset', () {
    expect(select([file('02_エロかわ自己PR♡.wav')]).length, 1);
  });

  test('no-se variants outrank se_low, which outranks the regular edition', () {
    for (final off in ['no-se', 'no_se', 'NO SE']) {
      final regular = folder('SE', [file('01_挨拶_SE.wav')]);
      final reduced = folder('se_low', [file('01_挨拶_se_low.wav')]);
      expect(select([regular, reduced]).single.title, '01_挨拶_se_low.wav');
      expect(
        select([
          regular,
          reduced,
          folder(off, [file('01_挨拶_$off.mp3')]),
        ]).single.title,
        '01_挨拶_$off.mp3',
      );
    }
    for (final low in ['SE_LOW', 'se-low', 'low_se', 'se reduced']) {
      expect(
        select([file('01_挨拶.wav'), file('01_挨拶_$low.wav')]).single.title,
        '01_挨拶_$low.wav',
      );
    }
  });

  test('compound SE labels and edition suffixes normalize together', () {
    expect(
      select([
        folder('SE効果音あり', [file('01_挨拶.wav')]),
        folder('SE効果音なし', [file('01_SE無し版 挨拶.wav')]),
      ]).single.title,
      '01_SE無し版 挨拶.wav',
    );
  });

  test('bit-depth labels match only inside explicitly labeled editions', () {
    expect(
      select([
        folder('16bit_通常WAV', [file('01_挨拶_16.wav')]),
        folder('24bit_ハイレゾWAV', [file('01_挨拶_24.wav')]),
        folder('MP3', [file('01_挨拶.mp3')]),
      ]).single.title,
      '01_挨拶.mp3',
    );
    expect(select([file('挨拶_16.wav'), file('挨拶_24.wav')]).length, 2);
    expect(
      select([
        folder('16bit_WAV', [file('01_挨拶_16.wav')]),
        folder('24bit_WAV', [file('01_挨拶_24.wav')]),
      ]).single.title,
      '01_挨拶_16.wav',
    );
  });

  test('compressed formats precede lossless only within the same SE rank', () {
    expect(
      select([
        file('01_挨拶.wav'),
        file('01_挨拶.flac'),
        file('01_挨拶.aac'),
        file('01_挨拶.mp3'),
      ]).single.title,
      '01_挨拶.mp3',
    );
    expect(
      select([file('01_挨拶.wav'), file('01_挨拶.aac')]).single.title,
      '01_挨拶.aac',
    );
    expect(
      select([file('01_挨拶.mp3'), file('01_挨拶_no-se.wav')]).single.title,
      '01_挨拶_no-se.wav',
    );
  });

  test('effect-only edition labels still identify one full-work recording', () {
    expect(
      select([
        file('効果音有り_BGM有り.wav'),
        file('効果音有り_BGM無し.wav'),
        file('効果音無し_BGM無し.wav'),
      ]).single.title,
      '効果音無し_BGM無し.wav',
    );
  });

  test('promotional clips and BGM omitted, spoken bonus PR talk retained', () {
    expect(
      select([
        folder('サンプル', [file('サンプル/01.wav')]),
        folder('作品BGM', [file('作品BGM/01.wav')]),
        folder('PR', [file('PR/野上菜月PRtalk.wav')]),
        file('本編.wav'),
        file('cover.jpg'),
      ]).map((n) => n.title),
      ['野上菜月PRtalk.wav', '本編.wav'],
    );
  });

  test('missing sources cannot displace a usable regular edition', () {
    expect(
      select([
        file('01.wav'),
        folder('SEなし', [file('SEなし/01.wav', source: false)]),
      ]).single.path,
      '01.wav',
    );
    expect(select([]), isEmpty);
  });

  test('named full track removed only when chapters cover its duration', () {
    expect(
      select([
        file('01.wav', duration: 60),
        file('02.wav', duration: 40),
        file('全パート通し音声.wav', duration: 101),
      ]).length,
      2,
    );
    expect(
      select([
        file('01.wav', duration: 60),
        file('02.wav', duration: 40),
        file('全パート通し音声.wav', duration: 150),
      ]).length,
      3,
    );
  });

  test(
    'format-only names and unknown editions are retained conservatively',
    () {
      expect(select([file('MP3.mp3'), file('WAV.wav')]).length, 2);
      expect(
        select([
          folder('微調整ver', [file('微調整ver/01.wav')]),
          folder('通常ver', [file('通常ver/01.wav')]),
        ]).length,
        2,
      );
    },
  );

  test('100 real random-work trees replay with audited edge cases', () {
    final works = samples();
    expect(works.length, 100);
    expect(works.map((w) => w['id']).toSet().length, 100);
    final output = <Map<String, dynamic>>[];
    final byId = <int, List<MediaNode>>{};
    for (final work in works) {
      final index = MediaTreeIndex(tree(work['tree']));
      final chosen = DictationMediaMatcher.select(index);
      byId[work['id']] = chosen;
      expect(chosen, isNotEmpty, reason: 'RJ${work['id']}');
      expect(chosen.map((n) => n.path).toSet().length, chosen.length);
      expect(chosen.every((n) => index.files.contains(n)), isTrue);
      output.add({
        'id': work['id'],
        'files': index.files.length,
        'selected': chosen.map((n) => n.path).toList(),
      });
    }
    expect(byId[1277504]!.length, 7); // Six clean tracks plus free talk.
    expect(byId[1003834]!.length, 4);
    expect(byId[1344348]!.length, 5); // Four formats/editions, no samples/CM.
    expect(byId[406695]!.length, 7); // No-SE main packaged as a bonus.
    expect(byId[1181073]!.length, 9); // Eight clean tracks plus PR talk.
    expect(byId[1209877]!.length, 11); // Nine clean tracks plus two EX tracks.
    expect(byId[1393120]!.length, 5); // NOSE, regular and partial SE editions.
    expect(byId[1396305]!.length, 5); // Prefix markers in otherwise flat tree.
    expect(byId[1115505]!.length, 9); // Eight main tracks plus bonus audio.
    expect(byId[315583]!.length, 6); // Video-only work remains supported.
    expect(byId[1297270]!.length, 5); // Compound SE効果音 labels.
    expect(byId[362833]!.length, 5); // Filename SE無し版 plus independent talk.
    expect(byId[277746]!.length, 4); // 16-bit/24-bit/MP3 editions.
    expect(byId[237230]!.length, 3); // Hi-res _24 filename suffixes.
    expect(byId[350413]!.length, 1); // Edition labels alone identify content.
    expect(byId[1562844]!.length, 4); // 自己PR is a legitimate scene title.
    const auditPath = String.fromEnvironment('DICTATION_AUDIT_OUTPUT');
    if (auditPath.isNotEmpty) {
      File(
        auditPath,
      ).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(output));
      final timings = <Map<String, dynamic>>[];
      for (final work in works) {
        final index = MediaTreeIndex(tree(work['tree']));
        final micros = <int>[];
        for (var repeat = 0; repeat < 7; repeat++) {
          final watch = Stopwatch()..start();
          DictationMediaMatcher.select(index);
          watch.stop();
          micros.add(watch.elapsedMicroseconds);
        }
        micros.sort();
        timings.add({
          'id': work['id'],
          'nodes': index.rows.length,
          'medianMicros': micros[3],
        });
      }
      File(
        '$auditPath.performance.json',
      ).writeAsStringSync(jsonEncode(timings));
    }
  });

  test(
    'large real tree runs in compute and yields the UI event loop',
    () async {
      final large = samples().singleWhere((work) => work['id'] == 1212141);
      final index = MediaTreeIndex(tree(large['tree']));
      var yielded = false;
      Timer.run(() => yielded = true);
      final chosen = await DictationMediaMatcher.selectForDictation(index);
      expect(yielded, isTrue);
      expect(chosen.map((n) => n.path), select(index.roots).map((n) => n.path));
    },
  );
}
