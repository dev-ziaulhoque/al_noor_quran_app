// lib/presentation/screens/qibla/qibla_screen.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/constants/app_colors.dart';

class QiblaScreen extends StatelessWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Qibla Direction', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                        Text('اتجاه القبلة', style: TextStyle(fontFamily: 'Amiri', fontSize: 13, color: AppColors.textLight)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Compass
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.emerald.withOpacity(0.2), width: 1.5),
                            ),
                          ),
                          Container(
                            width: 186,
                            height: 186,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.gold.withOpacity(0.25), width: 1),
                            ),
                          ),
                          Container(
                            width: 150,
                            height: 150,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Color(0xFFF8FCF9), AppColors.emeraldPale],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Center(child: Text('🕋', style: TextStyle(fontSize: 40))),
                          ),
                          // Compass needle
                          Transform.rotate(
                            angle: 35 * math.pi / 180,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(width: 4, height: 55, decoration: BoxDecoration(color: AppColors.emerald, borderRadius: BorderRadius.circular(4))),
                                Container(width: 4, height: 55, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4))),
                              ],
                            ),
                          ),
                          // N S E W
                          Positioned(top: 4, child: const Text('N', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.emerald))),
                          Positioned(bottom: 4, child: const Text('S', style: TextStyle(fontSize: 12, color: AppColors.textLight))),
                          Positioned(right: 4, top: 100, child: const Text('E', style: TextStyle(fontSize: 12, color: AppColors.textLight))),
                          Positioned(left: 4, top: 100, child: const Text('W', style: TextStyle(fontSize: 12, color: AppColors.textLight))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('278.4° NW', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.emerald)),
                    const SizedBox(height: 4),
                    const Text('Dhaka → Makkah', style: TextStyle(fontSize: 13, color: AppColors.textLight)),
                    const SizedBox(height: 16),
                    Container(
                      width: 60,
                      height: 1,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.transparent, AppColors.goldLight, Colors.transparent]),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Info grid
                    Row(
                      children: [
                        _InfoCard(label: 'Distance', value: '5,621 km'),
                        const SizedBox(width: 10),
                        _InfoCard(label: 'Direction', value: '278° NW'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _InfoCard(label: 'Location', value: 'Dhaka'),
                        const SizedBox(width: 10),
                        _InfoCard(label: 'Accuracy', value: 'High ✓', valueColor: AppColors.emerald),
                      ],
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

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _InfoCard({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black.withOpacity(0.06), width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
            const SizedBox(height: 2),
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: valueColor ?? AppColors.textDark)),
          ],
        ),
      ),
    );
  }
}
