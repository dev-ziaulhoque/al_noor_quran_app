// lib/presentation/screens/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/controllers/settings_controller.dart';
import '../../../app/controllers/quran_controller.dart';
import '../../../core/constants/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SettingsController>();
    final qCtrl = Get.find<QuranController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ─── Profile Header ───
              Obx(() => Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1B6B3A), Color(0xFF0D4223)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.gold.withOpacity(0.3),
                            border: Border.all(color: AppColors.goldLight, width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              ctrl.userName.value.isNotEmpty ? ctrl.userName.value[0].toUpperCase() : 'أ',
                              style: const TextStyle(fontFamily: 'Amiri', fontSize: 22, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ctrl.userName.value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                              GestureDetector(
                                onTap: () => _editName(context, ctrl),
                                child: const Text('Tap to edit name ›', style: TextStyle(fontSize: 11, color: Color(0x80FFFFFF))),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            const Text('7', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                            const Text('Streak', style: TextStyle(fontSize: 9, color: Color(0x80FFFFFF))),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Column(
                          children: [
                            const Text('4.2k', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                            const Text('Tasbihat', style: TextStyle(fontSize: 9, color: Color(0x80FFFFFF))),
                          ],
                        ),
                      ],
                    ),
                  )),

              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── Appearance ───
                    _SectionLabel('Appearance'),
                    _SettingsCard(children: [
                      // Font preview
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            const Text('Quran Font', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                            const SizedBox(height: 8),
                            const Text(
                              'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                              style: TextStyle(fontFamily: 'Amiri', fontSize: 20, color: AppColors.emerald),
                            ),
                            const SizedBox(height: 8),
                            Obx(() => Row(
                                  children: [
                                    const Text('A-', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.emerald)),
                                    Expanded(
                                      child: Slider(
                                        value: qCtrl.fontSize.value,
                                        min: 16,
                                        max: 36,
                                        activeColor: AppColors.emerald,
                                        inactiveColor: AppColors.emeraldMid,
                                        onChanged: qCtrl.updateFontSize,
                                      ),
                                    ),
                                    const Text('A+', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.emerald)),
                                  ],
                                )),
                          ],
                        ),
                      ),
                      Divider(height: 0, color: Colors.black.withOpacity(0.06), thickness: 0.5),
                      // Theme colors
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Theme Color', style: TextStyle(fontSize: 11, color: AppColors.textLight)),
                            const SizedBox(height: 8),
                            Obx(() => Row(
                                  children: [
                                    ...SettingsController.themeColors.asMap().entries.map((e) => GestureDetector(
                                          onTap: () => ctrl.selectTheme(e.key),
                                          child: Container(
                                            width: 28,
                                            height: 28,
                                            margin: const EdgeInsets.only(right: 8),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: e.value,
                                              border: ctrl.selectedTheme.value == e.key
                                                  ? Border.all(color: AppColors.textDark, width: 2)
                                                  : null,
                                            ),
                                          ),
                                        )),
                                    const SizedBox(width: 8),
                                    const Text('Dark Mode', style: TextStyle(fontSize: 11, color: AppColors.textMid)),
                                    const SizedBox(width: 6),
                                    Obx(() => Switch.adaptive(
                                          value: ctrl.isDarkMode.value,
                                          onChanged: ctrl.toggleDarkMode,
                                          activeColor: AppColors.emerald,
                                        )),
                                  ],
                                )),
                          ],
                        ),
                      ),
                    ]),

                    // ─── Notifications ───
                    _SectionLabel('Notifications'),
                    _SettingsCard(children: [
                      Obx(() => _SwitchRow(title: 'All Notifications', sub: 'Master switch', value: ctrl.allNotifications.value, onChanged: ctrl.toggleAllNotifications)),
                      Obx(() => _SwitchRow(title: 'Prayer Alerts', sub: '5 min before each prayer', value: ctrl.prayerAlerts.value, onChanged: ctrl.togglePrayerAlerts)),
                      Obx(() => _SwitchRow(title: 'Daily Verse', sub: 'Morning reminder', value: ctrl.dailyVerse.value, onChanged: ctrl.toggleDailyVerse)),
                      Obx(() => _SwitchRow(title: 'Reading Goal', sub: 'Daily target', value: ctrl.readingGoal.value, onChanged: ctrl.toggleReadingGoal, isLast: true)),
                    ]),

                    // ─── More ───
                    _SectionLabel('More'),
                    _SettingsCard(children: [
                      _ArrowRow(title: 'Reciter / Qari', sub: 'Abdul Basit Samad'),
                      _ArrowRow(title: 'Translation', sub: 'Display language', badge: 'English'),
                      _ArrowRow(title: 'Download Offline', sub: 'Save surahs locally', isLast: true),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editName(BuildContext context, SettingsController ctrl) {
    final textCtrl = TextEditingController(text: ctrl.userName.value);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(controller: textCtrl, decoration: const InputDecoration(hintText: 'Your name')),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              ctrl.updateUserName(textCtrl.text.trim());
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.emerald),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6, left: 4),
      child: Text(text.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textLight, letterSpacing: 1)),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.06), width: 0.5),
      ),
      child: Column(children: children),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String title;
  final String sub;
  final bool value;
  final Function(bool) onChanged;
  final bool isLast;

  const _SwitchRow({required this.title, required this.sub, required this.value, required this.onChanged, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: Colors.black.withOpacity(0.05), width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                Text(sub, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
              ],
            ),
          ),
          Switch.adaptive(value: value, onChanged: onChanged, activeColor: AppColors.emerald),
        ],
      ),
    );
  }
}

class _ArrowRow extends StatelessWidget {
  final String title;
  final String sub;
  final String? badge;
  final bool isLast;

  const _ArrowRow({required this.title, required this.sub, this.badge, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: Colors.black.withOpacity(0.05), width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                Text(sub, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
              ],
            ),
          ),
          if (badge != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppColors.emeraldPale, borderRadius: BorderRadius.circular(20)),
              child: Text(badge!, style: const TextStyle(fontSize: 10, color: AppColors.emerald, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 6),
          ],
          const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textLight),
        ],
      ),
    );
  }
}
