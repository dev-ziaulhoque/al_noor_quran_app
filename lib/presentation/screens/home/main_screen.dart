// lib/presentation/screens/home/main_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/controllers/home_controller.dart';
import '../../../core/constants/app_colors.dart';
import 'home_screen.dart';
import '../quran/quran_list_screen.dart';
import '../search/search_screen.dart';
import '../qibla/qibla_screen.dart';
import '../settings/settings_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<HomeController>();
    final tabs = const [
      HomeScreen(),
      QuranListScreen(),
      SearchScreen(),
      QiblaScreen(),
      SettingsScreen(),
    ];

    return Obx(() => Scaffold(
          body: IndexedStack(index: ctrl.currentTab.value, children: tabs),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.black.withOpacity(0.07), width: 0.5)),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(icon: Icons.home_rounded, label: 'Home', index: 0, current: ctrl.currentTab.value, onTap: ctrl.changeTab),
                    _NavItem(icon: Icons.menu_book_rounded, label: 'Quran', index: 1, current: ctrl.currentTab.value, onTap: ctrl.changeTab),
                    _NavItem(icon: Icons.search_rounded, label: 'Search', index: 2, current: ctrl.currentTab.value, onTap: ctrl.changeTab),
                    _NavItem(icon: Icons.explore_rounded, label: 'Qibla', index: 3, current: ctrl.currentTab.value, onTap: ctrl.changeTab),
                    _NavItem(icon: Icons.settings_rounded, label: 'Settings', index: 4, current: ctrl.currentTab.value, onTap: ctrl.changeTab),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int current;
  final Function(int) onTap;

  const _NavItem({required this.icon, required this.label, required this.index, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isActive = index == current;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: isActive ? AppColors.emerald : AppColors.textLight),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: isActive ? FontWeight.w600 : FontWeight.normal, color: isActive ? AppColors.emerald : AppColors.textLight)),
          ],
        ),
      ),
    );
  }
}
