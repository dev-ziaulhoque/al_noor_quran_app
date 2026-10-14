import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/controllers/quran_controller.dart';
import '../../app/controllers/settings_controller.dart';
import '../../app/routes/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/i18n/locale_text.dart';

/// Slim bar shown above the bottom navigation while a recitation is loaded.
class NowPlayingBar extends StatelessWidget {
  const NowPlayingBar({super.key});

  @override
  Widget build(BuildContext context) {
    final q = Get.find<QuranController>();
    final s = Get.find<SettingsController>();
    return Obx(() {
      final surah = q.currentSurah.value;
      final index = q.currentAyahIndex.value;
      if (surah == null || index < 0 || index >= q.currentAyahs.length) return const SizedBox.shrink();
      final ayah = q.currentAyahs[index];
      final total = q.duration.value.inMilliseconds;
      final progress = total == 0 ? 0.0 : (q.position.value.inMilliseconds / total).clamp(0.0, 1.0);

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.toNamed(AppRoutes.quranReader),
          child: Container(
            margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1F7A42), Color(0xFF0F4D2A)]),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: Color(0x331B6B3A), blurRadius: 14, offset: Offset(0, 6))],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 4, 6),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(color: Color(0x26FFFFFF), shape: BoxShape.circle),
                        child: const Icon(Icons.graphic_eq_rounded, color: AppPalette.goldLight, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${surah.englishName} · ${'Ayah'.tr} ${LocaleText.digits(ayah.number.toString())}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white),
                            ),
                            Text(
                              s.reciterOption.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11, color: Color(0xB3FFFFFF)),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: q.togglePlayPause,
                        icon: Icon(q.isPlaying.value ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                            color: Colors.white, size: 32),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Stop'.tr,
                        onPressed: q.stopPlayback,
                        icon: const Icon(Icons.close_rounded, color: Color(0xB3FFFFFF), size: 20),
                      ),
                    ],
                  ),
                ),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 2.5,
                  backgroundColor: const Color(0x1FFFFFFF),
                  valueColor: const AlwaysStoppedAnimation(AppPalette.goldLight),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
