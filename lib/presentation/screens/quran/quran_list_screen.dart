// lib/presentation/screens/quran/quran_list_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/controllers/quran_controller.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/i18n/locale_text.dart';
import '../../../data/models/models.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/quran_settings_sheet.dart';

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _HeaderButton({required this.icon, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Material(
        color: AppColors.emeraldPale,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Tooltip(
            message: tooltip,
            child: SizedBox(width: 38, height: 38, child: Icon(icon, size: 19, color: AppColors.emerald)),
          ),
        ),
      ),
    );
  }
}

class QuranListScreen extends StatelessWidget {
  QuranListScreen({super.key});

  Widget _buildSurahTile(BuildContext context, QuranController ctrl, SurahModel surah) {
    final pColor = ThemeColors.emerald;
    final pPale = ThemeColors.emeraldPale;
    final txtDark = ThemeColors.textDark;
    final txtLight = ThemeColors.textLight;

    return GestureDetector(
      onTap: () {
        ctrl.loadSurahAyahs(surah);
        Get.toNamed(AppRoutes.quranReader);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 1),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          border: Border(bottom: BorderSide(color: Colors.black.withValues(alpha: 0.04), width: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: pPale,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${surah.number}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: pColor),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(surah.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: txtDark)),
                  Obx(() {
                    final read = ctrl.readBySurah[surah.number] ?? 0;
                    final done = surah.totalAyah > 0 && read >= surah.totalAyah;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          read == 0
                              ? '${LocaleText.digits(surah.totalAyah)} ${'ayahs'.tr} · ${surah.revelationType.tr}'
                              : done
                                  ? '${'Completed'.tr} · ${LocaleText.digits(surah.totalAyah)} ${'ayahs'.tr}'
                                  : '${LocaleText.digits(read)} / ${LocaleText.digits(surah.totalAyah)} ${'ayahs read'.tr}',
                          style: TextStyle(fontSize: 11, color: read == 0 ? txtLight : pColor),
                        ),
                        if (read > 0 && !done) ...[
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: read / surah.totalAyah,
                              minHeight: 3,
                              backgroundColor: pPale,
                              valueColor: AlwaysStoppedAnimation(pColor),
                            ),
                          ),
                        ],
                      ],
                    );
                  }),
                ],
              ),
            ),
            Text(
              surah.nameArabic,
              style: TextStyle(fontFamily: 'Amiri', fontSize: 18, color: pColor),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<QuranController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: AppColors.card,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'القرآن الكريم',
                              style: TextStyle(fontFamily: 'Amiri', fontSize: 22, color: AppColors.getEmerald()),
                            ),
                            Text(
                              'The Holy Quran'.tr,
                              style: TextStyle(fontSize: 13, color: AppColors.getTextLight()),
                            ),
                          ],
                        ),
                      ),
                      _HeaderButton(icon: Icons.bookmarks_rounded, tooltip: 'Bookmarks'.tr, onTap: () => Get.toNamed(AppRoutes.bookmarks)),
                      _HeaderButton(icon: Icons.download_for_offline_rounded, tooltip: 'Offline downloads'.tr, onTap: () => Get.toNamed(AppRoutes.downloads)),
                      _HeaderButton(icon: Icons.tune_rounded, tooltip: 'Reading settings'.tr, onTap: () => showReaderSettings(context)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.emeraldPale,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      onChanged: (val) => ctrl.searchQuery.value = val,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search surah, name or number…'.tr,
                        hintStyle: TextStyle(color: AppColors.getTextLight(), fontSize: 13),
                        prefixIcon: Icon(Icons.search_rounded, color: AppColors.getTextLight(), size: 20),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ─── List ───
            Expanded(
              child: Obx(() {
                final primaryCol = ThemeColors.emerald;
                if (ctrl.isLoadingSurahs.value) {
                  return Center(child: CircularProgressIndicator(color: primaryCol));
                }
                if (ctrl.error.value.isNotEmpty && ctrl.surahList.isEmpty) {
                  return EmptyState(
                    icon: Icons.wifi_off_rounded,
                    title: 'You are offline'.tr,
                    message: 'Connect once to load the surah list. After that, downloaded surahs open without internet.'.tr,
                    actionLabel: 'Try again'.tr,
                    actionIcon: Icons.refresh_rounded,
                    onAction: ctrl.loadSurahs,
                  );
                }

                final list = ctrl.filteredSurahs;
                if (list.isEmpty) {
                  return EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'No surah matches'.tr,
                    message: 'Try the English name, Arabic name, meaning, or a number from 1 to 114.'.tr,
                    compact: true,
                  );
                }
                return ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: list.length,
                  itemBuilder: (context, index) => _buildSurahTile(context, ctrl, list[index]),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
