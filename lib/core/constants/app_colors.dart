// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/controllers/settings_controller.dart';

class AppColors {
  // Theme-aware Primary Colors
  static Color get emerald => ThemeColors.getEmerald();
  static Color get emeraldLight => ThemeColors.emeraldLight;
  static Color get emeraldPale => ThemeColors.emeraldPale;
  static Color get emeraldMid => ThemeColors.emeraldMid;

  // Gold Accent Getters
  static Color get gold => AppPalette.gold;
  static Color get goldLight => AppPalette.goldLight;
  /// Soft gold panel; a light cream in light mode would hide light text in dark mode.
  static Color get goldPale => ThemeColors.isDark ? const Color(0xFF2A2716) : AppPalette.goldPale;

  // Theme-aware Backgrounds & Text
  static Color get background => ThemeColors.getBackground();
  static Color get surface => ThemeColors.getSurface();
  static Color get card => ThemeColors.getCard();

  static Color get textDark => ThemeColors.getTextDark();
  static Color get textMid => ThemeColors.getTextMid();
  static Color get textLight => ThemeColors.getTextLight();

  // Dark Mode Getters
  static Color get darkBg => AppPalette.darkBg;
  static Color get darkSurface => AppPalette.darkSurface;
  static Color get darkCard => AppPalette.darkCard;
  static Color get darkBorder => AppPalette.darkBorder;

  static Color getEmerald() => ThemeColors.getEmerald();
  static Color getBackground() => ThemeColors.getBackground();
  static Color getSurface() => ThemeColors.getSurface();
  static Color getCard() => ThemeColors.getCard();
  static Color getTextDark() => ThemeColors.getTextDark();
  static Color getTextMid() => ThemeColors.getTextMid();
  static Color getTextLight() => ThemeColors.getTextLight();
}

class AppPalette {
  static const Color gold = Color(0xFFC9A84C);
  static const Color goldLight = Color(0xFFE8C96A);
  static const Color goldPale = Color(0xFFFBF4E3);

  static const Color darkBg = Color(0xFF0E1412);
  static const Color darkSurface = Color(0xFF141C19);
  static const Color darkCard = Color(0xFF1A2420);
  static const Color darkBorder = Color(0xFF2A3732);
  static const Color darkEmerald = Color(0xFF34A06A);
  static const Color darkTextPrimary = Color(0xFFEDF2EE);
  static const Color darkTextMid = Color(0xFFB4C3BA);
  static const Color darkTextLight = Color(0xFF82938A);
}

class ThemeColors {
  static Color getEmerald() => _isDark ? AppPalette.darkEmerald : const Color(0xFF1B6B3A);

  static Color get emerald => getEmerald();
  static Color get emeraldLight => getEmerald().withValues(alpha: 0.85);
  static Color get emeraldPale => getEmerald().withValues(alpha: 0.12);
  static Color get emeraldMid => getEmerald().withValues(alpha: 0.28);

  static Color getBackground() => _isDark ? AppPalette.darkBg : const Color(0xFFF3F0E8);
  static Color get background => getBackground();

  static Color getSurface() => _isDark ? AppPalette.darkSurface : const Color(0xFFFAFDF8);
  static Color get surface => getSurface();

  static Color getCard() => _isDark ? AppPalette.darkCard : Colors.white;
  static Color get card => getCard();

  static Color getTextDark() => _isDark ? AppPalette.darkTextPrimary : const Color(0xFF1A2E22);
  static Color get textDark => getTextDark();

  static Color getTextMid() => _isDark ? AppPalette.darkTextMid : const Color(0xFF4A6558);
  static Color get textMid => getTextMid();

  static Color getTextLight() => _isDark ? AppPalette.darkTextLight : const Color(0xFF8BA89A);
  static Color get textLight => getTextLight();

  static bool get isDark {
    try {
      if (Get.isRegistered<SettingsController>()) {
        return Get.find<SettingsController>().isDarkMode.value;
      }
    } catch (_) {}
    return false;
  }

  static bool get _isDark => isDark;
}
