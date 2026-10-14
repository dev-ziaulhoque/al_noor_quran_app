import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/controllers/quran_controller.dart';
import '../../app/routes/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/quran/reading_progress.dart';
import 'app_surfaces.dart';

/// Continue reading, today's ayahs against the goal, streak, and overall progress.
class QuranProgressCard extends StatelessWidget {
  const QuranProgressCard({super.key});

  static const List<int> goals = [5, 10, 20, 50, 100];

  void _continue(QuranController ctrl) {
    final lr = ctrl.lastRead.value;
    final surah = lr == null ? null : ctrl.surahList.firstWhereOrNull((s) => s.number == lr.surahNumber);
    if (surah == null) {
      Get.toNamed(AppRoutes.quranList);
      return;
    }
    ctrl.loadSurahAyahs(surah, startAyah: lr!.ayahNumber);
    Get.toNamed(AppRoutes.quranReader);
  }

  void _pickGoal(BuildContext context, QuranController ctrl) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheet) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Daily goal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              const SizedBox(height: 4),
              Text('New ayahs to read each day.', style: TextStyle(fontSize: 12, color: AppColors.textMid)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: goals.map((g) {
                  final selected = ctrl.dailyGoal.value == g;
                  return ChoiceChip(
                    label: Text('$g ayahs'),
                    selected: selected,
                    selectedColor: AppColors.emeraldPale,
                    labelStyle: TextStyle(
                      color: selected ? AppColors.emerald : AppColors.textDark,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (_) {
                      ctrl.setDailyGoal(g);
                      Navigator.of(sheet).pop();
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<QuranController>();

    return Obx(() {
      final lr = ctrl.lastRead.value;
      final today = ctrl.todayRead.value;
      final goal = ctrl.dailyGoal.value;
      final total = ctrl.totalRead.value;
      final streak = ctrl.streakDays.value;
      final percent = total / ReadingProgress.totalAyahs * 100;

      return Container(
        padding: const EdgeInsets.all(14),
        decoration: AppSurfaces.card(radius: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => _continue(ctrl),
              borderRadius: BorderRadius.circular(12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: AppColors.emeraldPale, borderRadius: BorderRadius.circular(12)),
                    child: Icon(Icons.menu_book_rounded, color: AppColors.emerald, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lr == null ? 'Start reading' : 'Continue ${lr.surahName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark),
                        ),
                        Text(
                          lr == null ? 'Open the Quran' : 'Ayah ${lr.ayahNumber}',
                          style: TextStyle(fontSize: 11, color: AppColors.textLight),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textLight),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('Today', style: TextStyle(fontSize: 11, color: AppColors.textLight)),
                const Spacer(),
                GestureDetector(
                  onTap: () => _pickGoal(context, ctrl),
                  child: Text(
                    '$today / $goal ayahs',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.emerald),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: goal == 0 ? 0 : (today / goal).clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: AppColors.emeraldPale,
                valueColor: AlwaysStoppedAnimation(AppColors.emerald),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _Fact(value: '$streak', label: streak == 1 ? 'day streak' : 'days streak'),
                _Fact(value: '$total', label: 'ayahs read'),
                _Fact(value: '${percent.toStringAsFixed(percent < 10 ? 1 : 0)}%', label: 'of the Quran'),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _Fact extends StatelessWidget {
  final String value;
  final String label;

  const _Fact({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          Text(label, style: TextStyle(fontSize: 10, color: AppColors.textLight)),
        ],
      ),
    );
  }
}
