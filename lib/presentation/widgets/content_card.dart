import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import 'app_surfaces.dart';

/// Arabic text with meaning and source, with copy and share actions.
/// Used for duas and hadith.
class ContentCard extends StatelessWidget {
  final String? title;
  final String badge;
  final String arabic;
  final String meaning;
  final String? note;
  final String source;
  final VoidCallback onShare;
  final bool hero;
  final String? heroLabel;

  const ContentCard({
    super.key,
    this.title,
    required this.badge,
    required this.arabic,
    required this.meaning,
    this.note,
    required this.source,
    required this.onShare,
    this.hero = false,
    this.heroLabel,
  });

  void _copy() {
    Clipboard.setData(ClipboardData(text: '$arabic\n\n$meaning\n\n$source'));
    Get.snackbar('Copied'.tr, source, snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    final onHero = hero;
    final strong = onHero ? Colors.white : AppColors.textDark;
    final soft = onHero ? const Color(0xD9FFFFFF) : AppColors.textMid;
    final faint = onHero ? const Color(0x99FFFFFF) : AppColors.textLight;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 6),
      decoration: onHero ? AppSurfaces.hero() : AppSurfaces.card(radius: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              children: [
                if (heroLabel != null)
                  Text(heroLabel!, style: TextStyle(fontSize: 10, letterSpacing: 1.4, fontWeight: FontWeight.w800, color: AppColors.goldLight))
                else if (title != null)
                  Expanded(child: Text(title!, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: strong))),
                if (heroLabel != null) const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: onHero ? AppColors.gold.withValues(alpha: 0.25) : AppColors.emeraldPale,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(badge, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: onHero ? AppColors.goldLight : AppColors.emerald)),
                ),
              ],
            ),
          ),
          if (heroLabel != null && title != null) ...[
            const SizedBox(height: 6),
            Text(title!, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: strong)),
          ],
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              arabic,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: TextStyle(fontFamily: 'Amiri', fontSize: 21, height: 1.9, color: strong),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(meaning, style: TextStyle(fontSize: 14, height: 1.55, color: soft)),
          ),
          if (note != null) ...[
            const SizedBox(height: 8),
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: onHero ? const Color(0x1AFFFFFF) : AppColors.goldPale.withValues(alpha: ThemeColors.isDark ? 0.08 : 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, size: 15, color: onHero ? AppColors.goldLight : AppColors.gold),
                  const SizedBox(width: 6),
                  Expanded(child: Text(note!, style: TextStyle(fontSize: 12, height: 1.4, color: soft))),
                ],
              ),
            ),
          ],
          Row(
            children: [
              Expanded(
                child: Text(source, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: faint)),
              ),
              IconButton(
                tooltip: 'Copy'.tr,
                onPressed: _copy,
                icon: Icon(Icons.copy_rounded, size: 18, color: faint),
              ),
              IconButton(
                tooltip: 'Share as image'.tr,
                onPressed: onShare,
                icon: Icon(Icons.ios_share_rounded, size: 19, color: onHero ? AppColors.goldLight : AppColors.emerald),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Horizontal category filter.
class CategoryChips extends StatelessWidget {
  final List<(String id, String label)> items;
  final String selected;
  final ValueChanged<String> onSelect;

  const CategoryChips({super.key, required this.items, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final item = items[i];
          final isSelected = item.$1 == selected;
          return GestureDetector(
            onTap: () => onSelect(item.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.emerald : AppColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? AppColors.emerald : AppColors.emeraldMid),
              ),
              child: Text(
                item.$2,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : AppColors.textMid),
              ),
            ),
          );
        },
      ),
    );
  }
}

class SearchField extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  final TextEditingController controller;

  const SearchField({super.key, required this.hint, required this.onChanged, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: AppColors.emeraldPale, borderRadius: BorderRadius.circular(14)),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(fontSize: 14, color: AppColors.textDark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.textLight, fontSize: 13),
          prefixIcon: Icon(Icons.search_rounded, color: AppColors.textLight, size: 20),
          suffixIcon: ValueListenableBuilder(
            valueListenable: controller,
            builder: (_, value, __) => value.text.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    icon: Icon(Icons.close_rounded, size: 18, color: AppColors.textLight),
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                  ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );
  }
}
