import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/controllers/quran_controller.dart';
import '../../app/controllers/settings_controller.dart';
import '../../app/routes/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/quran/arabic_fonts.dart';
import '../../core/quran/quran_catalog.dart';

Future<void> showReaderSettings(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.card,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => const _ReaderSettingsSheet(),
  );
}

class _ReaderSettingsSheet extends StatelessWidget {
  const _ReaderSettingsSheet();

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    final quran = Get.find<QuranController>();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.78,
      maxChildSize: 0.94,
      minChildSize: 0.4,
      builder: (context, scroll) => Obx(() {
        final font = ArabicFontOption.at(settings.arabicFont.value);
        final size = quran.fontSize.value;
        return ListView(
          controller: scroll,
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          children: [
            const SheetHandle(),
            const SizedBox(height: 12),
            Text('Reading settings'.tr, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              decoration: BoxDecoration(color: AppColors.goldPale.withValues(alpha: ThemeColors.isDark ? 0.08 : 1), borderRadius: BorderRadius.circular(16)),
              child: Text(
                'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: font.style(size: size, color: AppColors.emerald),
              ),
            ),
            const SizedBox(height: 14),
            _Label('Arabic font'.tr),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < ArabicFontOption.all.length; i++)
                  _Pill(
                    label: ArabicFontOption.all[i].name,
                    selected: settings.arabicFont.value == i,
                    onTap: () => settings.selectArabicFont(i),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _Label('Arabic size'.tr),
                const Spacer(),
                Text(size.toStringAsFixed(0), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.emerald)),
              ],
            ),
            Slider(
              value: size,
              min: 16,
              max: 40,
              divisions: 12,
              activeColor: AppColors.emerald,
              onChanged: quran.updateFontSize,
            ),
            const SizedBox(height: 4),
            _ChoiceRow(
              icon: Icons.translate_rounded,
              title: 'Translation'.tr,
              value: settings.translationOption.label,
              onTap: () => showTranslationPicker(context),
            ),
            _ChoiceRow(
              icon: Icons.record_voice_over_rounded,
              title: 'Qari (reciter)'.tr,
              value: settings.reciterOption.name,
              onTap: () => showReciterPicker(context),
            ),
            _ChoiceRow(
              icon: Icons.auto_stories_rounded,
              title: 'Tafsir (explanation)'.tr,
              value: settings.tafsirOption?.name ?? 'Off'.tr,
              onTap: () => showTafsirPicker(context),
            ),
            _ChoiceRow(
              icon: Icons.download_for_offline_rounded,
              title: 'Offline downloads'.tr,
              value: 'Text, tafsir and recitation'.tr,
              onTap: () {
                Navigator.of(context).pop();
                Get.toNamed(AppRoutes.downloads);
              },
            ),
          ],
        );
      }),
    );
  }
}

Future<void> showTranslationPicker(BuildContext context) {
  final settings = Get.find<SettingsController>();
  return _showOptionList(
    context,
    title: 'Translation'.tr,
    subtitle: 'Arabic stays Tanzil Uthmani. Only the meaning changes.'.tr,
    itemCount: QuranCatalog.translations.length,
    itemBuilder: (i) {
      final t = QuranCatalog.translations[i];
      return _OptionData(id: t.id, title: t.language, subtitle: t.translator);
    },
    selected: () => settings.translationId.value,
    onSelect: settings.selectTranslation,
  );
}

Future<void> showReciterPicker(BuildContext context) {
  final settings = Get.find<SettingsController>();
  return _showOptionList(
    context,
    title: 'Qari (reciter)'.tr,
    subtitle: 'Recitation plays ayah by ayah, with controls in the notification.'.tr,
    itemCount: QuranCatalog.reciters.length,
    itemBuilder: (i) {
      final r = QuranCatalog.reciters[i];
      return _OptionData(id: r.id, title: r.name, subtitle: r.style);
    },
    selected: () => settings.reciterId.value,
    onSelect: settings.selectReciter,
  );
}

Future<void> showTafsirPicker(BuildContext context) {
  final settings = Get.find<SettingsController>();
  return _showOptionList(
    context,
    title: 'Tafsir (explanation)'.tr,
    subtitle: 'Shown under each ayah when you open Study. Published tafsir only.'.tr,
    itemCount: QuranCatalog.tafsirs.length + 1,
    itemBuilder: (i) {
      if (i == QuranCatalog.tafsirs.length) {
        return _OptionData(id: QuranCatalog.noTafsir, title: 'Off'.tr, subtitle: 'Word meaning and Shan-e-Nuzul only'.tr);
      }
      final t = QuranCatalog.tafsirs[i];
      return _OptionData(id: t.id, title: t.name, subtitle: '${t.languageCode == 'bn' ? 'বাংলা' : 'English'} · ${t.author}');
    },
    selected: () => settings.tafsirId.value,
    onSelect: settings.selectTafsir,
  );
}

class _OptionData {
  final String id;
  final String title;
  final String subtitle;
  const _OptionData({required this.id, required this.title, required this.subtitle});
}

Future<void> _showOptionList(
  BuildContext context, {
  required String title,
  required String subtitle,
  required int itemCount,
  required _OptionData Function(int) itemBuilder,
  required String Function() selected,
  required void Function(String) onSelect,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.card,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (sheet) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.92,
      builder: (context, scroll) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SheetHandle(),
                const SizedBox(height: 12),
                Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(fontSize: 12, height: 1.4, color: AppColors.textMid)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: scroll,
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
              itemCount: itemCount,
              itemBuilder: (_, i) {
                final item = itemBuilder(i);
                final isSelected = selected() == item.id;
                return ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  tileColor: isSelected ? AppColors.emeraldPale : null,
                  title: Text(item.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isSelected ? AppColors.emerald : AppColors.textDark)),
                  subtitle: Text(item.subtitle, style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                  trailing: isSelected ? Icon(Icons.check_circle_rounded, color: AppColors.emerald) : null,
                  onTap: () {
                    onSelect(item.id);
                    Navigator.of(sheet).pop();
                  },
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 38,
        height: 4,
        decoration: BoxDecoration(color: AppColors.textLight.withValues(alpha: 0.45), borderRadius: BorderRadius.circular(4)),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMid));
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Pill({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.emerald : AppColors.emeraldPale,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: selected ? Colors.white : AppColors.emerald)),
      ),
    );
  }
}

class _ChoiceRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  const _ChoiceRow({required this.icon, required this.title, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: AppColors.emeraldPale, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, size: 19, color: AppColors.emerald),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }
}
