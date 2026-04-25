// lib/presentation/screens/dua/dua_screen.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class DuaScreen extends StatelessWidget {
  const DuaScreen({super.key});

  static const List<Map<String, String>> categories = [
    {'icon': '🌙', 'title': 'Morning Duas', 'count': '12 duas'},
    {'icon': '☀️', 'title': 'Evening Duas', 'count': '10 duas'},
    {'icon': '🍽️', 'title': 'Eating & Drinking', 'count': '8 duas'},
    {'icon': '🚪', 'title': 'Entering Home', 'count': '4 duas'},
    {'icon': '🕌', 'title': 'After Prayer', 'count': '15 duas'},
    {'icon': '😴', 'title': 'Before Sleep', 'count': '7 duas'},
    {'icon': '🌧️', 'title': 'Seeking Forgiveness', 'count': '9 duas'},
    {'icon': '❤️', 'title': 'For Parents', 'count': '5 duas'},
  ];

  static const List<Map<String, String>> featured = [
    {
      'arabic': 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الآخِرَةِ حَسَنَةً',
      'translation': 'Our Lord, give us good in this world and good in the Hereafter.',
      'source': 'Al-Baqarah 2:201',
    },
    {
      'arabic': 'رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي',
      'translation': 'My Lord, expand my breast and ease my task for me.',
      'source': 'Ta-Ha 20:25-26',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Column(children: [
          Text('Dua Collection', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          Text('مجموعة الأدعية', style: TextStyle(fontFamily: 'Amiri', fontSize: 12, color: AppColors.textLight)),
        ]),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // Featured duas
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text('FEATURED DUAS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textLight, letterSpacing: 1)),
          ),
          ...featured.map((d) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black.withOpacity(0.06), width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(d['arabic']!, textDirection: TextDirection.rtl, textAlign: TextAlign.right,
                        style: const TextStyle(fontFamily: 'Amiri', fontSize: 18, color: AppColors.textDark, height: 1.7)),
                    const SizedBox(height: 8),
                    const Divider(height: 1, thickness: 0.5),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(d['translation']!, style: const TextStyle(fontSize: 12, color: AppColors.textMid, height: 1.5)),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: AppColors.emeraldPale, borderRadius: BorderRadius.circular(20)),
                        child: Text(d['source']!, style: const TextStyle(fontSize: 10, color: AppColors.emerald, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text('CATEGORIES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textLight, letterSpacing: 1)),
          ),
          // Category grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.6,
            ),
            itemCount: categories.length,
            itemBuilder: (ctx, i) {
              final cat = categories[i];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black.withOpacity(0.06), width: 0.5),
                ),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cat['icon']!, style: const TextStyle(fontSize: 24)),
                    const Spacer(),
                    Text(cat['title']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                    Text(cat['count']!, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
