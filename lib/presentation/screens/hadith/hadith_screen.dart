// lib/presentation/screens/hadith/hadith_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/controllers/settings_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/content/hadiths.dart';
import '../../widgets/ayah_share_card.dart';
import '../../widgets/content_card.dart';
import '../../widgets/empty_state.dart';

class HadithScreen extends StatefulWidget {
  const HadithScreen({super.key});

  @override
  State<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen> {
  final _search = TextEditingController();
  String _category = 'All';
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Hadith> get _filtered {
    final q = _query.trim().toLowerCase();
    return Hadiths.all.where((h) {
      if (_category != 'All' && h.category != _category) return false;
      if (q.isEmpty) return true;
      return h.meaningEn.toLowerCase().contains(q) ||
          h.meaningBn.contains(q) ||
          h.arabic.contains(q) ||
          h.source.toLowerCase().contains(q);
    }).toList();
  }

  void _share(Hadith h, bool bangla) {
    showAyahShareSheet(
      context,
      AyahCardContent.text(
        arabic: h.arabic,
        meaning: h.meaning(bangla),
        heading: 'Hadith'.tr,
        reference: '${h.source} · ${h.grade}',
        fileId: 'hadith_${h.source.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_')}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    final today = Hadiths.forDate(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          children: [
            Text('Hadith'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            Text('الحديث الشريف', style: TextStyle(fontFamily: 'Amiri', fontSize: 12, color: AppColors.textLight)),
          ],
        ),
        backgroundColor: AppColors.card,
        elevation: 0,
      ),
      body: Obx(() {
        settings.appLanguage.value;
        settings.translationId.value;
        final bangla = settings.prefersBanglaMeaning;
        final list = _filtered;
        final showHero = _query.isEmpty && _category == 'All';
        return Column(
          children: [
            const SizedBox(height: 12),
            SearchField(
              controller: _search,
              hint: 'Search hadith by word or collection…'.tr,
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 10),
            CategoryChips(
              items: [for (final c in ['All', ...Hadiths.categories]) (c, c.tr)],
              selected: _category,
              onSelect: (c) => setState(() => _category = c),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: list.isEmpty
                  ? EmptyState(
                      icon: Icons.menu_book_rounded,
                      title: 'No hadith found'.tr,
                      message: 'Try another word, or a collection name like Bukhari or Muslim.'.tr,
                      actionLabel: 'Show all'.tr,
                      actionIcon: Icons.refresh_rounded,
                      onAction: () {
                        _search.clear();
                        setState(() {
                          _query = '';
                          _category = 'All';
                        });
                      },
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      children: [
                        if (showHero)
                          ContentCard(
                            hero: true,
                            heroLabel: 'HADITH OF THE DAY'.tr,
                            badge: today.category.tr,
                            arabic: today.arabic,
                            meaning: today.meaning(bangla),
                            source: '${today.source} · ${today.grade}',
                            onShare: () => _share(today, bangla),
                          ),
                        for (final h in list)
                          if (!showHero || h != today)
                            ContentCard(
                              badge: h.category.tr,
                              arabic: h.arabic,
                              meaning: h.meaning(bangla),
                              source: '${h.source} · ${h.grade}',
                              onShare: () => _share(h, bangla),
                            ),
                        const SizedBox(height: 4),
                        Text(
                          'Grades are those of the collection, or at-Tirmidhi\'s own wording. A short selection, not a new grading.'.tr,
                          style: TextStyle(fontSize: 11, height: 1.4, color: AppColors.textLight),
                        ),
                      ],
                    ),
            ),
          ],
        );
      }),
    );
  }
}
