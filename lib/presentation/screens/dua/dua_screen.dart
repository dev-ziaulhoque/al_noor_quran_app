// lib/presentation/screens/dua/dua_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/controllers/settings_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/content/duas.dart';
import '../../widgets/ayah_share_card.dart';
import '../../widgets/content_card.dart';
import '../../widgets/empty_state.dart';

class DuaScreen extends StatefulWidget {
  const DuaScreen({super.key});

  @override
  State<DuaScreen> createState() => _DuaScreenState();
}

class _DuaScreenState extends State<DuaScreen> {
  final _search = TextEditingController();
  String _category = 'all';
  String _query = '';

  @override
  void initState() {
    super.initState();
    final arg = Get.arguments;
    if (arg is Map && arg['category'] is String) _category = arg['category'] as String;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Dua> _filtered(bool bangla) {
    final q = _query.trim().toLowerCase();
    return Duas.all.where((d) {
      if (_category != 'all' && d.category != _category) return false;
      if (q.isEmpty) return true;
      return d.titleEn.toLowerCase().contains(q) ||
          d.titleBn.contains(q) ||
          d.meaningEn.toLowerCase().contains(q) ||
          d.meaningBn.contains(q) ||
          d.arabic.contains(q) ||
          d.source.toLowerCase().contains(q);
    }).toList();
  }

  void _share(Dua d, bool bangla) {
    showAyahShareSheet(
      context,
      AyahCardContent.text(
        arabic: d.arabic,
        meaning: d.meaning(bangla),
        heading: '${'Dua'.tr} · ${d.title(bangla)}',
        reference: d.source,
        fileId: 'dua_${d.id}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          children: [
            Text('Dua & Adhkar'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            Text('الأدعية والأذكار', style: TextStyle(fontFamily: 'Amiri', fontSize: 12, color: AppColors.textLight)),
          ],
        ),
        backgroundColor: AppColors.card,
        elevation: 0,
      ),
      body: Obx(() {
        settings.appLanguage.value;
        settings.translationId.value;
        final bangla = settings.prefersBanglaMeaning;
        final list = _filtered(bangla);
        return Column(
          children: [
            const SizedBox(height: 12),
            SearchField(
              controller: _search,
              hint: 'Search dua by name, meaning or source…'.tr,
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 10),
            CategoryChips(
              items: [
                ('all', 'All'.tr),
                for (final c in Duas.categories) (c.id, '${c.emoji} ${c.name(bangla)}'),
              ],
              selected: _category,
              onSelect: (id) => setState(() => _category = id),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: list.isEmpty
                  ? EmptyState(
                      icon: Icons.volunteer_activism_rounded,
                      title: 'No dua found'.tr,
                      message: 'Try another word, or look in a different category.'.tr,
                      actionLabel: 'Show all duas'.tr,
                      actionIcon: Icons.refresh_rounded,
                      onAction: () {
                        _search.clear();
                        setState(() {
                          _query = '';
                          _category = 'all';
                        });
                      },
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      itemCount: list.length,
                      itemBuilder: (_, i) {
                        final d = list[i];
                        final cat = Duas.categories.firstWhere((c) => c.id == d.category);
                        return ContentCard(
                          title: d.title(bangla),
                          badge: cat.name(bangla),
                          arabic: d.arabic,
                          meaning: d.meaning(bangla),
                          note: d.note(bangla),
                          source: d.source,
                          onShare: () => _share(d, bangla),
                        );
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }
}
