import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_settings_model.dart';

class SettingsRepository {
  static const _kUserName = 'dp_user_name';
  static const _kThemeMode = 'dp_theme_mode';
  static const _kLanguage = 'dp_language';
  static const _kNotifications = 'dp_notifications';
  static const _kAppPin = 'dp_app_pin';
  static const _kBiometric = 'dp_biometric';
  static const _kWaterTarget = 'dp_water_target';

  Future<UserSettingsModel> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeStr = prefs.getString(_kThemeMode) ?? 'light';
    ThemeMode themeMode;
    switch (themeStr) {
      case 'dark':
        themeMode = ThemeMode.dark;
        break;
      case 'system':
        themeMode = ThemeMode.system;
        break;
      default:
        themeMode = ThemeMode.light;
    }

    return UserSettingsModel(
      userName: prefs.getString(_kUserName) ?? '',
      themeMode: themeMode,
      languageCode: prefs.getString(_kLanguage) ?? 'en',
      notificationsEnabled: prefs.getBool(_kNotifications) ?? true,
      appPin: prefs.getString(_kAppPin),
      biometricEnabled: prefs.getBool(_kBiometric) ?? false,
      dailyWaterTargetMl: prefs.getInt(_kWaterTarget) ?? 2500,
    );
  }

  Future<void> saveSettings(UserSettingsModel settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUserName, settings.userName);
    await prefs.setString(_kThemeMode, settings.themeMode.name);
    await prefs.setString(_kLanguage, settings.languageCode);
    await prefs.setBool(_kNotifications, settings.notificationsEnabled);
    if (settings.appPin != null && settings.appPin!.length == 4) {
      await prefs.setString(_kAppPin, settings.appPin!);
    } else {
      await prefs.remove(_kAppPin);
    }
    await prefs.setBool(_kBiometric, settings.biometricEnabled);
    await prefs.setInt(_kWaterTarget, settings.dailyWaterTargetMl);
  }
}
