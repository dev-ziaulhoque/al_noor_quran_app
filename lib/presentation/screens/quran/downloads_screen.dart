import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/controllers/quran_controller.dart';
import '../../../app/controllers/quran_download_controller.dart';
import '../../../app/controllers/settings_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/i18n/locale_text.dart';
import '../../widgets/app_surfaces.dart';
import '../../widgets/quran_settings_sheet.dart';

class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  String _size(int bytes) {
    if (bytes < 1024 * 1024) return '${LocaleText.digits((bytes / 1024).toStringAsFixed(0))} KB';
    return '${LocaleText.digits((bytes / 1024 / 1024).toStringAsFixed(1))} MB';
  }

  @override
  Widget build(BuildContext context) {
    final dl = Get.find<QuranDownloadController>();
    final settings = Get.find<SettingsController>();
    final quran = Get.find<QuranController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Offline downloads'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.card,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: dl.refreshStatus,
        child: Obx(() {
          final textProgress = dl.progress['text'];
          final tafsirProgress = dl.progress['tafsir'];
          final tafsir = settings.tafsirOption;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: AppSurfaces.hero(),
                child: Row(
                  children: [
                    const Icon(Icons.download_for_offline_rounded, color: Colors.white, size: 34),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Read and listen without internet'.tr,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                          const SizedBox(height: 4),
                          Text(
                            '${'Saved on this phone'.tr}: ${_size(dl.storageBytes.value)}',
                            style: const TextStyle(fontSize: 12, color: Color(0xCCFFFFFF)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (dl.lastError.value.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(dl.lastError.value, style: const TextStyle(fontSize: 12, color: Color(0xFFC0392B))),
              ],
              const SizedBox(height: 16),
              _DownloadCard(
                icon: Icons.menu_book_rounded,
                title: 'Quran text and translation'.tr,
                subtitle: '${'Arabic (Tanzil Uthmani)'.tr} + ${settings.translationOption.label}',
                status: '${LocaleText.digits(dl.translationSaved.value < dl.arabicSaved.value ? dl.translationSaved.value : dl.arabicSaved.value)} / ${LocaleText.digits(114)} ${'surahs'.tr}',
                note: 'About 3 MB. Change the translation to download another language.'.tr,
                done: dl.textComplete,
                progress: textProgress,
                onDownload: dl.downloadText,
                onCancel: () => dl.cancel('text'),
                onDelete: dl.translationSaved.value > 0 ? dl.deleteText : null,
                onChange: () => showTranslationPicker(context),
              ),
              const SizedBox(height: 12),
              _DownloadCard(
                icon: Icons.auto_stories_rounded,
                title: 'Tafsir'.tr,
                subtitle: tafsir == null ? 'Tafsir is turned off'.tr : '${tafsir.name} · ${tafsir.author}',
                status: tafsir == null ? '' : '${LocaleText.digits(dl.tafsirSaved.value)} / ${LocaleText.digits(114)} ${'surahs'.tr}',
                note: tafsir?.id.contains('kaseer') == true || tafsir?.id.contains('kathir') == true
                    ? 'Ibn Kathir is large, about 60 MB or more. Use Wi-Fi.'.tr
                    : 'About 10–15 MB. Use Wi-Fi if you can.'.tr,
                done: dl.tafsirSaved.value >= 114,
                progress: tafsirProgress,
                onDownload: tafsir == null ? null : dl.downloadTafsir,
                onCancel: () => dl.cancel('tafsir'),
                onDelete: dl.tafsirSaved.value > 0 ? dl.deleteTafsir : null,
                onChange: () => showTafsirPicker(context),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Recitation audio'.tr, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                        Text(dl.reciterName, style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => showReciterPicker(context),
                    icon: Icon(Icons.swap_horiz_rounded, size: 18, color: AppColors.emerald),
                    label: Text('Change'.tr, style: TextStyle(color: AppColors.emerald, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Download a surah to listen offline. Downloaded audio plays from the phone.'.tr,
                style: TextStyle(fontSize: 12, height: 1.4, color: AppColors.textMid),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: AppSurfaces.card(radius: 18),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    for (final surah in quran.surahList)
                      _AudioRow(
                        number: surah.number,
                        name: surah.name,
                        arabic: surah.nameArabic,
                        total: surah.totalAyah,
                        saved: dl.audioSaved[surah.number] ?? 0,
                        progress: dl.progress['audio:${surah.number}'],
                        onDownload: () => dl.downloadSurahAudio(surah.number),
                        onCancel: () => dl.cancel('audio:${surah.number}'),
                        onDelete: () => dl.deleteSurahAudio(surah.number),
                      ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _DownloadCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String status;
  final String note;
  final bool done;
  final double? progress;
  final VoidCallback? onDownload;
  final VoidCallback onCancel;
  final VoidCallback? onDelete;
  final VoidCallback onChange;

  const _DownloadCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.note,
    required this.done,
    required this.progress,
    required this.onDownload,
    required this.onCancel,
    required this.onDelete,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final running = progress != null;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppSurfaces.card(radius: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(color: AppColors.emeraldPale, borderRadius: BorderRadius.circular(12)),
                child: Icon(done ? Icons.check_rounded : icon, color: AppColors.emerald),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                    Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                  ],
                ),
              ),
              if (status.isNotEmpty)
                Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.emerald)),
            ],
          ),
          const SizedBox(height: 10),
          if (running) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress == 0 ? null : progress,
                minHeight: 6,
                backgroundColor: AppColors.emeraldPale,
                valueColor: AlwaysStoppedAnimation(AppColors.emerald),
              ),
            ),
            const SizedBox(height: 6),
          ],
          Text(note, style: TextStyle(fontSize: 11, height: 1.35, color: AppColors.textMid)),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton(onPressed: onChange, child: Text('Change'.tr, style: TextStyle(color: AppColors.emerald))),
              if (onDelete != null && !running)
                TextButton(onPressed: onDelete, child: Text('Delete'.tr, style: TextStyle(color: AppColors.textMid))),
              const Spacer(),
              if (running)
                OutlinedButton(onPressed: onCancel, child: Text('Cancel'.tr))
              else if (!done && onDownload != null)
                FilledButton.icon(
                  onPressed: onDownload,
                  icon: const Icon(Icons.download_rounded, size: 18, color: Colors.white),
                  label: Text('Download'.tr, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.emerald,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                )
              else if (done)
                Row(
                  children: [
                    Icon(Icons.offline_pin_rounded, size: 18, color: AppColors.emerald),
                    const SizedBox(width: 4),
                    Text('Available offline'.tr, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.emerald)),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AudioRow extends StatelessWidget {
  final int number;
  final String name;
  final String arabic;
  final int total;
  final int saved;
  final double? progress;
  final VoidCallback onDownload;
  final VoidCallback onCancel;
  final VoidCallback onDelete;

  const _AudioRow({
    required this.number,
    required this.name,
    required this.arabic,
    required this.total,
    required this.saved,
    required this.progress,
    required this.onDownload,
    required this.onCancel,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final complete = total > 0 && saved >= total;
    final running = progress != null;
    Widget trailing;
    if (running) {
      trailing = SizedBox(
        width: 40,
        height: 40,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(value: progress == 0 ? null : progress, strokeWidth: 3, color: AppColors.emerald),
            IconButton(icon: const Icon(Icons.close_rounded, size: 16), onPressed: onCancel, color: AppColors.textMid),
          ],
        ),
      );
    } else if (complete) {
      trailing = IconButton(
        icon: Icon(Icons.delete_outline_rounded, color: AppColors.textLight),
        tooltip: 'Delete'.tr,
        onPressed: onDelete,
      );
    } else {
      trailing = IconButton(
        icon: Icon(Icons.download_rounded, color: AppColors.emerald),
        tooltip: 'Download'.tr,
        onPressed: onDownload,
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.textLight.withValues(alpha: 0.12)))),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(LocaleText.digits(number), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.emerald)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                Text(
                  complete
                      ? 'Downloaded'.tr
                      : saved > 0
                          ? '${LocaleText.digits(saved)} / ${LocaleText.digits(total)} ${'ayahs'.tr}'
                          : '${LocaleText.digits(total)} ${'ayahs'.tr}',
                  style: TextStyle(fontSize: 11, color: complete ? AppColors.emerald : AppColors.textLight),
                ),
              ],
            ),
          ),
          Text(arabic, style: TextStyle(fontFamily: 'Amiri', fontSize: 15, color: AppColors.emerald)),
          const SizedBox(width: 6),
          trailing,
        ],
      ),
    );
  }
}
