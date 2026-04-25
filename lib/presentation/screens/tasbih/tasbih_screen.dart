// lib/presentation/screens/tasbih/tasbih_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import '../../../app/controllers/tasbih_controller.dart';
import '../../../core/constants/app_colors.dart';

class TasbihScreen extends StatelessWidget {
  const TasbihScreen({super.key});

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
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      children: [
                        Text('Digital Tasbih', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                        Text('سُبْحَانَ الله', style: TextStyle(fontFamily: 'Amiri', fontSize: 13, color: AppColors.textLight)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // Phrase selector
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Obx(() => Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.black.withOpacity(0.06), width: 0.5),
                          ),
                          child: Row(
                            children: TasbihController.phrases.asMap().entries.map((e) {
                              final isSelected = ctrl.selectedPhrase.value == e.key;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () => ctrl.selectPhrase(e.key),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppColors.emerald : Colors.transparent,
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Text(
                                      e.value['arabic']!,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontFamily: 'Amiri',
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                        color: isSelected ? Colors.white : AppColors.textMid,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        )),
                  ),
                  const SizedBox(height: 24),
                  // Circular counter
                  Obx(() => GestureDetector(
                        onTap: () {
                          ctrl.tap();
                          HapticFeedback.lightImpact();
                        },
                        child: SizedBox(
                          width: 200,
                          height: 200,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Progress ring
                              CustomPaint(
                                size: const Size(200, 200),
                                painter: _RingPainter(progress: ctrl.progress),
                              ),
                              // Inner circle
                              Container(
                                width: 140,
                                height: 140,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [Color(0xFF1B6B3A), Color(0xFF0D4223)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Center(
                                  child: Container(
                                    width: 110,
                                    height: 110,
                                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${ctrl.count.value}',
                                          style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w800, color: AppColors.emerald, height: 1),
                                        ),
                                        Text('of ${ctrl.targetCount.value}', style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                  const SizedBox(height: 20),
                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () { ctrl.tap(); HapticFeedback.lightImpact(); },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.emerald,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Text('+ Count', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: ctrl.reset,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.black.withOpacity(0.1), width: 0.5),
                          ),
                          child: const Text('Reset', style: TextStyle(color: AppColors.textMid)),
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
                            _StatCard(label: 'Today', value: '${ctrl.count.value}'),
                            const SizedBox(width: 10),
                            _StatCard(label: 'Streak', value: '${ctrl.streak.value}'),
                            const SizedBox(width: 10),
                            _StatCard(label: 'Total', value: ctrl.formattedTotal),
                          ],
                        )),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black.withOpacity(0.06), width: 0.5),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  const _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Background ring
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.gold.withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    // Progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..color = AppColors.gold.withOpacity(0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}
