// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Fixed palettes per brightness. Built from constants, not the theme-aware
/// getters, so the light theme stays light even if the app starts dark.
class AppTheme {
  static const _primary = Color(0xFF1B6B3A);
  static const _lightBg = Color(0xFFF3F0E8);
  static const _lightText = Color(0xFF1A2E22);
  static const _lightTextMid = Color(0xFF4A6558);
  static const _lightTextLight = Color(0xFF8BA89A);

  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primary,
        primary: _primary,
        surface: Colors.white,
        onSurface: _lightText,
        brightness: Brightness.light,
      ),
    );
    return base.copyWith(
      scaffoldBackgroundColor: _lightBg,
      textTheme: base.textTheme.apply(bodyColor: _lightText, displayColor: _lightText),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: _lightText,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: _primary),
        titleTextStyle: TextStyle(color: _lightText, fontWeight: FontWeight.w700, fontSize: 16),
      ),
      cardColor: Colors.white,
      dividerColor: _lightTextLight.withValues(alpha: 0.25),
      bottomSheetTheme: const BottomSheetThemeData(backgroundColor: Colors.white),
      dialogTheme: const DialogThemeData(
        backgroundColor: Colors.white,
        titleTextStyle: TextStyle(color: _lightText, fontSize: 17, fontWeight: FontWeight.w700),
        contentTextStyle: TextStyle(color: _lightTextMid, fontSize: 14),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: _lightTextLight),
        labelStyle: TextStyle(color: _lightTextMid),
      ),
      listTileTheme: const ListTileThemeData(textColor: _lightText, iconColor: _lightTextMid),
      snackBarTheme: const SnackBarThemeData(contentTextStyle: TextStyle(color: Colors.white)),
      sliderTheme: const SliderThemeData(activeTrackColor: _primary, thumbColor: _primary),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(backgroundColor: _primary, foregroundColor: Colors.white),
      ),
    );
  }

  static ThemeData get darkTheme {
    const primary = AppPalette.darkEmerald;
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primary,
        primary: primary,
        surface: AppPalette.darkCard,
        onSurface: AppPalette.darkTextPrimary,
        brightness: Brightness.dark,
      ),
    );
    return base.copyWith(
      scaffoldBackgroundColor: AppPalette.darkBg,
      textTheme: base.textTheme.apply(bodyColor: AppPalette.darkTextPrimary, displayColor: AppPalette.darkTextPrimary),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppPalette.darkCard,
        foregroundColor: AppPalette.darkTextPrimary,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: primary),
        titleTextStyle: TextStyle(color: AppPalette.darkTextPrimary, fontWeight: FontWeight.w700, fontSize: 16),
      ),
      cardColor: AppPalette.darkCard,
      dividerColor: AppPalette.darkBorder,
      bottomSheetTheme: const BottomSheetThemeData(backgroundColor: AppPalette.darkCard),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppPalette.darkCard,
        titleTextStyle: TextStyle(color: AppPalette.darkTextPrimary, fontSize: 17, fontWeight: FontWeight.w700),
        contentTextStyle: TextStyle(color: AppPalette.darkTextMid, fontSize: 14),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: AppPalette.darkTextLight),
        labelStyle: TextStyle(color: AppPalette.darkTextMid),
      ),
      listTileTheme: const ListTileThemeData(textColor: AppPalette.darkTextPrimary, iconColor: AppPalette.darkTextMid),
      sliderTheme: const SliderThemeData(activeTrackColor: primary, thumbColor: primary),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(backgroundColor: primary, foregroundColor: Colors.white),
      ),
    );
  }
}
