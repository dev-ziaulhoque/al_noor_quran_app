// lib/presentation/screens/quran/quran_list_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/controllers/quran_controller.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/models.dart';

class QuranListScreen extends StatelessWidget {
  const QuranListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<QuranController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header ───
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'القرآن الكريم',
                    style: TextStyle(fontFamily: 'Amiri', fontSize: 22, color: AppColors.emerald),
                  ),
                  const Text(
                    'The Holy Quran',
                    style: TextStyle(fontSize: 13, color: AppColors.textLight),
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
                        hintText: 'Search surah, name or number…',
                        hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 13),
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textLight, size: 20),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ─── List ───
            Expanded(
              child: Obx(() {
                if (ctrl.isLoadingSurahs.value) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.emerald));
                }
                if (ctrl.error.value.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.textLight),
                        const SizedBox(height: 12),
                        Text(ctrl.error.value, style: const TextStyle(color: AppColors.textMid)),
                        const SizedBox(height: 12),
                        ElevatedButton(onPressed: ctrl.loadSurahs, child: const Text('Retry')),
                      ],
                    ),
                  );
                }
                final list = ctrl.filteredSurahs;
                return ListView.builder(
                  itemCount: list.length,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  itemBuilder: (ctx, i) => _SurahTile(surah: list[i]),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _SurahTile extends StatelessWidget {
  final SurahModel surah;
  const _SurahTile({required this.surah});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<QuranController>();
    return GestureDetector(
      onTap: () {
        ctrl.loadSurahAyahs(surah);
        Get.toNamed(AppRoutes.quranReader);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 1),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Colors.black.withOpacity(0.04), width: 0.5)),
        ),
        child: Row(
          children: [
            // Number badge
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.emeraldPale,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${surah.number}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.emerald),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Title
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(surah.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                  Text(
                    '${surah.totalAyah} ayahs · ${surah.revelationType}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textLight),
                  ),
                ],
              ),
            ),
            // Arabic name
            Text(
              surah.nameArabic,
              style: const TextStyle(fontFamily: 'Amiri', fontSize: 18, color: AppColors.emerald),
            ),
          ],
        ),
      ),
    );
  }
}
