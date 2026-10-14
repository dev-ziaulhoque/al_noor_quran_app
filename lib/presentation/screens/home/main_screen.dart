// lib/presentation/screens/home/main_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/controllers/home_controller.dart';
import '../../../app/routes/notification_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/now_playing_bar.dart';
import 'home_screen.dart';
import '../quran/quran_list_screen.dart';
import '../search/search_screen.dart';
import '../settings/settings_screen.dart';

class MainScreen extends StatelessWidget {
  MainScreen({super.key});

  static final List<Widget> _tabs = [
    HomeScreen(),
    QuranListScreen(),
    SearchScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<HomeController>();
    WidgetsBinding.instance.addPostFrameCallback((_) => NotificationRouter.attach());

    return Obx(() => Scaffold(
          body: IndexedStack(index: ctrl.currentTab.value, children: _tabs),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              border: Border(top: BorderSide(color: AppColors.gold.withValues(alpha: 0.45))),
              boxShadow: const [
                BoxShadow(color: Color(0x141B6B3A), blurRadius: 18, offset: Offset(0, -6)),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const NowPlayingBar(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _NavItem(icon: Icons.home_rounded, label: 'Home'.tr, index: 0, current: ctrl.currentTab.value, onTap: ctrl.changeTab),
                        _NavItem(icon: Icons.menu_book_rounded, label: 'Quran'.tr, index: 1, current: ctrl.currentTab.value, onTap: ctrl.changeTab),
                        _NavItem(icon: Icons.explore_rounded, label: 'Explore'.tr, index: 2, current: ctrl.currentTab.value, onTap: ctrl.changeTab),
                        _NavItem(icon: Icons.settings_rounded, label: 'Settings'.tr, index: 3, current: ctrl.currentTab.value, onTap: ctrl.changeTab),
                      ],
                    ),
                  ),
                ],
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

  _NavItem({super.key, required this.icon, required this.label, required this.index, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isActive = index == current;
    final activeColor = ThemeColors.emerald;
    final inactiveColor = ThemeColors.textLight;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: isActive ? activeColor : inactiveColor),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: isActive ? FontWeight.w600 : FontWeight.normal, color: isActive ? activeColor : inactiveColor)),
          ],
        ),
      ),
    );
  }
}
