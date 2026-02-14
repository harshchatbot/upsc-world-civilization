import 'package:just_audio/just_audio.dart';

/// Minimal 2-track looping mixer for ambient + music beds.
class AudioMixer {
  final AudioPlayer _ambient = AudioPlayer();
  final AudioPlayer _music = AudioPlayer();

  Future<void> loadAndPlay({
    required String ambientAsset,
    required String musicAsset,
    double ambientVolume = 0.5,
    double musicVolume = 0.0,
  }) async {
    if (ambientAsset.isEmpty && musicAsset.isEmpty) {
      return;
    }

    try {
      if (ambientAsset.isNotEmpty) {
        await _ambient.setLoopMode(LoopMode.one);
        await _ambient.setAsset(ambientAsset.replaceFirst('assets/', ''));
        await _ambient.setVolume(ambientVolume);
        await _ambient.play();
      }
      if (musicAsset.isNotEmpty) {
        await _music.setLoopMode(LoopMode.one);
        await _music.setAsset(musicAsset.replaceFirst('assets/', ''));
        await _music.setVolume(musicVolume);
        await _music.play();
      }
    } catch (_) {
      // Audio assets are optional in MVP.
    }
  }

  /// value = 0 keeps ambient louder, value = 1 pushes music up.
  Future<void> crossfade(double value) async {
    final double t = value.clamp(0, 1);
    await _ambient.setVolume(1 - t);
    await _music.setVolume(t);
  }

  Future<void> stop() async {
    await _ambient.stop();
    await _music.stop();
  }

  Future<void> dispose() async {
    await _ambient.dispose();
    await _music.dispose();
  }
}
