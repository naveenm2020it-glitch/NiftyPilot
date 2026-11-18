import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  static const String appName = 'DayPilot';
  static const String packageId = 'com.naveenmanickam.daypilot';
  static const String appVersion = '1.0.0';
  static const String dbName = 'daypilot_offline_v1.db';
  static const int dbVersion = 1;

  static const List<IconData> habitIcons = [
    Icons.wb_sunny_rounded,
    Icons.water_drop_rounded,
    Icons.fitness_center_rounded,
    Icons.menu_book_rounded,
    Icons.self_improvement_rounded,
    Icons.directions_walk_rounded,
    Icons.bedtime_rounded,
    Icons.spa_rounded,
    Icons.edit_note_rounded,
    Icons.local_cafe_rounded,
    Icons.timer_rounded,
    Icons.favorite_rounded,
  ];

  static const List<String> eventCategories = [
    'Work',
    'Personal',
    'Health',
    'Focus',
    'Family',
    'Errands',
  ];
}
