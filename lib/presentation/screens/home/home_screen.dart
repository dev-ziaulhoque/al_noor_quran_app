// lib/presentation/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/controllers/home_controller.dart';
import '../../../app/controllers/prayer_controller.dart';
import '../../../app/controllers/quran_controller.dart';
import '../../../app/controllers/settings_controller.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/i18n/locale_text.dart';
import '../../../core/utils/hijri_date.dart';
import '../../widgets/app_surfaces.dart';
import '../../widgets/ayah_of_day_card.dart';
import '../../widgets/next_azan_banner.dart';
import '../../widgets/quran_progress_card.dart';
import '../../widgets/quran_settings_sheet.dart' show SheetHandle;
import '../../widgets/reflection_widgets.dart';

class _Feature {
  final String title;
  final IconData icon;
  final String route;
  final Color color;
  const _Feature(this.title, this.icon, this.route, this.color);
}

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  static List<_Feature> _allFeatures() => [
        _Feature('Quran', Icons.menu_book_rounded, AppRoutes.quranList, AppColors.emerald),
        const _Feature('Prayer times', Icons.access_time_filled_rounded, AppRoutes.azan, Color(0xFF5A4A9C)),
        const _Feature('Qibla', Icons.explore_rounded, AppRoutes.qibla, AppPalette.gold),
        const _Feature('Dua', Icons.back_hand_rounded, AppRoutes.dua, Color(0xFFC07028)),
        const _Feature('Hadith', Icons.auto_stories_rounded, AppRoutes.hadith, Color(0xFF1E6F7D)),
        const _Feature('Tasbih', Icons.radio_button_checked_rounded, AppRoutes.tasbih, Color(0xFF2D8C61)),
        const _Feature('Calendar', Icons.calendar_month_rounded, AppRoutes.calendar, Color(0xFF1E6F7D)),
        const _Feature('Ramadan', Icons.nightlight_round, AppRoutes.ramadan, Color(0xFF5A4A9C)),
        const _Feature('Zakat', Icons.calculate_rounded, AppRoutes.zakat, Color(0xFFC07028)),
        const _Feature('Tracker', Icons.fact_check_rounded, AppRoutes.tracker, Color(0xFF8B5E3C)),
        const _Feature('Reflect', Icons.spa_rounded, AppRoutes.journal, Color(0xFF3F6FB5)),
        const _Feature('Bookmarks', Icons.bookmark_rounded, AppRoutes.bookmarks, AppPalette.gold),
        const _Feature('Downloads', Icons.download_for_offline_rounded, AppRoutes.downloads, Color(0xFF2D8C61)),
        _Feature('Search', Icons.search_rounded, AppRoutes.search, AppColors.emerald),
      ];

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(() {
          settings.appLanguage.value;
          settings.isDarkMode.value;
          final hijri = HijriDate.fromGregorian(DateTime.now());
          final all = _allFeatures();
          final ramadanSeason = hijri.month == 8 || hijri.month == 9;
          final primary = [
            all[0], all[1], all[2], all[3], all[4], all[5],
            ramadanSeason ? all[7] : all[6],
          ];
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _Greeting(hijri: hijri),
              const SizedBox(height: 14),
              const NextAzanBanner(),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.86,
                children: [
                  for (final f in primary) _FeatureTile(feature: f),
                  _FeatureTile(
                    feature: const _Feature('More', Icons.apps_rounded, '', AppPalette.gold),
                    onTap: () => _showAllFeatures(context, all),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const _TimelySuggestion(),
              const SizedBox(height: 16),
              const AyahOfDayCard(),
              const SizedBox(height: 16),
              const MoodCheckIn(compact: true),
              const SizedBox(height: 16),
              const QuranProgressCard(),
            ],
          );
        }),
      ),
    );
  }

  void _showAllFeatures(BuildContext context, List<_Feature> all) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(child: SheetHandle()),
              const SizedBox(height: 12),
              Text('All features'.tr, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textDark)),
              const SizedBox(height: 14),
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.86,
                children: [
                  for (final f in all)
                    _FeatureTile(
                      feature: f,
                      onTap: () {
                        Get.back();
                        Get.toNamed(f.route);
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  final HijriDate hijri;
  const _Greeting({required this.hijri});

  List<(String, IconData)> _occasions() {
    final now = DateTime.now();
    final list = <(String, IconData)>[];
    if (hijri.month == 9) list.add(('Ramadan Kareem', Icons.nightlight_round));
    if (hijri.month == 10 && hijri.day <= 3) list.add(('Eid Mubarak', Icons.celebration_rounded));
    if (hijri.month == 12 && hijri.day == 9) list.add(('Day of Arafah', Icons.terrain_rounded));
    if (hijri.month == 12 && hijri.day >= 10 && hijri.day <= 13) list.add(('Eid Mubarak', Icons.celebration_rounded));
    if (hijri.month == 1 && hijri.day == 10) list.add(('Day of Ashura', Icons.water_drop_rounded));
    if (hijri.day >= 13 && hijri.day <= 15 && hijri.month != 9) list.add(('White days (sunnah fast)', Icons.brightness_3_rounded));
    if (now.weekday == DateTime.friday) list.add(("Jumu'ah Mubarak", Icons.mosque_rounded));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    final name = settings.userName.value.trim();
    final occasions = _occasions();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'السَّلَامُ عَلَيْكُمْ',
                style: TextStyle(fontFamily: 'Amiri', fontSize: 22, height: 1.3, color: AppColors.emerald, fontWeight: FontWeight.w700),
              ),
              Text(
                name.isEmpty ? 'Assalamu Alaikum'.tr : '${'Assalamu Alaikum'.tr}, $name',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textDark),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _Chip(
                    icon: Icons.brightness_2_rounded,
                    label: LocaleText.hijri(hijri),
                    color: AppPalette.gold,
                  ),
                  for (final o in occasions) _Chip(icon: o.$2, label: o.$1.tr, color: AppColors.emerald, filled: true),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => Get.find<HomeController>().changeTab(3),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [AppColors.emerald.withValues(alpha: 0.85), AppColors.emerald]),
              border: Border.all(color: AppPalette.goldLight, width: 1.5),
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'ن',
                style: const TextStyle(fontFamily: 'Amiri', fontSize: 19, color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool filled;

  const _Chip({required this.icon, required this.label, required this.color, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: filled ? color.withValues(alpha: 0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}

/// One suggestion that fits the current time: adhkar, Al-Kahf on Friday,
/// the sleep duas at night.
class _TimelySuggestion extends StatelessWidget {
  const _TimelySuggestion();

  @override
  Widget build(BuildContext context) {
    final p = Get.find<PrayerController>();
    return Obx(() {
      final w = p.todayWaqt;
      p.nextAzanAt.value;
      if (w.isEmpty) return const SizedBox.shrink();
      final now = DateTime.now();
      late final String title;
      late final String subtitle;
      late final IconData icon;
      late final VoidCallback onTap;

      void openDuas(String category) => Get.toNamed(AppRoutes.dua, arguments: {'category': category});

      if (now.weekday == DateTime.friday && now.isBefore(w['Maghrib']!)) {
        title = 'Read Surah Al-Kahf today';
        subtitle = "A light between the two Fridays · Sunnah of Jumu'ah";
        icon = Icons.auto_stories_rounded;
        onTap = () {
          Get.find<QuranController>().openAyah(18, 1);
          Get.toNamed(AppRoutes.quranReader);
        };
      } else if (!now.isBefore(w['Fajr']!) && now.isBefore(w['Dhuhr']!)) {
        title = 'Morning adhkar';
        subtitle = 'Start the day with remembrance of Allah';
        icon = Icons.wb_sunny_rounded;
        onTap = () => openDuas('morning');
      } else if (!now.isBefore(w['Asr']!) && now.isBefore(w['Maghrib']!)) {
        title = 'Evening adhkar';
        subtitle = 'Protection until the morning';
        icon = Icons.wb_twilight_rounded;
        onTap = () => openDuas('morning');
      } else if (!now.isBefore(w['Isha']!) || now.isBefore(w['Fajr']!)) {
        title = 'Before you sleep';
        subtitle = 'Ayat al-Kursi and the sleeping duas';
        icon = Icons.bedtime_rounded;
        onTap = () => openDuas('sleep');
      } else {
        title = 'Hadith of the day';
        subtitle = 'A short reminder from the Sunnah';
        icon = Icons.format_quote_rounded;
        onTap = () => Get.toNamed(AppRoutes.hadith);
      }

      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: AppSurfaces.card(radius: 18),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(color: AppPalette.gold.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: AppPalette.gold, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SUGGESTED NOW'.tr, style: TextStyle(fontSize: 9.5, letterSpacing: 1.3, fontWeight: FontWeight.w800, color: AppColors.textLight)),
                    const SizedBox(height: 2),
                    Text(title.tr, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                    Text(subtitle.tr, style: TextStyle(fontSize: 11.5, color: AppColors.textMid)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
            ],
          ),
        ),
      );
    });
  }
}

class _FeatureTile extends StatelessWidget {
  final _Feature feature;
  final VoidCallback? onTap;

  const _FeatureTile({required this.feature, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () => Get.toNamed(feature.route),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: AppSurfaces.card(radius: 18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(color: feature.color.withValues(alpha: 0.13), borderRadius: BorderRadius.circular(13)),
              child: Icon(feature.icon, color: feature.color, size: 21),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                feature.title.tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
