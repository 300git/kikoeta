/// Exclusive playback routing modes. Mono sends the same mix to both ears.
enum AudioChannelMode { stereo, swap, mono }

const playbackRatePresets = <double>[0.5, 1.0, 1.5, 2.0, 3.0];

double normalizePlaybackRate(double value) =>
    playbackRatePresets.contains(value) ? value : 1.0;

const _eqHz = ['31', '62', '125', '250', '500', '1k', '2k', '4k', '8k', '16k'];

/// Builds the shared mpv af chain so changing EQ cannot remove channel routing.
/// mpv's native format filter works even when bundled FFmpeg omits pan/aformat.
String buildAudioFilterChain({
  required bool equalizerEnabled,
  required List<double> gains,
  required AudioChannelMode channelMode,
}) {
  final filters = <String>[];
  if (equalizerEnabled && gains.any((gain) => gain.abs() >= 0.05)) {
    filters.addAll(
      List.generate(_eqHz.length, (index) {
        final gain = index < gains.length && gains[index].isFinite
            ? gains[index].clamp(-12, 12).toStringAsFixed(1)
            : '0.0';
        return 'equalizer=f=${_eqHz[index]}:t=q:w=1.0:g=$gain';
      }),
    );
  }
  // Keep EQ before routing: FFmpeg's EQ accepts the decoded channel layout,
  // whereas reversed labels can require aresample, omitted by bundled builds.
  switch (channelMode) {
    case AudioChannelMode.stereo:
      break;
    case AudioChannelMode.swap:
      // Convert mono/surround input first, then relabel the existing samples.
      // mpv remaps this reversed layout back to the output device's layout.
      filters.add('format=channels=stereo:out-channels=fr-fl');
    case AudioChannelMode.mono:
      // The default stereo->mono->stereo remix gives both ears (L + R) / 2.
      filters.add('format=channels=mono');
      filters.add('format=channels=stereo');
  }
  return filters.join(',');
}
