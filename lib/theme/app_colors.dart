import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Light Palette — Warm Editorial Alabaster & Botanical Forest Emerald
  static const Color lightBackground = Color(0xFFFAF8F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceSecondary = Color(0xFFF3EFEA);
  static const Color lightBorder = Color(0xFFE6E0D6);
  static const Color lightTextPrimary = Color(0xFF171A18);
  static const Color lightTextSecondary = Color(0xFF5D645F);
  static const Color lightTextTertiary = Color(0xFF8C928D);

  // Dark Palette — Deep Obsidian & Sage Forest Emerald
  static const Color darkBackground = Color(0xFF0E100F);
  static const Color darkSurface = Color(0xFF171A18);
  static const Color darkSurfaceSecondary = Color(0xFF212522);
  static const Color darkBorder = Color(0xFF2C312E);
  static const Color darkTextPrimary = Color(0xFFF4F2EE);
  static const Color darkTextSecondary = Color(0xFFA7ADA8);
  static const Color darkTextTertiary = Color(0xFF6E7570);

  // Signature Brand Accents (Strictly zero blue, zero purple)
  static const Color emeraldPrimary = Color(0xFF1D6348);
  static const Color emeraldLight = Color(0xFF36A87B);
  static const Color emeraldSoftLight = Color(0xFFE5F2EC);
  static const Color emeraldSoftDark = Color(0xFF163327);

  static const Color terracotta = Color(0xFFD4653B);
  static const Color terracottaLight = Color(0xFFEB825A);
  static const Color terracottaSoftLight = Color(0xFFFAEBE5);
  static const Color terracottaSoftDark = Color(0xFF3A2017);

  static const Color amberOchre = Color(0xFFC88A1E);
  static const Color amberLight = Color(0xFFE6AB42);
  static const Color amberSoftLight = Color(0xFFFAF1DF);
  static const Color amberSoftDark = Color(0xFF362811);

  static const Color oliveMoss = Color(0xFF5E7A3A);
  static const Color copperBronze = Color(0xFFA85D34);
  static const Color roseClay = Color(0xFFC25B63);
  static const Color pineTeal = Color(0xFF236E66);
  static const Color espressoUmber = Color(0xFF6E5341);

  // Curated Habit & Category Swatches (All non-blue, non-purple)
  static const List<Color> habitSwatches = [
    emeraldPrimary,
    terracotta,
    amberOchre,
    oliveMoss,
    pineTeal,
    roseClay,
    copperBronze,
    espressoUmber,
  ];
}
