// lib/core/utils/sound_service.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundService {
  final AudioPlayer _player = AudioPlayer();

  SoundService() {
    _player.setReleaseMode(ReleaseMode.stop);
  }

  Future<void> tocarCampanita() async {
    try {
      if (_player.state == PlayerState.playing) {
        await _player.stop();
      }
      // Se agrega PlayerMode.lowLatency para evitar conflictos de hilos en Windows
      await _player.play(
        AssetSource('campanita.mp3'), 
        volume: 1.0, 
        mode: PlayerMode.lowLatency,
      );
    } catch (e) {
      debugPrint('Error al reproducir campanita: $e');
    }
  }
}