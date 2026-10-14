import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/controllers/settings_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/quran_study_service.dart';

class AyahStudySection extends StatefulWidget {
  final int surah;
  final int ayah;

  const AyahStudySection({super.key, required this.surah, required this.ayah});

  @override
  State<AyahStudySection> createState() => _AyahStudySectionState();
}

class _AyahStudySectionState extends State<AyahStudySection> {
  bool _open = false;
  Future<AyahStudy>? _future;

  void _toggle() {
    setState(() {
      _open = !_open;
      final settings = Get.find<SettingsController>();
      _future ??= Get.find<QuranStudyService>().load(
        surah: widget.surah,
        ayah: widget.ayah,
        language: settings.studyLanguageCode,
        tafsirId: settings.tafsirId.value,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _toggle,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.emerald,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              visualDensity: VisualDensity.compact,
            ),
            icon: Icon(_open ? Icons.expand_less_rounded : Icons.menu_book_rounded, size: 18),
            label: Text(_open ? 'Hide study'.tr : 'Tafsir · word meaning · Shan-e-Nuzul'.tr),
          ),
        ),
        if (_open)
          FutureBuilder<AyahStudy>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: LinearProgressIndicator(color: AppColors.emerald, backgroundColor: AppColors.emeraldPale),
                );
              }
              if (snapshot.hasError || snapshot.data == null) {
                return Text(
                  'Could not load the study notes. The Arabic above is still the Tanzil Uthmani text.'.tr,
                  style: TextStyle(fontSize: 12, height: 1.4, color: AppColors.textMid),
                );
              }
              return _StudyBody(study: snapshot.data!, translationSource: settings.translationSourceLabel);
            },
          ),
      ],
    );
  }
}

class _StudyBody extends StatelessWidget {
  final AyahStudy study;
  final String translationSource;

  const _StudyBody({required this.study, required this.translationSource});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (study.explanation != null) ...[
          _Label(study.explanationSource ?? 'Tafsir'.tr),
          const SizedBox(height: 4),
          _LongText(study.explanation!),
          const SizedBox(height: 12),
        ],
        _Label('Word by word · Quran.com'.tr),
        const SizedBox(height: 6),
        if (study.words.isEmpty)
          Text(
            'Word meanings need a connection for this ayah.'.tr,
            style: TextStyle(fontSize: 12, height: 1.4, color: AppColors.textMid),
          )
        else
          Wrap(
          spacing: 6,
          runSpacing: 6,
          children: study.words
              .map((word) => Container(
                    constraints: const BoxConstraints(maxWidth: 140),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.emeraldPale,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          word.arabic,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontFamily: 'Amiri', fontSize: 16, color: AppColors.textDark),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          word.meaning,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11, height: 1.3, color: AppColors.textMid),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 12),
        _Label('Shan-e-Nuzul · Al-Wahidi'.tr),
        const SizedBox(height: 4),
        _OccasionText(study.shaneNuzul),
        const SizedBox(height: 6),
        Text(
          '${'Arabic text: Tanzil Uthmani. Translation:'.tr} $translationSource. ${'Shan-e-Nuzul is Al-Wahidi in English.'.tr}',
          style: TextStyle(fontSize: 10, height: 1.35, color: AppColors.textLight),
        ),
      ],
    );
  }
}

class _OccasionText extends StatelessWidget {
  final String? text;
  const _OccasionText(this.text);

  @override
  Widget build(BuildContext context) {
    final body = text ?? 'Al-Wahidi does not record a specific occasion for this ayah.'.tr;
    final style = TextStyle(fontSize: 13, height: 1.5, color: AppColors.textDark);
    if (body.length < 420) return Text(body, style: style);
    return SizedBox(
      height: 180,
      child: SingleChildScrollView(child: Text(body, style: style)),
    );
  }
}

/// Long tafsir passages collapse to a few lines until tapped.
class _LongText extends StatefulWidget {
  final String text;
  const _LongText(this.text);

  @override
  State<_LongText> createState() => _LongTextState();
}

class _LongTextState extends State<_LongText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(fontSize: 14, height: 1.6, color: AppColors.textDark);
    final long = widget.text.length > 360;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          maxLines: long && !_expanded ? 6 : null,
          overflow: long && !_expanded ? TextOverflow.fade : null,
          style: style,
        ),
        if (long)
          TextButton(
            onPressed: () => setState(() => _expanded = !_expanded),
            style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
            child: Text(_expanded ? 'Show less'.tr : 'Read full tafsir'.tr, style: TextStyle(color: AppColors.emerald, fontWeight: FontWeight.w700)),
          ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.emerald),
    );
  }
}
