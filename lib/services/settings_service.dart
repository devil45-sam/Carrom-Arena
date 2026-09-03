import 'package:shared_preferences/shared_preferences.dart';
import 'game_feedback.dart';

class SettingsService {
  static const _sound = 'sound';
  static const _music = 'music';
  static const _vibration = 'vibration';
  static const _aimGuide = 'aimGuide';
  static const _ultra = 'ultra';
  static Future<Map<String, bool>> load() async {
    final p = await SharedPreferences.getInstance();
    final values = <String, bool>{
      _sound: p.getBool(_sound) ?? true,
      _music: p.getBool(_music) ?? true,
      _vibration: p.getBool(_vibration) ?? true,
      _aimGuide: p.getBool(_aimGuide) ?? true,
      _ultra: p.getBool(_ultra) ?? true,
    };
    GameFeedback.soundEnabled = values[_sound]!;
    GameFeedback.vibrationEnabled = values[_vibration]!;
    return values;
  }
  static Future<void> save(String key, bool value) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(key, value);
    if (key == _sound) GameFeedback.soundEnabled = value;
    if (key == _vibration) GameFeedback.vibrationEnabled = value;
  }
  static String get sound => _sound;
  static String get music => _music;
  static String get vibration => _vibration;
  static String get aimGuide => _aimGuide;
  static String get ultra => _ultra;
}
