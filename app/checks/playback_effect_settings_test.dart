import 'package:flutter_test/flutter_test.dart';
import 'package:kikoeta_app/data.dart';
import 'package:kikoeta_app/services/audio_effects.dart';

void main() {
  test('speed starts disabled and only enabled presets are persisted', () {
    final saved = <String, String>{};
    final app = AppState(
      playbackSettingsWriter: (key, value) => saved[key] = value,
    );
    addTearDown(app.dispose);

    expect(app.playbackSpeedEnabled, isFalse);
    expect(app.playbackRate, 1.0);
    app.setPlaybackRate(2.0);
    expect(saved, isEmpty);
    expect(app.playbackRate, 1.0);

    app.setPlaybackSpeedEnabled(true);
    expect(saved['playback_speed_enabled'], '1');
    for (final rate in playbackRatePresets) {
      app.setPlaybackRate(rate);
      expect(app.playbackRate, rate);
      expect(saved['playback_rate'], '$rate');
    }
    for (final rate in [0.25, 1.25, 4.0, double.nan, double.infinity]) {
      app.setPlaybackRate(rate);
      expect(app.playbackRate, 3.0);
      expect(saved['playback_rate'], '3.0');
    }

    app.setPlaybackSpeedEnabled(false);
    expect(app.playbackRate, 1.0);
    expect(saved['playback_speed_enabled'], '0');
    expect(saved['playback_rate'], '1.0');
  });

  test('channel selection persists independently of the speed switch', () {
    final saved = <String, String>{};
    final app = AppState(
      playbackSettingsWriter: (key, value) => saved[key] = value,
    );
    addTearDown(app.dispose);
    var notifications = 0;
    app.addListener(() => notifications++);

    expect(app.audioChannelMode, AudioChannelMode.stereo);
    app.setAudioChannelMode(AudioChannelMode.swap);
    expect(saved['audio_channel_mode'], 'swap');
    expect(notifications, 1);
    app.setAudioChannelMode(AudioChannelMode.swap);
    expect(notifications, 1);
    app.setAudioChannelMode(AudioChannelMode.mono);
    expect(saved['audio_channel_mode'], 'mono');
    app.setPlaybackSpeedEnabled(true);
    app.setPlaybackRate(2.0);
    app.setPlaybackSpeedEnabled(false);
    expect(app.audioChannelMode, AudioChannelMode.mono);
    app.setAudioChannelMode(AudioChannelMode.stereo);
    expect(saved['audio_channel_mode'], 'stereo');
  });
}
