// lib/presentation/screens/quran/quran_reader_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/controllers/quran_controller.dart';
import '../../../app/controllers/settings_controller.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/i18n/locale_text.dart';
import '../../../core/quran/arabic_fonts.dart';
import '../../../data/models/models.dart';
import '../../widgets/ayah_share_card.dart';
import '../../widgets/ayah_study_section.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/quran_settings_sheet.dart';
import '../../widgets/reflection_widgets.dart';

class QuranReaderScreen extends StatelessWidget {
  final SurahModel? surah;
  const QuranReaderScreen({super.key, this.surah});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<QuranController>();
    final settings = Get.find<SettingsController>();

    if (surah != null && ctrl.currentSurah.value?.number != surah!.number) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ctrl.loadSurahAyahs(surah!);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Obx(() {
          final surah = ctrl.currentSurah.value;
          if (surah == null) return const SizedBox.shrink();
          return Column(
            children: [
              // ─── AppBar ───
              Container(
                color: AppColors.card,
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: Get.back,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.emeraldPale,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.emerald),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(surah.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.getTextDark())),
                          Text(
                            '${surah.nameArabic} · ${LocaleText.digits(surah.totalAyah)} ${'Ayahs'.tr}',
                            style: TextStyle(fontSize: 11, color: AppColors.getTextLight(), fontFamily: 'Amiri'),
                          ),
                          Obx(() => Text(
                                '${settings.translationOption.language} · ${settings.reciterOption.name}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 9, color: AppColors.getTextLight()),
                              )),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => showReaderSettings(context),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.emeraldPale,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.tune_rounded, size: 16, color: AppColors.getEmerald()),
                      ),
                    ),
                  ],
                ),
              ),

              // ─── Bismillah ───
              if (surah.number != 1 && surah.number != 9)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  color: AppColors.goldPale,
                  child: Text(
                    'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'Amiri', fontSize: 22, color: AppColors.emerald),
                  ),
                ),

              // ─── Ayahs ───
              Expanded(
                child: ctrl.isLoadingAyahs.value
                    ? Center(child: CircularProgressIndicator(color: AppColors.emerald))
                    : ctrl.currentAyahs.isEmpty
                        ? EmptyState(
                            icon: Icons.cloud_off_rounded,
                            title: 'Surah not loaded'.tr,
                            message: ctrl.readerError.value.isEmpty
                                ? 'This surah could not be loaded.'.tr
                                : '${ctrl.readerError.value}\n${'Download the Quran once to read without internet.'.tr}',
                            actionLabel: 'Try again'.tr,
                            actionIcon: Icons.refresh_rounded,
                            onAction: () => ctrl.loadSurahAyahs(surah),
                            secondaryLabel: 'Offline downloads'.tr,
                            onSecondary: () => Get.toNamed(AppRoutes.downloads),
                          )
                        : NotificationListener<ScrollEndNotification>(
                            onNotification: (_) {
                              ctrl.scheduleReadTracking();
                              return false;
                            },
                            child: ListView.builder(
                              key: ctrl.listKey,
                              controller: ctrl.scrollController,
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              itemCount: ctrl.currentAyahs.length,
                              itemBuilder: (ctx, i) {
                                final ayah = ctrl.currentAyahs[i];
                                return KeyedSubtree(
                                  key: ctrl.keyForAyah(i),
                                  child: Obx(() {
                                    final isPlaying = ctrl.currentAyahIndex.value == i;
                                    return _AyahCard(
                                      ayah: ayah,
                                      ctrl: ctrl,
                                      isPlaying: isPlaying,
                                      index: i,
                                    );
                                  }),
                                );
                              },
                            ),
                          ),
              ),

              // ─── Audio Player ───
              Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(
                  children: [
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                        activeTrackColor: AppColors.emerald,
                        inactiveTrackColor: AppColors.emeraldMid,
                        thumbColor: AppColors.emerald,
                      ),
                      child: Obx(() {
                        final pos = ctrl.position.value.inSeconds.toDouble();
                        final dur = ctrl.duration.value.inSeconds.toDouble();
                        return Slider(
                          value: pos.clamp(0.0, dur > 0 ? dur : 0.0),
                          max: dur > 0 ? dur : 1.0,
                          onChanged: (v) => ctrl.seek(Duration(seconds: v.toInt())),
                        );
                      }),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(() => Text(_formatDuration(ctrl.position.value), style: TextStyle(fontSize: 10, color: ThemeColors.textLight))),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.skip_previous_rounded), 
                              onPressed: ctrl.skipPrevious, 
                              color: AppColors.emerald,
                            ),
                            GestureDetector(
                              onTap: ctrl.togglePlayPause,
                              child: Container(
                                width: 45,
                                height: 45,
                                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.emerald),
                                child: Obx(() => Icon(
                                  ctrl.isPlaying.value ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 28,
                                )),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.skip_next_rounded), 
                              onPressed: ctrl.skipNext, 
                              color: AppColors.emerald,
                            ),
                          ],
                        ),
                        Obx(() => Text(_formatDuration(ctrl.duration.value), style: TextStyle(fontSize: 10, color: ThemeColors.textLight))),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

}

