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

List<Map<String, dynamic>> samples([
  String fixture = 'dictation_media_samples.json.gz',
]) =>
    (jsonDecode(
              utf8.decode(
                gzip.decode(File('checks/fixtures/$fixture').readAsBytesSync()),
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
    duration: (value['duration'] as num?)?.toInt() ?? 0,
    children: tree(value['children'] ?? [], path),
    url: value['type'] == 'folder' ? null : 'https://example.invalid/audio',
  );
}).toList();

void main() {
  test(
    'RJ01627675 selects 25 chapters from 39 overlapping perspective mixes',
    () {
      final raw =
          jsonDecode(
                utf8.decode(
                  gzip.decode(
                    File(
                      'checks/fixtures/RJ01627675-tracks.json.gz',
                    ).readAsBytesSync(),
                  ),
                ),
              )
              as List;
      final chosen = select(tree(raw));
      expect(raw.where((n) => n['type'] == 'audio').length, 39);
      expect(chosen.length, 25);
      expect(chosen.map((n) => n.path).toSet().length, 25);
      for (var chapter = 1; chapter <= 25; chapter++) {
        expect(
          chosen
              .where((n) => RegExp('^#$chapter(?:A)?\\.').hasMatch(n.title))
              .length,
          1,
          reason: 'Exactly one transcript source for chapter $chapter',
        );
      }
    },
  );

  test(
    'perspective mixes use existing format and SE preferences, then A first',
    () {
      expect(
        select([
          file('#06B.二人同時に優しく耳元でお話しsideB.wav', duration: 60),
          file('#6A.二人同時に優しく耳元でお話しsideA.mp3', duration: 61),
          file('#6C.二人同時に優しく耳元でお話しsideC.wav', duration: 60),
        ]).map((n) => n.title),
        ['#6A.二人同時に優しく耳元でお話しsideA.mp3'],
      );
      expect(
        select([
          file('#6A.二人同時に優しく耳元でお話しsideA.mp3', duration: 60),
          file('#6B.二人同時に優しく耳元でお話しsideB_SEなし.wav', duration: 60),
        ]).map((n) => n.title),
        ['#6B.二人同時に優しく耳元でお話しsideB_SEなし.wav'],
      );
      expect(
        select([
          file('#6B.二人同時に優しく耳元でお話しsideB.wav', duration: 60),
          file('#6A.二人同時に優しく耳元でお話しsideA.wav', duration: 60),
        ]).single.title,
        startsWith('#6A.'),
      );
    },
  );

  test('lettered chapters need all perspective-equivalence conditions', () {
    final cases = <String, List<MediaNode>>{
      'unrelated titles with identical durations': [
        file('#6A.同時に朝の散歩へ出かける.wav', duration: 60),
        file('#6B.同時に夜の図書館で読書する.wav', duration: 60),
      ],
      'no perspective label': [
        file('#6A.彼女との楽しい一日の結末A.wav', duration: 60),
        file('#6B.彼女との楽しい一日の結末B.wav', duration: 60),
      ],
      'short ambiguous titles': [
        file('#6A.同時A.wav', duration: 60),
        file('#6B.同時B.wav', duration: 60),
      ],
      'missing duration': [
        file('#6A.二人同時に優しく耳元でお話しsideA.wav'),
        file('#6B.二人同時に優しく耳元でお話しsideB.wav'),
      ],
      'duration tolerance does not chain': [
        file('#6A.二人同時に優しく耳元でお話しsideA.wav', duration: 60),
        file('#6B.二人同時に優しく耳元でお話しsideB.wav', duration: 61),
        file('#6C.二人同時に優しく耳元でお話しsideC.wav', duration: 62),
      ],
      'ambiguous duplicate letters': [
        file('#6A.二人同時に優しく耳元でお話しsideA.wav', duration: 60),
        file('#06A.二人同時に優しく耳元でお話しsideA.wav', duration: 60),
        file('#6B.二人同時に優しく耳元でお話しsideB.wav', duration: 60),
      ],
      'different chapter numbers': [
        file('#6A.二人同時に優しく耳元でお話しsideA.wav', duration: 60),
        file('#7B.二人同時に優しく耳元でお話しsideB.wav', duration: 60),
      ],
    };
    for (final entry in cases.entries) {
      expect(select(entry.value).length, entry.value.length, reason: entry.key);
    }
    expect(
      select([
        folder('声優一', [file('声優一/#6A.二人同時に優しく耳元でお話しsideA.wav', duration: 60)]),
        folder('声優二', [file('声優二/#6B.二人同時に優しく耳元でお話しsideB.wav', duration: 60)]),
      ]).length,
      2,
    );
  });

  test('combined-track coverage counts each perspective scene only once', () {
    final chosen = select([
      file('#1A.二人同時に優しく耳元でお話しsideA.wav', duration: 60),
      file('#1B.二人同時に優しく耳元でお話しsideB.wav', duration: 60),
      file('#2.おやすみ.wav', duration: 20),
      file('全パート.wav', duration: 80),
    ]);
    expect(chosen.map((n) => n.title), [
      '#1A.二人同時に優しく耳元でお話しsideA.wav',
      '#2.おやすみ.wav',
    ]);
  });

  test(
    'hash-prefixed language chapters match each lettered branch separately',
    () {
      final chosen = select([
        folder('日本語', [
          file('日本語/#01.挨拶.mp3', duration: 30),
          file('日本語/#6A.会話A.mp3', duration: 60),
          file('日本語/#6B.会話B.mp3', duration: 60),
        ]),
        folder('简体中文', [
          file('简体中文/＃１.问候.wav', duration: 30),
          file('简体中文/#06A.对话甲.wav', duration: 60),
          file('简体中文/#06B.对话乙.wav', duration: 60),
          file('简体中文/#06C.独立分支.wav', duration: 60),
        ]),
      ]);
      expect(chosen.map((n) => n.path), [
        '日本語/#01.挨拶.mp3',
        '日本語/#6A.会話A.mp3',
        '日本語/#6B.会話B.mp3',
        '简体中文/#06C.独立分支.wav',
      ]);
    },
  );

  test(
    'only audio files enter matching, including early editions and bonuses',
    () {
      final formats = [
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
        'mka',
      ];
      final audio = [
        for (var i = 0; i < formats.length; i++)
          file('${i + 1}_音声.${formats[i].toUpperCase()}'),
      ];
      final video = [
        for (final ext in [
          'mp4',
          'webm',
          'mkv',
          'avi',
          'mov',
          'wmv',
          'flv',
          'ts',
          'm4v',
        ])
          file('映像_$ext.$ext'),
      ];
      final chosen = select([
        ...audio,
        folder('早期購入版 SEなし 特典', [...video, file('01_挨拶.mp4')]),
        folder('通常版', [file('01_挨拶.mp3')]),
        file('音声.mp3.vtt'),
        file('cover.jpg'),
      ]);
      expect(chosen.map((n) => n.title), [
        ...audio.map((n) => n.title),
        '01_挨拶.mp3',
      ]);
      expect(select(video), isEmpty);
    },
  );

  test('RJ01716786 keeps nine clean main tracks and seven spoken bonuses', () {
    final raw =
        jsonDecode(
              utf8.decode(
                gzip.decode(
                  File(
                    'checks/fixtures/RJ01716786-tracks.json.gz',
                  ).readAsBytesSync(),
                ),
              ),
            )
            as List;
    final chosen = select(tree(raw));
    expect(chosen.length, 16);
    expect(chosen.where((n) => n.path.startsWith('本編/mp3/mp3SEなし/')).length, 9);
    expect(chosen.where((n) => n.path.startsWith('特典/mp3/')).length, 7);
    expect(chosen.any((n) => n.path.startsWith('とぉっても素敵な音源')), isFalse);
    expect(chosen.any((n) => n.title.contains('フリートーク')), isTrue);
    expect(chosen.every((n) => n.title.endsWith('.mp3')), isTrue);
  });

  test(
    'sound-material actions are excluded without swallowing voiced scenes',
    () {
      expect(
        select([
          folder('音源素材', [
            file('フェラ_役A.mp3'),
            file('耳舐め_役B_右.wav'),
            file('優しい鼻息耳舐め_役B_両耳.mp3'),
            file('耳舐め_役B_フリートーク.mp3'),
            file('耳舐め_役B_セリフあり.mp3'),
            file('01_フェラ_正片.mp3'),
            folder('特典囁きボイス', [file('耳舐め_役B_右.mp3'), file('EX05_耳舐め1.wav')]),
          ]),
          folder('特典', [file('耳舐め 出せ.wav'), file('耳かき_おやすみ.mp3')]),
          file('耳舐め_声優B.mp3'),
        ]).map((n) => n.title),
        [
          '耳舐め_役B_フリートーク.mp3',
          '耳舐め_役B_セリフあり.mp3',
          '01_フェラ_正片.mp3',
          '耳舐め_役B_右.mp3',
          'EX05_耳舐め1.wav',
          '耳舐め 出せ.wav',
          '耳かき_おやすみ.mp3',
          '耳舐め_声優B.mp3',
        ],
      );
    },
  );

  test('RJ01680559 chooses eight early-purchase MP3s including its bonus', () {
    final raw =
        jsonDecode(
              utf8.decode(
                gzip.decode(
                  File(
                    'checks/fixtures/RJ01680559-tracks.json.gz',
                  ).readAsBytesSync(),
                ),
              ),
            )
            as List;
    final chosen = select(tree(raw));
    expect(chosen.length, 8);
    expect(
      chosen.every(
        (node) =>
            node.path.startsWith('♡早期購入版♡/') && node.title.endsWith('.mp3'),
      ),
      isTrue,
    );
    expect(chosen.where((node) => node.title.startsWith('特典トラック')).length, 1);
    expect(
      select(tree(raw.reversed.toList())).map((n) => n.path).toSet(),
      chosen.map((n) => n.path).toSet(),
    );
  });

  test('early editions precede regular editions and fill missing chapters', () {
    final chosen = select([
      folder('♥通常版♥', [file('通常版/01_挨拶_no-se.mp3'), file('通常版/02_追加.mp3')]),
      folder('♡早期購入版♡', [
        file('早期版/01_挨拶.wav'),
        folder('特典', [file('早期版/特典/01_独立内容.mp3')]),
      ]),
    ]);
    expect(chosen.map((n) => n.path), [
      '通常版/02_追加.mp3',
      '早期版/01_挨拶.wav',
      '早期版/特典/01_独立内容.mp3',
    ]);
  });

  test('filename edition labels and first-print bonuses retain identity', () {
    for (final early in ['早期版', '初回限定版', '初期購入版', 'early edition']) {
      expect(
        select([file('01_挨拶_通常版.mp3'), file('01_挨拶_$early.mp3')]).single.title,
        '01_挨拶_$early.mp3',
      );
    }
    expect(
      select([
        folder('初期購買特典', [file('01_独立内容.mp3')]),
        file('01_独立内容.mp3'),
      ]).length,
      2,
    );
  });

  test(
    'speechless labels and pure sleep sounds are excluded before ranking',
    () {
      final chosen = select([
        folder('无人声助眠赠品', [file('01_雨声.mp3'), file('Free Talk.wav')]),
        folder('ボイスなし', [file('01.wav')]),
        file('特典_no_voice.mp3'),
        file('EX02_寝息ループ.wav'),
        file('09.寝息.mp3'),
        file('01 吐息1.wav'),
        file('EX05_耳舐め1.wav'),
        file('EX01_耳かきのみ.mp3'),
        file('01_環境音のみ.wav'),
        file('01_お嬢様の耳かき.mp3'),
        file('1 耳かき.mp3'),
        file('04 ぱふぱふ囁き(無声音).wav'),
        file('09 耳舐め 出せ.wav'),
        file('おやすみボイス.wav'),
        file('睡眠用囁き.mp3'),
      ]);
      expect(chosen.map((n) => n.title), [
        '01_お嬢様の耳かき.mp3',
        '1 耳かき.mp3',
        '04 ぱふぱふ囁き(無声音).wav',
        '09 耳舐め 出せ.wav',
        'おやすみボイス.wav',
        '睡眠用囁き.mp3',
      ]);
    },
  );

  test(
    'fresh 100 random-work trees replay separately from the original set',
    () {
      final works = samples('dictation_media_samples_20261024.json.gz');
      expect(works.length, 100);
      expect(works.map((w) => w['id']).toSet().length, 100);
      expect(
        works
            .map((w) => w['id'])
            .toSet()
            .intersection(samples().map((w) => w['id']).toSet()),
        isEmpty,
      );
      final output = <Map<String, dynamic>>[];
      final byId = <int, List<MediaNode>>{};
      for (final work in works) {
        final index = MediaTreeIndex(tree(work['tree']));
        final chosen = DictationMediaMatcher.select(index);
        byId[work['id']] = chosen;
        expect(chosen.map((n) => n.path).toSet().length, chosen.length);
        expect(chosen.every((n) => index.files.contains(n)), isTrue);
        DictationMediaMatcher.select(index); // Warm up before timing.
        final timings = <int>[];
        for (var i = 0; i < 7; i++) {
          final watch = Stopwatch()..start();
          DictationMediaMatcher.select(index);
          watch.stop();
          timings.add(watch.elapsedMicroseconds);
        }
        timings.sort();
        output.add({
          'id': work['id'],
          'nodes': index.rows.length,
          'files': index.files.length,
          'medianMicros': timings[3],
          'selected': chosen.map((n) => n.path).toList(),
        });
      }
      expect(byId[1629016]!.length, 13); // Separately labeled breathing track.
      expect(byId[280509]!.length, 8); // Excludes only 09.寝息.
      expect(byId[1206897]!.length, 29); // Pure-sound clips and video excluded.
      expect(byId[1206897]!.any((n) => n.title.contains('無声音')), isTrue);
      expect(byId[1206897]!.any((n) => n.title.contains('耳舐め 出せ')), isTrue);
      expect(byId[319990]!.length, 12); // Main ear-cleaning scene survives.
      expect(byId[1415066]!.any((n) => n.path.contains('初期購買特典')), isFalse);
      expect(
        byId[1415066]!.length,
        11,
      ); // Video bonus excluded; audio retained.
      const auditPath = String.fromEnvironment('DICTATION_EARLY_AUDIT_OUTPUT');
      if (auditPath.isNotEmpty) {
        File(
          auditPath,
        ).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(output));
      }
    },
  );

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
      expect(
        chosen,
        work['id'] == 315583 ? isEmpty : isNotEmpty,
        reason: 'RJ${work['id']}',
      );
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
    expect(
      byId[1209877]!.length,
      9,
    ); // Excludes ear-cleaning-only and breathing loops.
    expect(byId[1393120]!.length, 5); // NOSE, regular and partial SE editions.
    expect(byId[1396305]!.length, 5); // Prefix markers in otherwise flat tree.
    expect(byId[1115505]!.length, 9); // Eight main tracks plus bonus audio.
    expect(byId[315583], isEmpty); // Video-only work has no audio candidates.
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
