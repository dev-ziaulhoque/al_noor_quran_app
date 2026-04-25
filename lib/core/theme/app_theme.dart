// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.emerald,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
          iconTheme: IconThemeData(color: AppColors.emerald),
          titleTextStyle: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.black.withOpacity(0.06), width: 0.5),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.emerald,
          unselectedItemColor: AppColors.textLight,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          unselectedLabelStyle: TextStyle(fontSize: 10),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700),
          headlineMedium: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(color: AppColors.textDark),
          bodyMedium: TextStyle(color: AppColors.textMid),
          bodySmall: TextStyle(color: AppColors.textLight),
        ),
        dividerTheme: DividerThemeData(
          color: Colors.black.withOpacity(0.06),
          thickness: 0.5,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith(
            (s) => s.contains(MaterialState.selected) ? Colors.white : Colors.white,
          ),
          trackColor: MaterialStateProperty.resolveWith(
            (s) => s.contains(MaterialState.selected)
                ? AppColors.emerald
                : const Color(0xFFD1D5DB),
          ),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.emerald,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkSurface,
          elevation: 0,
          centerTitle: true,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
          iconTheme: IconThemeData(color: AppColors.emeraldLight),
        ),
        cardTheme: CardThemeData(
          color: AppColors.darkCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.darkBorder, width: 0.5),
          ),
        ),
      );
}
