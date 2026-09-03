import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class GameFeedback {
  static final _player = AudioPlayer();
  static bool soundEnabled = true;
  static bool vibrationEnabled = true;

  static Future<void> hit() async {
    if (vibrationEnabled) HapticFeedback.selectionClick();
    if (soundEnabled) await _play('hit.wav');
  }
  static Future<void> pocket() async {
    if (vibrationEnabled) HapticFeedback.mediumImpact();
    if (soundEnabled) await _play('pocket.wav');
  }
  static Future<void> foul() async {
    if (vibrationEnabled) HapticFeedback.heavyImpact();
    if (soundEnabled) await _play('foul.wav');
  }
  static Future<void> _play(String name) async {
    try { await _player.stop(); await _player.play(AssetSource('audio/$name'), volume: .55); } catch (_) {}
  }
}
