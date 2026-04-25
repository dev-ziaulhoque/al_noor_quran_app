// lib/presentation/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/controllers/quran_controller.dart';
import '../../../app/controllers/settings_controller.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/models.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final qCtrl = Get.find<QuranController>();
    final sCtrl = Get.find<SettingsController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Top Bar ───
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'السلام عليكم',
                        style: TextStyle(fontSize: 11, color: AppColors.textLight, fontFamily: 'Amiri'),
                      ),
                      Text(
                        _greeting(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  Obx(() => Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [AppColors.emeraldLight, AppColors.emerald],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            sCtrl.userName.value.isNotEmpty
                                ? sCtrl.userName.value[0].toUpperCase()
                                : 'أ',
                            style: const TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )),
                ],
              ),
              const SizedBox(height: 16),

              // ─── Verse of the Day ───
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B6B3A), Color(0xFF0D4223)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'VERSE OF THE DAY',
                      style: TextStyle(fontSize: 9, color: Color(0x80FFFFFF), letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ',
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 20,
                        color: Colors.white,
                        height: 1.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '"Whoever relies upon Allah — He is sufficient."',
                      style: TextStyle(fontSize: 12, color: Color(0xBFFFFFFF), height: 1.5),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'At-Talaq 65:3',
                      style: TextStyle(fontSize: 11, color: AppColors.goldLight, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ─── Prayer Times ───
              const Text(
                'Prayer Times',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              _PrayerTimesRow(),
              const SizedBox(height: 16),

              // ─── Continue Reading ───
              Obx(() {
                final lr = qCtrl.lastRead.value;
                if (lr == null) return const SizedBox.shrink();
                return GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.quranList),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black.withOpacity(0.06), width: 0.5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.emeraldPale,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text('يس', style: TextStyle(fontFamily: 'Amiri', fontSize: 14, color: AppColors.emerald)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Continue: ${lr.surahName}',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
                              ),
                              Text(
                                'Ayah ${lr.ayahNumber}',
                                style: const TextStyle(fontSize: 11, color: AppColors.textLight),
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: 0.63,
                                  backgroundColor: AppColors.emeraldMid,
                                  valueColor: const AlwaysStoppedAnimation(AppColors.emerald),
                                  minHeight: 3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textLight),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),

              // ─── Quick Actions Grid ───
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.5,
                children: [
                  _QuickCard(icon: Icons.format_quote_rounded, title: 'Hadith', sub: 'Daily wisdom', onTap: () => Get.toNamed(AppRoutes.hadith)),
                  _QuickCard(icon: Icons.auto_awesome_rounded, title: 'Dua', sub: '250+ duas', onTap: () => Get.toNamed(AppRoutes.dua)),
                  _QuickCard(icon: Icons.repeat_rounded, title: 'Tasbih', sub: 'Counter', onTap: () => Get.toNamed(AppRoutes.tasbih)),
                  _QuickCard(icon: Icons.star_rounded, title: 'Tracker', sub: '7 day streak', onTap: () => Get.toNamed(AppRoutes.tracker)),
                ],
              ),
              const SizedBox(height: 10),

              // ─── Bottom Quick Tiles ───
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.qibla),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1B6B3A), Color(0xFF0D4223)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Column(
                          children: [
                            Text('🕋', style: TextStyle(fontSize: 20)),
                            SizedBox(height: 4),
                            Text('Qibla', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.azan),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.goldPale,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.gold.withOpacity(0.3), width: 0.5),
                        ),
                        child: const Column(
                          children: [
                            Text('🕌', style: TextStyle(fontSize: 20)),
                            SizedBox(height: 4),
                            Text('Azan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF412402))),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrayerTimesRow extends StatelessWidget {
  final prayers = const [
    {'name': 'Fajr', 'time': '4:52', 'active': false},
    {'name': 'Dhuhr', 'time': '12:07', 'active': false},
    {'name': 'Asr', 'time': '3:45', 'active': true},
    {'name': 'Maghrib', 'time': '6:28', 'active': false},
    {'name': 'Isha', 'time': '7:48', 'active': false},
  ];

  const _PrayerTimesRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: prayers
          .map((p) => Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 4),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: p['active'] == true ? AppColors.emeraldPale : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: p['active'] == true
                          ? AppColors.emeraldLight
                          : Colors.black.withOpacity(0.06),
                      width: p['active'] == true ? 0.8 : 0.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        p['name'] as String,
                        style: TextStyle(
                          fontSize: 9,
                          color: p['active'] == true ? AppColors.emerald : AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        p['time'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: p['active'] == true ? AppColors.emerald : AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String sub;
  final VoidCallback onTap;

  const _QuickCard({required this.icon, required this.title, required this.sub, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black.withOpacity(0.06), width: 0.5),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.emerald),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                Text(sub, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
