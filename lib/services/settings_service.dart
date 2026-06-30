
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._();
  factory SettingsService() => _instance;
  SettingsService._();

  SharedPreferences? _prefs;

  bool get hapticEnabled => _prefs?.getBool('haptic_enabled') ?? true;
  String get themeName => _prefs?.getString('theme_name') ?? 'indigo';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> setHapticEnabled(bool value) async {
    await _prefs?.setBool('haptic_enabled', value);
  }

  Future<void> setThemeName(String value) async {
    await _prefs?.setString('theme_name', value);
  }
}
