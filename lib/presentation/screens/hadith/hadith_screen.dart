// lib/presentation/screens/hadith/hadith_screen.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class HadithScreen extends StatelessWidget {
  const HadithScreen({super.key});

  static const List<Map<String, String>> hadiths = [
    {
      'arabic': 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ',
      'translation': '"Actions are judged by intentions."',
      'source': 'Sahih Bukhari · 1',
      'category': 'Faith',
    },
    {
      'arabic': 'الْمُسْلِمُ مَنْ سَلِمَ الْمُسْلِمُونَ مِنْ لِسَانِهِ وَيَدِهِ',
      'translation': '"A Muslim is one from whose tongue and hand other Muslims are safe."',
      'source': 'Sahih Bukhari · 10',
      'category': 'Manners',
    },
    {
      'arabic': 'خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ',
      'translation': '"The best of you are those who learn the Quran and teach it."',
      'source': 'Sahih Bukhari · 5027',
      'category': 'Quran',
    },
    {
      'arabic': 'اتَّقِ اللَّهَ حَيْثُمَا كُنْتَ',
      'translation': '"Fear Allah wherever you are."',
      'source': 'Tirmidhi · 1987',
      'category': 'Patience',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Column(
          children: [
            Text('Hadith', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            Text('الحديث الشريف', style: TextStyle(fontFamily: 'Amiri', fontSize: 12, color: AppColors.textLight)),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Faith', 'Manners', 'Patience', 'Quran'].map((cat) => Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: cat == 'All' ? AppColors.emerald : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: cat == 'All' ? AppColors.emerald : Colors.black.withOpacity(0.1), width: 0.5),
                      ),
                      child: Text(cat, style: TextStyle(fontSize: 12, color: cat == 'All' ? Colors.white : AppColors.textMid, fontWeight: cat == 'All' ? FontWeight.w600 : FontWeight.normal)),
                    )).toList(),
              ),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: hadiths.length,
        itemBuilder: (ctx, i) {
          final h = hadiths[i];
          final isFirst = i == 0;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              gradient: isFirst
                  ? const LinearGradient(colors: [Color(0xFF1B6B3A), Color(0xFF0D4223)])
                  : null,
              color: isFirst ? null : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: isFirst ? null : Border.all(color: Colors.black.withOpacity(0.06), width: 0.5),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(isFirst ? 'HADITH OF THE DAY' : 'HADITH', style: TextStyle(fontSize: 9, color: isFirst ? const Color(0x80FFFFFF) : AppColors.textLight, letterSpacing: 1.2)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isFirst ? AppColors.gold.withOpacity(0.25) : AppColors.emeraldPale,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(h['category']!, style: TextStyle(fontSize: 9, color: isFirst ? AppColors.goldLight : AppColors.emerald, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(h['arabic']!, textDirection: TextDirection.rtl, textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Amiri', fontSize: 18, color: isFirst ? Colors.white : AppColors.textDark, height: 1.7)),
                const SizedBox(height: 6),
                Text(h['translation']!, style: TextStyle(fontSize: 13, color: isFirst ? const Color(0xBFFFFFFF) : AppColors.textMid, height: 1.5)),
                const SizedBox(height: 4),
                Text(h['source']!, style: TextStyle(fontSize: 10, color: isFirst ? const Color(0x66FFFFFF) : AppColors.textLight)),
              ],
            ),
          );
        },
      ),
    );
  }
}
