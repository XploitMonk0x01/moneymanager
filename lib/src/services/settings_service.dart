import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing app settings and preferences
class SettingsService {
  // Settings keys
  static const String _themeKey = 'theme_mode';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _biometricKey = 'biometric_enabled';
  static const String _offlineModeKey = 'offline_mode_enabled';
  static const String _currencyKey = 'currency_symbol';
  static const String _languageKey = 'language_code';

  /// Reset all settings to default values
  Future<void> resetSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Clear all preferences
      await prefs.clear();

      // Set default values
      await prefs.setString(_themeKey, 'system'); // ThemeMode.system
      await prefs.setBool(_notificationsKey, true);
      await prefs.setBool(_biometricKey, false);
      await prefs.setBool(_offlineModeKey, false);
      await prefs.setString(_currencyKey, '₹');
      await prefs.setString(_languageKey, 'en');
    } catch (e) {
      throw Exception('Failed to reset settings: $e');
    }
  }

  /// Get theme mode setting
  Future<String> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey) ?? 'system';
  }

  /// Set theme mode setting
  Future<void> setThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode);
  }

  /// Get notifications enabled setting
  Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsKey) ?? true;
  }

  /// Set notifications enabled setting
  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, enabled);
  }

  /// Get biometric authentication enabled setting
  Future<bool> getBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricKey) ?? false;
  }

  /// Set biometric authentication enabled setting
  Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricKey, enabled);
  }

  /// Get offline mode enabled setting
  Future<bool> getOfflineModeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_offlineModeKey) ?? false;
  }

  /// Set offline mode enabled setting
  Future<void> setOfflineModeEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_offlineModeKey, enabled);
  }

  /// Get currency symbol setting
  Future<String> getCurrencySymbol() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currencyKey) ?? '₹';
  }

  /// Set currency symbol setting
  Future<void> setCurrencySymbol(String symbol) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, symbol);
  }

  /// Get language code setting
  Future<String> getLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'en';
  }

  /// Set language code setting
  Future<void> setLanguageCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, code);
  }
}
