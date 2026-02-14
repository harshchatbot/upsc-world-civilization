import 'dart:async';

import 'package:just_audio/just_audio.dart';

enum MixerTrack { ambient, fire }

class AudioMixer {
  final AudioPlayer _ambientPlayer = AudioPlayer();
  final AudioPlayer _firePlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  Timer? _ambientRamp;
  Timer? _fireRamp;
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    _ready = true;
    await _ambientPlayer.setLoopMode(LoopMode.one);
    await _firePlayer.setLoopMode(LoopMode.one);
    await _sfxPlayer.setLoopMode(LoopMode.off);
  }

  Future<void> playAmbient(
    String asset,
    double volume, {
    bool loop = true,
  }) async {
    if (asset.isEmpty) return;
    await init();
    try {
      await _ambientPlayer.setLoopMode(loop ? LoopMode.one : LoopMode.off);
      await _ambientPlayer.setAsset(_asAudioAsset(asset));
      await _ambientPlayer.setVolume(volume.clamp(0, 1));
      await _ambientPlayer.play();
    } catch (_) {
      // Keep app stable when asset is missing in MVP.
    }
  }

  Future<void> playFire(String asset, double volume, {bool loop = true}) async {
    if (asset.isEmpty) return;
    await init();
    try {
      await _firePlayer.setLoopMode(loop ? LoopMode.one : LoopMode.off);
      await _firePlayer.setAsset(_asAudioAsset(asset));
      await _firePlayer.setVolume(volume.clamp(0, 1));
      await _firePlayer.play();
    } catch (_) {
      // Keep app stable when asset is missing in MVP.
    }
  }

  Future<void> setVolume(MixerTrack track, double to, int durationMs) async {
    final double target = to.clamp(0, 1).toDouble();
    final AudioPlayer player = track == MixerTrack.ambient
        ? _ambientPlayer
        : _firePlayer;

    final Timer? oldTimer = track == MixerTrack.ambient
        ? _ambientRamp
        : _fireRamp;
    oldTimer?.cancel();

    final double from = player.volume;
    final int steps = durationMs <= 0 ? 1 : (durationMs / 50).ceil();
    int tick = 0;

    final Timer ramp = Timer.periodic(const Duration(milliseconds: 50), (
      Timer timer,
    ) {
      tick += 1;
      final double t = (tick / steps).clamp(0, 1);
      final double value = from + ((target - from) * t);
      player.setVolume(value);
      if (tick >= steps) {
        timer.cancel();
      }
    });

    if (track == MixerTrack.ambient) {
      _ambientRamp = ramp;
    } else {
      _fireRamp = ramp;
    }
  }

  Future<void> playSfx(String asset) async {
    if (asset.isEmpty) return;
    await init();
    try {
      await _sfxPlayer.setAsset(_asAudioAsset(asset));
      await _sfxPlayer.seek(Duration.zero);
      await _sfxPlayer.play();
    } catch (_) {
      // Keep app stable when asset is missing in MVP.
    }
  }

  Future<void> stopAll() async {
    _ambientRamp?.cancel();
    _fireRamp?.cancel();
    await _ambientPlayer.stop();
    await _firePlayer.stop();
    await _sfxPlayer.stop();
  }

  Future<void> dispose() async {
    _ambientRamp?.cancel();
    _fireRamp?.cancel();
    await _ambientPlayer.dispose();
    await _firePlayer.dispose();
    await _sfxPlayer.dispose();
  }

  String _asAudioAsset(String path) {
    return path.startsWith('assets/') ? path.replaceFirst('assets/', '') : path;
  }
}
