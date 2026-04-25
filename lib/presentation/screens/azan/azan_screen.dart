// lib/presentation/screens/azan/azan_screen.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class AzanScreen extends StatelessWidget {
  const AzanScreen({super.key});

  static const List<Map<String, dynamic>> prayers = [
    {'name': 'Fajr', 'time': '4:52 AM', 'next': false},
    {'name': 'Sunrise', 'time': '6:10 AM', 'next': false},
    {'name': 'Dhuhr', 'time': '12:07 PM', 'next': false},
    {'name': 'Asr', 'time': '3:45 PM', 'next': true},
    {'name': 'Maghrib', 'time': '6:28 PM', 'next': false},
    {'name': 'Isha', 'time': '7:48 PM', 'next': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Column(children: [
          Text('Azan Times', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          Text('مواقيت الصلاة', style: TextStyle(fontFamily: 'Amiri', fontSize: 12, color: AppColors.textLight)),
        ]),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1B6B3A), Color(0xFF0D4223)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(children: [
              Text('NEXT PRAYER', style: TextStyle(fontSize: 9, color: Color(0x80FFFFFF), letterSpacing: 1.5)),
              SizedBox(height: 8),
              Text('Asr', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white)),
              Text('3:45 PM', style: TextStyle(fontSize: 18, color: AppColors.goldLight)),
              SizedBox(height: 8),
              Text('In 1 hour 23 minutes', style: TextStyle(fontSize: 13, color: Color(0xBFFFFFFF))),
            ]),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Color(0x0F000000), width: 0.5)),
            child: Column(
              children: prayers.asMap().entries.map((entry) {
                final i = entry.key;
                final p = entry.value;
                final isNext = p['next'] as bool;
                final isLast = i == prayers.length - 1;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isNext ? AppColors.emeraldPale : Colors.transparent,
                    border: isLast ? null : Border(bottom: BorderSide(color: const Color(0x0D000000), width: 0.5)),
                  ),
                  child: Row(children: [
                    Text(p['name'] as String, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isNext ? AppColors.emerald : AppColors.textDark)),
                    const Spacer(),
                    if (isNext) ...[
                      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppColors.emerald, borderRadius: BorderRadius.circular(20)), child: const Text('Next', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600))),
                      const SizedBox(width: 10),
                    ],
                    Text(p['time'] as String, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isNext ? AppColors.emerald : AppColors.textMid)),
                  ]),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