class _AyahCard extends StatelessWidget {
  final AyahModel ayah;
  final QuranController ctrl;
  final bool isPlaying;
  final int index;

  const _AyahCard({
    required this.ayah, 
    required this.ctrl, 
    required this.isPlaying,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPlaying ? AppColors.emerald.withValues(alpha: 0.08) : AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPlaying ? AppColors.emerald.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.05), 
          width: isPlaying ? 1.5 : 0.5,
        ),
        boxShadow: isPlaying ? [
          BoxShadow(color: AppColors.emerald.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 4))
        ] : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Obx(() {
                    final surahNum = ctrl.currentSurah.value?.number ?? 1;
                    final isBookmarked = ctrl.isBookmarked(surahNum, ayah.number);
                    return GestureDetector(
                      onTap: () => ctrl.toggleBookmark(ayah),
                      child: Icon(
                        isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        size: 20,
                        color: isBookmarked ? AppColors.emerald : AppColors.textLight,
                      ),
                    );
                  }),
                  const SizedBox(width: 14),
                  GestureDetector(
                    onTap: () {
                      final surah = ctrl.currentSurah.value;
                      showAyahShareSheet(
                        context,
                        AyahCardContent(
                          arabic: ayah.arabic,
                          meaning: ayah.translation,
                          surahName: surah?.englishName.isNotEmpty == true ? surah!.englishName : (surah?.name ?? 'Surah'),
                          surahNumber: surah?.number ?? ayah.surahNumber,
                          ayahNumber: ayah.number,
                          heading: 'Quran'.tr,
                        ),
                      );
                    },
                    child: Icon(
                      Icons.share_rounded,
                      size: 18,
                      color: ThemeColors.textLight,
                    ),
                  ),
                  const SizedBox(width: 14),
                  GestureDetector(
                    onTap: () {
                      final surah = ctrl.currentSurah.value;
                      final number = surah?.number ?? ayah.surahNumber;
                      final name = surah?.englishName.isNotEmpty == true ? surah!.englishName : (surah?.name ?? 'Surah'.tr);
                      showAyahReflectSheet(context, surah: number, ayah: ayah.number, reference: '$name $number:${ayah.number}');
                    },
                    child: Icon(Icons.spa_outlined, size: 18, color: ThemeColors.textLight),
                  ),
                  const SizedBox(width: 14),
                  GestureDetector(
                    onTap: () => ctrl.playAyah(index),
                    child: Icon(
                      isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                      size: 20,
                      color: isPlaying ? AppColors.emerald : AppColors.emerald.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isPlaying ? AppColors.emerald : AppColors.emeraldPale,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${ayah.number}',
                  style: TextStyle(
                    fontSize: 10, 
                    fontWeight: FontWeight.bold, 
                    color: isPlaying ? Colors.white : AppColors.emerald,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() => Text(
            ayah.arabic,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: ArabicFontOption.at(Get.find<SettingsController>().arabicFont.value).style(
              size: ctrl.fontSize.value,
              color: AppColors.textDark,
              weight: isPlaying ? FontWeight.w600 : FontWeight.normal,
            ),
          )),
          if (ayah.translation.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: Colors.black.withValues(alpha: 0.06), height: 1, thickness: 0.5),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Get.find<SettingsController>().translationSourceLabel,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.emerald),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ayah.translation,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 13,
                      color: isPlaying ? AppColors.textDark : AppColors.textMid,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            Obx(() {
              final settings = Get.find<SettingsController>();
              return AyahStudySection(
                key: ValueKey('${settings.translationId.value}:${settings.tafsirId.value}:${ayah.surahNumber}:${ayah.number}'),
                surah: ayah.surahNumber,
                ayah: ayah.number,
              );
            }),
          ],
        ],
      ),
    );
  }
}
