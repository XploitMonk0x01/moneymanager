import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing app settings and preferences.
/// Uses a cached [SharedPreferences] instance to avoid repeated async lookups.
class SettingsService {
  // Settings keys
  static const String _themeKey = 'theme_mode';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _biometricKey = 'biometric_enabled';
  static const String _offlineModeKey = 'offline_mode_enabled';
  static const String _currencyKey = 'currency_symbol';
  static const String _languageKey = 'language_code';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Reset all settings to default values
  Future<void> resetSettings() async {
    try {
      final prefs = await _instance;
      await prefs.clear();
      _prefs = null; // invalidate cache so next read picks up defaults
      await prefs.setString(_themeKey, 'system');
      await prefs.setBool(_notificationsKey, true);
      await prefs.setBool(_biometricKey, false);
      await prefs.setBool(_offlineModeKey, false);
      await prefs.setString(_currencyKey, '₹');
      await prefs.setString(_languageKey, 'en');
    } catch (e) {
      throw Exception('Failed to reset settings: $e');
    }
  }

  Future<String> getThemeMode() async =>
      (await _instance).getString(_themeKey) ?? 'system';

  Future<void> setThemeMode(String mode) async =>
      (await _instance).setString(_themeKey, mode);

  Future<bool> getNotificationsEnabled() async =>
      (await _instance).getBool(_notificationsKey) ?? true;

  Future<void> setNotificationsEnabled(bool enabled) async =>
      (await _instance).setBool(_notificationsKey, enabled);

  Future<bool> getBiometricEnabled() async =>
      (await _instance).getBool(_biometricKey) ?? false;

  Future<void> setBiometricEnabled(bool enabled) async =>
      (await _instance).setBool(_biometricKey, enabled);

  Future<bool> getOfflineModeEnabled() async =>
      (await _instance).getBool(_offlineModeKey) ?? false;

  Future<void> setOfflineModeEnabled(bool enabled) async =>
      (await _instance).setBool(_offlineModeKey, enabled);

  Future<String> getCurrencySymbol() async =>
      (await _instance).getString(_currencyKey) ?? '₹';

  Future<void> setCurrencySymbol(String symbol) async =>
      (await _instance).setString(_currencyKey, symbol);

  Future<String> getLanguageCode() async =>
      (await _instance).getString(_languageKey) ?? 'en';

  Future<void> setLanguageCode(String code) async =>
      (await _instance).setString(_languageKey, code);
}
