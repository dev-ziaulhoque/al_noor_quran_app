// lib/presentation/screens/tasbih/tasbih_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/controllers/tasbih_controller.dart';
import '../../../core/constants/app_colors.dart';

class TasbihScreen extends StatelessWidget {
  TasbihScreen({super.key});

  Widget _buildStatCard(String label, String value) {
    final textDark = ThemeColors.textDark;
    final textLight = ThemeColors.textLight;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black.withValues(alpha: 0.06), width: 0.5),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: textDark)),
            Text(label, style: TextStyle(fontSize: 11, color: textLight)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TasbihController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: AppColors.card,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text('Digital Tasbih', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.getTextDark())),
                        Text('سُبْحَانَ الله', style: TextStyle(fontFamily: 'Amiri', fontSize: 13, color: AppColors.getTextLight())),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Dhikr Selector Chips
                    Obx(() => SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: ctrl.dhikrList.asMap().entries.map((e) {
                              final isSelected = ctrl.selectedDhikrIndex.value == e.key;
                              return GestureDetector(
                                onTap: () => ctrl.selectDhikr(e.key),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.emerald : AppColors.card,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected ? AppColors.emerald : AppColors.emeraldMid,
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Text(
                                    e.value.transliteration,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? Colors.white : AppColors.textDark,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        )),

                    const SizedBox(height: 16),

                    // Dhikr Arabic Banner
                    Obx(() {
                      final item = ctrl.currentDhikr;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.emeraldPale,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              item.arabic,
                              style: TextStyle(fontFamily: 'Amiri', fontSize: 24, color: AppColors.emerald),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.meaning,
                              style: TextStyle(fontSize: 11, color: AppColors.textMid, fontStyle: FontStyle.italic),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 24),

                    // Counter Circle (Interactive Tap)
                    Obx(() => GestureDetector(
                          onTap: ctrl.increment,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 220,
                                height: 220,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.emeraldPale,
                                  border: Border.all(color: AppColors.emerald.withValues(alpha: 0.3), width: 2),
                                ),
                              ),
                              Container(
                                width: 170,
                                height: 170,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.emerald.withValues(alpha: 0.15),
                                ),
                              ),
                              Container(
                                width: 130,
                                height: 130,
                                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.emerald),
                              ),
                              Container(
                                width: (110).toDouble(),
                                height: (110).toDouble(),
                                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.card),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${ctrl.count.value}',
                                      style: TextStyle(fontSize: 42, fontWeight: FontWeight.w800, color: AppPalette.gold, height: 1),
                                    ),
                                    Text('of ${ctrl.targetCount.value}', style: TextStyle(fontSize: 11, color: AppPalette.goldLight)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),

                    const SizedBox(height: 24),

                    // Target indicator & Reset button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: ctrl.reset,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: (24).toDouble(), vertical: (12).toDouble()),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: AppColors.gold.withValues(alpha: 0.4), width: 0.8),
                            ),
                            child: Text('Reset', style: TextStyle(color: AppPalette.gold)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Stats
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Obx(() => Row(
                            children: [
                              _buildStatCard('Today', '${ctrl.count.value}'),
                              SizedBox(width: 10),
                              _buildStatCard('Streak', '${ctrl.streak.value}'),
                              SizedBox(width: 10),
                              _buildStatCard('Total', ctrl.formattedTotal),
                            ],
                          )),
                    ),
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
