import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AppSurfaces {
  static BoxDecoration card({double radius = 20}) {
    final dark = ThemeColors.isDark;
    return BoxDecoration(
      color: ThemeColors.getCard(),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: dark ? const Color(0x33C9A84C) : const Color(0xFFE6D9BE)),
      boxShadow: [
        if (dark)
          const BoxShadow(color: Color(0x66000000), blurRadius: 18, offset: Offset(0, 8))
        else ...[
          const BoxShadow(color: Color(0x141B6B3A), blurRadius: 22, offset: Offset(0, 10)),
          const BoxShadow(color: Color(0x0A000000), blurRadius: 2, offset: Offset(0, 1)),
        ],
      ],
    );
  }

  static BoxDecoration hero() {
    return BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF1F7A42), Color(0xFF0E3D22)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0x66E8C96A)),
      boxShadow: const [
        BoxShadow(color: Color(0x331B6B3A), blurRadius: 24, offset: Offset(0, 12)),
      ],
    );
  }
}
