// lib/presentation/screens/settings/settings_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../app/controllers/prayer_controller.dart';
import '../../../app/controllers/settings_controller.dart';
import '../../../app/controllers/tasbih_controller.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/i18n/locale_text.dart';
import '../../../core/quran/arabic_fonts.dart';
import '../../../core/utils/hijri_date.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/app_surfaces.dart';
import '../../../core/prayer/prayer_options.dart';
import '../../../data/services/azan_audio_service.dart';
import '../../../data/services/notification_service.dart';
import '../../../data/services/storage_service.dart';
import '../../widgets/location_picker.dart';
import '../../widgets/prayer_pickers.dart';
import '../../widgets/quran_settings_sheet.dart';

TextStyle createTextStyle({
  required double fontSize,
  required Color color,
  required FontWeight fontWeight,
  double? letterSpacing,
}) {
  return TextStyle(
    fontSize: fontSize,
    color: color,
    fontWeight: fontWeight,
    letterSpacing: letterSpacing,
  );
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SettingsController>();
    final tCtrl = Get.find<TasbihController>();

    return Scaffold(
      backgroundColor: ThemeColors.getBackground(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ─── Profile Header ───
              Obx(() {
                final primary = ThemeColors.getEmerald();
                final nameVal = ctrl.userName.value;
                final streakVal = tCtrl.streak.value;
                final totalVal = tCtrl.formattedTotal;
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primary, primary.withValues(alpha: 0.75)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.gold.withValues(alpha: 0.3),
                          border: Border.all(color: AppColors.goldLight, width: 1.5),
                        ),
                        child: Center(
                          child: Text(
                            nameVal.isNotEmpty ? nameVal[0].toUpperCase() : 'أ',
                            style: const TextStyle(fontFamily: 'Amiri', fontSize: 22, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(nameVal.isEmpty ? 'Add your name'.tr : nameVal,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                            GestureDetector(
                              onTap: () => _editName(context, ctrl),
                              child: Text('Tap to edit name ›'.tr, style: const TextStyle(fontSize: 11, color: Color(0x80FFFFFF))),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Text(LocaleText.digits(streakVal), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                          Text('Streak'.tr, style: const TextStyle(fontSize: 9, color: Color(0x80FFFFFF))),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Column(
                        children: [
                          Text(LocaleText.digits(totalVal), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                          Text('Tasbihat'.tr, style: const TextStyle(fontSize: 9, color: Color(0x80FFFFFF))),
                        ],
                      ),
                    ],
                  ),
                );
              }),

              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── Language ───
                    _SectionLabel('Language'.tr),
                    _SettingsCard(children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Obx(() {
                          final code = ctrl.appLanguage.value;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('App language'.tr, style: createTextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: ThemeColors.getTextDark())),
                              const SizedBox(height: 2),
                              Text('Menus and labels. The Quran translation is set separately.'.tr,
                                  style: createTextStyle(fontSize: 11, fontWeight: FontWeight.normal, color: ThemeColors.getTextLight())),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(child: _ModeChip(label: 'English', selected: code == 'en', onTap: () => ctrl.setAppLanguage('en'))),
                                  const SizedBox(width: 8),
                                  Expanded(child: _ModeChip(label: 'বাংলা', selected: code == 'bn', onTap: () => ctrl.setAppLanguage('bn'))),
                                ],
                              ),
                            ],
                          );
                        }),
                      ),
                    ]),

                    // ─── Quran ───
                    _SectionLabel('Quran'.tr),
                    _SettingsCard(children: [
                      Obx(() => _ArrowRow(
                            title: 'Translation'.tr,
                            sub: ctrl.translationOption.label,
                            onTap: () => showTranslationPicker(context),
                          )),
                      Obx(() => _ArrowRow(
                            title: 'Qari (reciter)'.tr,
                            sub: ctrl.reciterOption.name,
                            onTap: () => showReciterPicker(context),
                          )),
                      Obx(() => _ArrowRow(
                            title: 'Tafsir (explanation)'.tr,
                            sub: ctrl.tafsirOption?.name ?? 'Off'.tr,
                            onTap: () => showTafsirPicker(context),
                          )),
                      Obx(() => _ArrowRow(
                            title: 'Arabic font and size'.tr,
                            sub: ArabicFontOption.at(ctrl.arabicFont.value).name,
                            onTap: () => showReaderSettings(context),
                          )),
                      _ArrowRow(
                        title: 'Offline downloads'.tr,
                        sub: 'Text, tafsir and recitation'.tr,
                        isLast: true,
                        onTap: () => Get.toNamed(AppRoutes.downloads),
                      ),
                    ]),

                    // ─── Appearance ───
                    _SectionLabel('Appearance'.tr),
                    _SettingsCard(children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Obx(() {
                          final isDark = ctrl.isDarkMode.value;
                          return Row(
                            children: [
                              Expanded(child: _ModeChip(label: 'Light'.tr, selected: !isDark, onTap: () => ctrl.toggleDarkMode(false))),
                              const SizedBox(width: 8),
                              Expanded(child: _ModeChip(label: 'Dark'.tr, selected: isDark, onTap: () => ctrl.toggleDarkMode(true))),
                            ],
                          );
                        }),
                      ),
                    ]),

                    // ─── Prayer ───
                    _SectionLabel('Prayer'.tr),
                    _SettingsCard(children: [
                      Obx(() {
                        final p = Get.find<PrayerController>();
                        final place = p.placeLabel;
                        return _ArrowRow(
                          title: 'Location'.tr,
                          sub: p.usingGps.value ? '$place · ${'GPS'.tr}' : place,
                          onTap: () => showLocationPicker(context),
                        );
                      }),
                      Obx(() {
                        final method = PrayerOptions.methodById(ctrl.calcMethodId.value);
                        return _ArrowRow(
                          title: 'Calculation method'.tr,
                          sub: method.region,
                          badge: method.shortName,
                          onTap: () => showPrayerMethodPicker(context),
                        );
                      }),
                      Obx(() {
                        final madhab = PrayerOptions.madhabById(ctrl.madhabId.value);
                        return _ArrowRow(
                          title: 'Asr madhab'.tr,
                          sub: madhab.asrNote,
                          badge: madhab.id == 'hanafi' ? 'Hanafi' : 'Shafi‘i',
                          onTap: () => showMadhabPicker(context),
                        );
                      }),
                      Obx(() {
                        final azan = Get.find<AzanAudioService>();
                        azan.enabled.value;
                        azan.ready.length;
                        azan.muazzinId.value;
                        return _ArrowRow(
                          title: 'Azan sound'.tr,
                          sub: azan.statusLabel,
                          badge: azan.isActive ? null : (AzanAudioService.supported ? 'Set up'.tr : null),
                          onTap: () => showMuazzinPicker(context),
                        );
                      }),
                      Obx(() {
                        final adjust = ctrl.hijriAdjust.value;
                        final today = HijriDate.fromGregorian(DateTime.now());
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Hijri date adjustment'.tr,
                                        style: createTextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: ThemeColors.getTextDark())),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${LocaleText.hijri(today)} · ${'Match your local moon sighting'.tr}',
                                      style: createTextStyle(fontSize: 11, fontWeight: FontWeight.normal, color: ThemeColors.getTextLight()),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: adjust > -2 ? () => ctrl.setHijriAdjust(adjust - 1) : null,
                                icon: Icon(Icons.remove_circle_outline_rounded, color: AppColors.emerald),
                              ),
                              Text(
                                LocaleText.digits(adjust > 0 ? '+$adjust' : '$adjust'),
                                style: createTextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.emerald),
                              ),
                              IconButton(
                                onPressed: adjust < 2 ? () => ctrl.setHijriAdjust(adjust + 1) : null,
                                icon: Icon(Icons.add_circle_outline_rounded, color: AppColors.emerald),
                              ),
                            ],
                          ),
                        );
                      }),
                    ]),

                    // ─── Notifications ───
                    _SectionLabel('Notifications'.tr),
                    _SettingsCard(children: [
                      Obx(() {
                        final v = ctrl.allNotifications.value;
                        return _SwitchRow(title: 'All notifications'.tr, sub: 'Master switch'.tr, value: v, onChanged: ctrl.toggleAllNotifications);
                      }),
                      Obx(() {
                        final v = ctrl.prayerAlerts.value;
                        return _SwitchRow(title: 'Azan alerts'.tr, sub: 'At each azan time'.tr, value: v, onChanged: ctrl.togglePrayerAlerts);
                      }),
                      Obx(() {
                        final v = ctrl.dailyVerse.value;
                        return _SwitchRow(title: 'Daily verse'.tr, sub: 'Morning reminder'.tr, value: v, onChanged: ctrl.toggleDailyVerse);
                      }),
                      Obx(() {
                        final v = ctrl.reminders.value;
                        return _SwitchRow(
                          title: "Jumu'ah & Ramadan".tr,
                          sub: 'Al-Kahf on Friday, sehri and iftar in Ramadan'.tr,
                          value: v,
                          onChanged: ctrl.toggleReminders,
                        );
                      }),
                      Obx(() {
                        final v = ctrl.readingGoal.value;
                        return _SwitchRow(title: 'Reading goal'.tr, sub: 'Daily target'.tr, value: v, onChanged: ctrl.toggleReadingGoal);
                      }),
                      _ArrowRow(
                        title: 'Test notification'.tr,
                        sub: 'Check that alerts pop up on your screen'.tr,
                        isLast: true,
                        onTap: () async {
                          final shown = await NotificationService.instance.showTest(
                            title: '@prayer azan · @time'.trParams({'prayer': 'Maghrib'.tr, 'time': LocaleText.time(DateTime.now())}),
                            body: 'This is how azan alerts will look. Tap to open prayer times.'.tr,
                          );
                          if (!shown) {
                            Get.snackbar(
                              'Notifications are off'.tr,
                              'Allow notifications for Al-Noor in your phone settings to get alerts.'.tr,
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          }
                        },
                      ),
                    ]),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(6, 2, 6, 6),
                      child: Text(
                        'If alerts only show in the notification shade, open phone Settings › Apps › Al Noor Quran › Notifications and turn on "Pop on screen" (some phones call it "Floating notifications").'.tr,
                        style: createTextStyle(fontSize: 11.0, fontWeight: FontWeight.normal, color: ThemeColors.getTextLight()),
                      ),
                    ),

                    _SectionLabel('Privacy'.tr),
                    _SettingsCard(children: [
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Text(
                          'Location is used on this phone for prayer times and Qibla. It is not uploaded and no location history is kept. Your journal, bookmarks and reading progress stay on this phone unless you export a backup.'.tr,
                          style: createTextStyle(fontSize: 12.0, fontWeight: FontWeight.normal, color: ThemeColors.getTextMid()),
                        ),
                      ),
                      _ArrowRow(
                        title: 'Export backup'.tr,
                        sub: 'Bookmarks, journal, progress and settings. No location.'.tr,
                        isLast: true,
                        onTap: () => _exportBackup(),
                      ),
                    ]),
                    const SizedBox(height: 28),
                    const AppLogo.mark(size: 56),
                    const SizedBox(height: 8),
                    Text('Al Noor Quran',
                        style: createTextStyle(fontSize: 13.0, fontWeight: FontWeight.w700, color: ThemeColors.getTextMid())),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportBackup() async {
    final storage = Get.find<StorageService>();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/al_noor_backup.json');
    await file.writeAsString(storage.exportBackupJson());
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Al-Noor backup. Keep this file in Drive or iCloud. It has no location data.'.tr,
    );
  }

  void _editName(BuildContext context, SettingsController ctrl) {
    final textCtrl = TextEditingController(text: ctrl.userName.value);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ThemeColors.getCard(),
        title: Text('Edit name'.tr, style: createTextStyle(fontSize: 16.0, color: ThemeColors.getTextDark(), fontWeight: FontWeight.bold)),
        content: TextField(
          controller: textCtrl,
          style: createTextStyle(fontSize: 14.0, color: ThemeColors.getTextDark(), fontWeight: FontWeight.normal),
          decoration: InputDecoration(hintText: 'Your name'.tr, hintStyle: createTextStyle(fontSize: 12.0, color: ThemeColors.getTextLight(), fontWeight: FontWeight.normal)),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: Text('Cancel'.tr, style: createTextStyle(fontSize: 14.0, color: ThemeColors.getTextMid(), fontWeight: FontWeight.normal))),
          ElevatedButton(
            onPressed: () {
              ctrl.updateUserName(textCtrl.text.trim());
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: ThemeColors.getEmerald()),
            child: Text('Save'.tr, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModeChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? ThemeColors.getEmerald() : ThemeColors.emeraldPale,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? ThemeColors.getEmerald() : (ThemeColors.isDark ? AppPalette.darkBorder : const Color(0xFFE6D9BE))),
        ),
        child: Text(
          label,
          style: createTextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : ThemeColors.getTextDark(),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final Color lightColor = ThemeColors.getTextLight();
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6, left: 4),
      child: Text(text.toUpperCase(), style: createTextStyle(fontSize: 10.0, fontWeight: FontWeight.w600, color: lightColor, letterSpacing: 1.0)),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppSurfaces.card(radius: 18),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String title;
  final String sub;
  final bool value;
  final Function(bool) onChanged;
  final bool isLast;

  const _SwitchRow({required this.title, required this.sub, required this.value, required this.onChanged, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    final Color textColor = ThemeColors.getTextDark();
    final Color subColor = ThemeColors.getTextLight();
    final Color primaryColor = ThemeColors.getEmerald();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: subColor.withValues(alpha: 0.15), width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: createTextStyle(fontSize: 13.0, fontWeight: FontWeight.w600, color: textColor)),
                const SizedBox(height: 2),
                Text(sub, maxLines: 2, overflow: TextOverflow.ellipsis, style: createTextStyle(fontSize: 11.0, fontWeight: FontWeight.normal, color: subColor)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch.adaptive(value: value, onChanged: onChanged, activeTrackColor: primaryColor),
        ],
      ),
    );
  }
}

class _ArrowRow extends StatelessWidget {
  final String title;
  final String sub;
  final String? badge;
  final bool isLast;
  final VoidCallback? onTap;

  const _ArrowRow({required this.title, required this.sub, this.badge, this.isLast = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final Color textColor = ThemeColors.getTextDark();
    final Color subColor = ThemeColors.getTextLight();
    final Color primaryColor = ThemeColors.getEmerald();
    final Color paleColor = ThemeColors.emeraldPale;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          border: isLast ? null : Border(bottom: BorderSide(color: subColor.withValues(alpha: 0.15), width: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: createTextStyle(fontSize: 13.0, fontWeight: FontWeight.w600, color: textColor)),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 12, color: subColor),
              ],
            ),
            const SizedBox(height: 2),
            Text(sub, maxLines: 2, overflow: TextOverflow.ellipsis, style: createTextStyle(fontSize: 11.0, fontWeight: FontWeight.normal, color: subColor)),
            if (badge != null) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: paleColor, borderRadius: BorderRadius.circular(20)),
                child: Text(
                  badge!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: createTextStyle(fontSize: 10.0, fontWeight: FontWeight.w600, color: primaryColor),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
