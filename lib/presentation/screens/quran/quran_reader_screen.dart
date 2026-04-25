// lib/presentation/screens/quran/quran_reader_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/controllers/quran_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/models.dart';

class QuranReaderScreen extends StatelessWidget {
  const QuranReaderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<QuranController>();

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
                color: Colors.white,
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
                        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.emerald),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(surah.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                          Text(
                            '${surah.nameArabic} · ${surah.totalAyah} Ayahs',
                            style: const TextStyle(fontSize: 11, color: AppColors.textLight, fontFamily: 'Amiri'),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showFontSizeDialog(context, ctrl),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.emeraldPale,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.text_fields_rounded, size: 16, color: AppColors.emerald),
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
                  child: const Text(
                    'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'Amiri', fontSize: 22, color: AppColors.emerald),
                  ),
                ),

              // ─── Ayahs ───
              Expanded(
                child: ctrl.isLoadingAyahs.value
                    ? const Center(child: CircularProgressIndicator(color: AppColors.emerald))
                    : ListView.builder(
                        controller: ctrl.scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        itemCount: ctrl.currentAyahs.length,
                        itemBuilder: (ctx, i) {
                          final ayah = ctrl.currentAyahs[i];
                          return Obx(() {
                            final isPlaying = ctrl.currentAyahIndex.value == i;
                            return _AyahCard(
                              ayah: ayah, 
                              ctrl: ctrl, 
                              isPlaying: isPlaying,
                              index: i,
                            );
                          });
                        },
                      ),
              ),

              // ─── Audio Player ───
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(
                  children: [
                    SliderTheme(
                      data: const SliderThemeData(
                        trackHeight: 3,
                        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
                        overlayShape: RoundSliderOverlayShape(overlayRadius: 14),
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
                        Obx(() => Text(_formatDuration(ctrl.position.value), style: const TextStyle(fontSize: 10, color: AppColors.textLight))),
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
                                decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.emerald),
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
                        Obx(() => Text(_formatDuration(ctrl.duration.value), style: const TextStyle(fontSize: 10, color: AppColors.textLight))),
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

  void _showFontSizeDialog(BuildContext context, QuranController ctrl) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Font Size', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Obx(() => Slider(
              value: ctrl.fontSize.value,
              min: 16,
              max: 36,
              divisions: 10,
              label: ctrl.fontSize.value.toStringAsFixed(0),
              activeColor: AppColors.emerald,
              onChanged: ctrl.updateFontSize,
            )),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
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
    final isBookmarked = ctrl.isBookmarked(ctrl.currentSurah.value!.number, ayah.number);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPlaying ? AppColors.emerald.withOpacity(0.08) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPlaying ? AppColors.emerald.withOpacity(0.3) : Colors.black.withOpacity(0.05), 
          width: isPlaying ? 1.5 : 0.5,
        ),
        boxShadow: isPlaying ? [
          BoxShadow(color: AppColors.emerald.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))
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
                  GestureDetector(
                    onTap: () => ctrl.toggleBookmark(ayah),
                    child: Icon(
                      isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                      size: 20,
                      color: isBookmarked ? AppColors.emerald : AppColors.textLight,
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => ctrl.playAyah(index),
                    child: Icon(
                      isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                      size: 20,
                      color: isPlaying ? AppColors.emerald : AppColors.emerald.withOpacity(0.4),
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
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: ctrl.fontSize.value,
              color: AppColors.textDark,
              height: 1.8,
              fontWeight: isPlaying ? FontWeight.w600 : FontWeight.normal,
            ),
          )),
          if (ayah.translation.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: Colors.black.withOpacity(0.06), height: 1, thickness: 0.5),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                ayah.translation,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 13, 
                  color: isPlaying ? AppColors.textDark : AppColors.textMid, 
                  height: 1.5,
                  fontStyle: isPlaying ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
