import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/controllers/settings_controller.dart';
import '../../app/routes/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../data/content/daily_ayahs.dart';
import '../../data/services/storage_service.dart';
import 'ayah_share_card.dart';
import 'islamic_art.dart';

class AyahOfDayCard extends StatefulWidget {
  const AyahOfDayCard({super.key});

  @override
  State<AyahOfDayCard> createState() => _AyahOfDayCardState();
}

class _AyahOfDayCardState extends State<AyahOfDayCard> {
  int _look = 0;
  int _font = 0;
  int _art = 0;

  @override
  void initState() {
    super.initState();
    final storage = Get.find<StorageService>();
    _look = storage.getAyahCardBackground();
    _font = storage.getAyahCardFont();
    _art = storage.getAyahCardArt();
  }

  void _reloadStyle() {
    final storage = Get.find<StorageService>();
    setState(() {
      _look = storage.getAyahCardBackground();
      _font = storage.getAyahCardFont();
      _art = storage.getAyahCardArt();
    });
  }

  AyahCardContent _content(DailyAyah ayah, bool bangla) {
    final space = ayah.reference.lastIndexOf(' ');
    final surahName = space > 0 ? ayah.reference.substring(0, space) : ayah.reference;
    return AyahCardContent(
      arabic: ayah.arabic,
      meaning: bangla ? ayah.meaningBn : ayah.meaningEn,
      surahName: surahName,
      surahNumber: ayah.surah,
      ayahNumber: ayah.ayah,
      heading: 'Ayah of the day'.tr,
    );
  }

  Future<void> _share(DailyAyah ayah, bool bangla) async {
    await showAyahShareSheet(context, _content(ayah, bangla));
    if (mounted) _reloadStyle();
  }

  @override
  Widget build(BuildContext context) {
    final ayah = DailyAyahs.forDate(DateTime.now());
    final settings = Get.find<SettingsController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          settings.translationId.value;
          settings.appLanguage.value;
          final bangla = settings.prefersBanglaMeaning;
          return GestureDetector(
            onTap: () => _share(ayah, bangla),
            child: AyahShareCard(
              content: _content(ayah, bangla),
              lookIndex: _look,
              fontIndex: _font,
              artIndex: _art,
              compact: true,
            ),
          );
        }),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _SmallAction(
              icon: Icons.text_fields_rounded,
              tooltip: '${'Arabic font'.tr}: ${AyahCardFont.all[_font % AyahCardFont.all.length].name}',
              onTap: () {
                setState(() => _font = (_font + 1) % AyahCardFont.all.length);
                Get.find<StorageService>().saveAyahCardFont(_font);
              },
            ),
            _SmallAction(
              icon: Icons.palette_outlined,
              tooltip: 'Card color'.tr,
              onTap: () {
                setState(() => _look = (_look + 1) % AyahCardLook.all.length);
                Get.find<StorageService>().saveAyahCardBackground(_look);
              },
            ),
            _SmallAction(
              icon: Icons.auto_awesome_rounded,
              tooltip: 'Islamic art'.tr,
              onTap: () {
                setState(() => _art = (_art + 1) % IslamicArt.values.length);
                Get.find<StorageService>().saveAyahCardArt(_art);
              },
            ),
            _SmallAction(
              icon: Icons.edit_note_rounded,
              tooltip: 'Reflect'.tr,
              onTap: () => Get.toNamed(AppRoutes.reflectEditor, arguments: {
                'surah': ayah.surah,
                'ayah': ayah.ayah,
                'reference': ayah.reference,
              }),
            ),
            _SmallAction(
              icon: Icons.share_rounded,
              tooltip: 'Share'.tr,
              onTap: () => _share(ayah, settings.prefersBanglaMeaning),
            ),
          ],
        ),
      ],
    );
  }
}

class _SmallAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _SmallAction({required this.icon, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      iconSize: 18,
      icon: Icon(icon, color: AppColors.textMid),
    );
  }
}
