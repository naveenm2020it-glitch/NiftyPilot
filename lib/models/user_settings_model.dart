import 'package:flutter/material.dart';

class UserSettingsModel {
  final String userName;
  final ThemeMode themeMode;
  final String languageCode; // 'en' or 'ta'
  final bool notificationsEnabled;
  final String? appPin;
  final bool biometricEnabled;
  final int dailyWaterTargetMl;

  const UserSettingsModel({
    this.userName = '',
    this.themeMode = ThemeMode.light,
    this.languageCode = 'en',
    this.notificationsEnabled = true,
    this.appPin,
    this.biometricEnabled = false,
    this.dailyWaterTargetMl = 2500,
  });

  bool get hasPin => appPin != null && appPin!.length == 4;

  UserSettingsModel copyWith({
    String? userName,
    ThemeMode? themeMode,
    String? languageCode,
    bool? notificationsEnabled,
    String? appPin,
    bool clearPin = false,
    bool? biometricEnabled,
    int? dailyWaterTargetMl,
  }) {
    return UserSettingsModel(
      userName: userName ?? this.userName,
      themeMode: themeMode ?? this.themeMode,
      languageCode: languageCode ?? this.languageCode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      appPin: clearPin ? null : (appPin ?? this.appPin),
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      dailyWaterTargetMl: dailyWaterTargetMl ?? this.dailyWaterTargetMl,
    );
  }
}
