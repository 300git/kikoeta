import 'package:flutter_test/flutter_test.dart';
import 'package:kikoeta_app/services/audio_effects.dart';

void main() {
  test('flat or disabled EQ preserves each selected channel mode', () {
    for (final mode in AudioChannelMode.values) {
      final withDisabledEq = buildAudioFilterChain(
        equalizerEnabled: false,
        gains: List.filled(10, 8),
        channelMode: mode,
      );
      final withFlatEq = buildAudioFilterChain(
        equalizerEnabled: true,
        gains: List.filled(10, 0),
        channelMode: mode,
      );
      expect(withFlatEq, withDisabledEq);
      if (mode == AudioChannelMode.stereo) {
        expect(withDisabledEq, isEmpty);
      } else {
        expect(withDisabledEq, contains('format=channels=stereo'));
      }
    }
  });

  test('EQ gains survive switching between swap, mono, and stereo', () {
    final gains = <double>[20, -20, 3, 0, 0, 0, 0, 0, 0, 0];
    String chain(AudioChannelMode mode) => buildAudioFilterChain(
      equalizerEnabled: true,
      gains: gains,
      channelMode: mode,
    );
    final eq = chain(AudioChannelMode.stereo);
    expect(eq, contains('equalizer=f=31:t=q:w=1.0:g=12.0'));
    expect(eq, contains('equalizer=f=62:t=q:w=1.0:g=-12.0'));
    expect(chain(AudioChannelMode.swap), startsWith('$eq,'));
    expect(chain(AudioChannelMode.mono), startsWith('$eq,'));
    expect(chain(AudioChannelMode.swap), contains('out-channels=fr-fl'));
    expect(
      chain(AudioChannelMode.mono),
      contains('format=channels=mono,format=channels=stereo'),
    );
  });

  test('only the five supported playback rates are accepted', () {
    expect(playbackRatePresets, [0.5, 1, 1.5, 2, 3]);
    for (final rate in playbackRatePresets) {
      expect(normalizePlaybackRate(rate), rate);
    }
    for (final rate in [double.nan, double.infinity, -1.0, 0.0, 0.75, 4.0]) {
      expect(normalizePlaybackRate(rate), 1.0);
    }
  });
}
