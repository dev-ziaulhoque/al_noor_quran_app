// lib/presentation/screens/search/search_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/controllers/quran_controller.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

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
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Search Quran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(color: AppColors.emeraldPale, borderRadius: BorderRadius.circular(10)),
                    child: TextField(
                      onChanged: (val) => ctrl.searchQuery.value = val,
                      autofocus: false,
                      decoration: const InputDecoration(
                        hintText: 'Search surah, ayah or word…',
                        hintStyle: TextStyle(color: AppColors.textLight, fontSize: 13),
                        prefixIcon: Icon(Icons.search_rounded, color: AppColors.textLight, size: 20),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Recent
                    const Text('Recent Searches', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textLight, letterSpacing: 1)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ['Ar-Rahman', 'patience', 'Al-Ikhlas'].map((tag) => GestureDetector(
                            onTap: () => ctrl.searchQuery.value = tag,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.black.withOpacity(0.07), width: 0.5),
                              ),
                              child: Text(tag, style: const TextStyle(fontSize: 12, color: AppColors.textMid)),
                            ),
                          )).toList(),
                    ),
                    const SizedBox(height: 16),
                    // Surahs
                    const Text('All Surahs', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textLight, letterSpacing: 1)),
                    const SizedBox(height: 8),
                    Obx(() {
                      final list = ctrl.filteredSurahs.take(20).toList();
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black.withOpacity(0.06), width: 0.5),
                        ),
                        child: Column(
                          children: list.asMap().entries.map((entry) {
                            final i = entry.key;
                            final s = entry.value;
                            return GestureDetector(
                              onTap: () {
                                ctrl.loadSurahAyahs(s);
                                Get.toNamed(AppRoutes.quranReader);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                decoration: BoxDecoration(
                                  border: i < list.length - 1
                                      ? Border(bottom: BorderSide(color: Colors.black.withOpacity(0.04), width: 0.5))
                                      : null,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(color: AppColors.emeraldPale, borderRadius: BorderRadius.circular(6)),
                                      child: Center(child: Text('${s.number}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.emerald))),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(s.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                                          Text('${s.totalAyah} ayahs · ${s.revelationType}', style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
                                        ],
                                      ),
                                    ),
                                    Text(s.nameArabic, style: const TextStyle(fontFamily: 'Amiri', fontSize: 16, color: AppColors.emerald)),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
