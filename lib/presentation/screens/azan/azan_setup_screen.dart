import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/controllers/prayer_controller.dart';
import '../../../app/controllers/settings_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/i18n/locale_text.dart';
import '../../../core/prayer/prayer_options.dart';
import '../../../data/services/azan_audio_service.dart';
import '../../../data/services/notification_service.dart';
import '../../widgets/app_surfaces.dart';

/// One-time setup for the full azan: pick and download a voice, preview it,
/// choose prayers and volume, then turn it on. Until then azan is a notification.
class AzanSetupScreen extends StatefulWidget {
  const AzanSetupScreen({super.key});

  @override
  State<AzanSetupScreen> createState() => _AzanSetupScreenState();
}

class _AzanSetupScreenState extends State<AzanSetupScreen> {
  final AzanAudioService _azan = Get.find();
  bool _batteryOk = true;

  @override
  void initState() {
    super.initState();
    _checkBattery();
  }

  @override
  void dispose() {
    _azan.stopPreview();
    super.dispose();
  }

  Future<void> _checkBattery() async {
    final ok = await _azan.batteryUnrestricted;
    if (mounted) setState(() => _batteryOk = ok);
  }

  void _resync() => Get.find<PrayerController>().syncNotifications();

  Future<void> _download(MuazzinOption m) async {
    final error = await _azan.download(m);
    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  void _select(MuazzinOption m) {
    _azan.setMuazzin(m.id);
    Get.find<SettingsController>().muazzinId.value = m.id;
    Get.find<PrayerController>().reload();
  }

  Future<void> _turnOn() async {
    final granted = await NotificationService.instance.ensurePermission();
    if (!granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Allow notifications for Al-Noor in your phone settings to get alerts.'.tr),
        ));
      }
      return;
    }
    await _azan.requestReliability();
    await _checkBattery();
    final settings = Get.find<SettingsController>();
    if (!settings.allNotifications.value) await settings.toggleAllNotifications(true);
    if (!settings.prayerAlerts.value) await settings.togglePrayerAlerts(true);
    _azan.setEnabled(true);
    _resync();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Full azan is on. It will play at the next azan time.'.tr),
      ));
    }
  }

  void _turnOff() {
    _azan.setEnabled(false);
    _resync();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        foregroundColor: AppColors.textDark,
        title: Text('Azan sound'.tr, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
      ),
      body: Obx(() {
        final supported = AzanAudioService.supported;
        final voice = _azan.voice;
        final voiceReady = _azan.ready[voice.id] ?? false;
        final on = _azan.enabled.value;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
          children: [
            _hero(on && voiceReady, voice),
            if (!supported) ...[
              const SizedBox(height: 12),
              _notice(Icons.phone_iphone_rounded,
                  'On iPhone the azan comes as a notification with sound. The full azan plays on Android phones.'.tr),
            ],
            const SizedBox(height: 18),
            _stepTitle('1', 'Choose a muazzin'.tr, 'Download once (about 7 MB). It then works offline.'.tr),
            for (final m in PrayerOptions.muazzins) _VoiceCard(muazzin: m, onSelect: () => _select(m), onDownload: () => _download(m)),
            const SizedBox(height: 14),
            _stepTitle('2', 'Prayers with full azan'.tr, 'Prayers you turn off still get a notification.'.tr),
            _prayersCard(),
            const SizedBox(height: 14),
            _stepTitle('3', 'Azan volume'.tr, 'Uses the alarm volume, so the azan plays even when the phone is on silent.'.tr),
            _volumeCard(),
            if (supported) ...[
              const SizedBox(height: 14),
              _stepTitle('4', 'Keep it on time'.tr, 'Some phones stop apps in the background. Allow Al Noor Quran to run so the azan is never missed.'.tr),
              _batteryCard(),
            ],
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        final voiceReady = _azan.ready[_azan.voice.id] ?? false;
        final on = _azan.enabled.value;
        if (!AzanAudioService.supported) return const SizedBox.shrink();
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            decoration: BoxDecoration(
              color: AppColors.card,
              border: Border(top: BorderSide(color: AppColors.gold.withValues(alpha: 0.3))),
            ),
            child: on && voiceReady
                ? Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _turnOff,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: AppColors.textLight),
                          ),
                          child: Text('Use notification only'.tr, style: TextStyle(color: AppColors.textMid, fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => Get.back(),
                          style: FilledButton.styleFrom(backgroundColor: AppColors.emerald, padding: const EdgeInsets.symmetric(vertical: 14)),
                          icon: const Icon(Icons.check_rounded, color: Colors.white),
                          label: Text('Done'.tr, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                        ),
                      ),
                    ],
                  )
                : FilledButton.icon(
                    onPressed: voiceReady ? _turnOn : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.emerald,
                      disabledBackgroundColor: AppColors.textLight.withValues(alpha: 0.3),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    icon: Icon(Icons.campaign_rounded, color: voiceReady ? Colors.white : AppColors.textMid),
                    label: Text(
                      voiceReady ? 'Turn on full azan'.tr : 'Download a muazzin to turn on'.tr,
                      style: TextStyle(color: voiceReady ? Colors.white : AppColors.textMid, fontWeight: FontWeight.w800),
                    ),
                  ),
          ),
        );
      }),
    );
  }

  Widget _hero(bool active, MuazzinOption voice) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppSurfaces.hero(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(color: Color(0x26E8C96A), shape: BoxShape.circle),
                child: const Icon(Icons.mosque_rounded, color: AppPalette.goldLight, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hear the real azan'.tr,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
                    const Text('حَيَّ عَلَى الصَّلَاةِ', style: TextStyle(fontFamily: 'Amiri', fontSize: 16, color: AppPalette.goldLight)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'The full azan plays at each azan time, even when the app is closed or the phone is on silent. Tap "Stop azan" on the notification to silence it.'.tr,
            style: const TextStyle(fontSize: 12.5, height: 1.45, color: Color(0xDDFFFFFF)),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: active ? const Color(0x33E8C96A) : const Color(0x1FFFFFFF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: active ? AppPalette.goldLight : const Color(0x40FFFFFF)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(active ? Icons.volume_up_rounded : Icons.notifications_rounded,
                    size: 16, color: active ? AppPalette.goldLight : Colors.white),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    active ? '${'Full azan'.tr} · ${voice.name}' : 'Now: notification only'.tr,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: active ? AppPalette.goldLight : Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepTitle(String n, String title, String sub) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
            child: Text(LocaleText.digits(n), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                Text(sub, style: TextStyle(fontSize: 11.5, height: 1.35, color: AppColors.textMid)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _notice(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.goldPale,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.gold),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: TextStyle(fontSize: 12.5, height: 1.4, color: AppColors.textDark))),
        ],
      ),
    );
  }

  Widget _prayersCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppSurfaces.card(radius: 18),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final p in AzanAudioService.prayers)
            Obx(() {
              final on = _azan.audioPrayers.contains(p);
              return FilterChip(
                selected: on,
                showCheckmark: true,
                checkmarkColor: Colors.white,
                selectedColor: AppColors.emerald,
                backgroundColor: AppColors.card,
                side: BorderSide(color: on ? AppColors.emerald : AppColors.textLight.withValues(alpha: 0.5)),
                label: Text(p.tr, style: TextStyle(fontWeight: FontWeight.w700, color: on ? Colors.white : AppColors.textDark)),
                onSelected: (v) {
                  _azan.togglePrayer(p, v);
                  _resync();
                },
              );
            }),
        ],
      ),
    );
  }

  Widget _volumeCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: AppSurfaces.card(radius: 18),
      child: Row(
        children: [
          Icon(Icons.volume_down_rounded, color: AppColors.textLight),
          Expanded(
            child: Slider(
              value: _azan.volume.value,
              min: 0.2,
              max: 1.0,
              divisions: 8,
              activeColor: AppColors.emerald,
              label: '${LocaleText.digits((_azan.volume.value * 100).round())}%',
              onChanged: _azan.setVolume,
              onChangeEnd: (_) => _resync(),
            ),
          ),
          Icon(Icons.volume_up_rounded, color: AppColors.emerald),
          const SizedBox(width: 6),
          SizedBox(
            width: 44,
            child: Text('${LocaleText.digits((_azan.volume.value * 100).round())}%',
                textAlign: TextAlign.end, style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textDark)),
          ),
        ],
      ),
    );
  }

  Widget _batteryCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      decoration: AppSurfaces.card(radius: 18),
      child: Row(
        children: [
          Icon(_batteryOk ? Icons.verified_rounded : Icons.battery_alert_rounded,
              color: _batteryOk ? AppColors.emerald : const Color(0xFFE09B2D)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _batteryOk ? 'Battery limits are off for Al Noor Quran.'.tr : 'Battery saver may delay the azan on this phone.'.tr,
              style: TextStyle(fontSize: 12.5, height: 1.35, color: AppColors.textDark),
            ),
          ),
          if (!_batteryOk)
            TextButton(
              onPressed: () async {
                await _azan.requestReliability();
                await _checkBattery();
              },
              child: Text('Allow'.tr, style: TextStyle(color: AppColors.emerald, fontWeight: FontWeight.w800)),
            ),
        ],
      ),
    );
  }
}

class _VoiceCard extends StatelessWidget {
  final MuazzinOption muazzin;
  final VoidCallback onSelect;
  final VoidCallback onDownload;

  const _VoiceCard({required this.muazzin, required this.onSelect, required this.onDownload});

  @override
  Widget build(BuildContext context) {
    final azan = Get.find<AzanAudioService>();
    return Obx(() {
      final selected = azan.muazzinId.value == muazzin.id;
      final ready = azan.ready[muazzin.id] ?? false;
      final progress = azan.progress[muazzin.id];
      final playing = azan.previewing.value;
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onSelect,
            borderRadius: BorderRadius.circular(18),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
              decoration: AppSurfaces.card(radius: 18).copyWith(
                border: Border.all(color: selected ? AppColors.emerald : AppColors.gold.withValues(alpha: 0.25), width: selected ? 2 : 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                          color: selected ? AppColors.emerald : AppColors.textLight),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(muazzin.name, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                            Text(
                              muazzin.fajrVoice == null
                                  ? muazzin.style.tr
                                  : '${muazzin.style.tr} · ${'Fajr azan in the @voice voice'.trParams({'voice': muazzin.fajrVoice!.tr})}',
                              style: TextStyle(fontSize: 11.5, color: AppColors.textMid),
                            ),
                          ],
                        ),
                      ),
                      if (ready)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.emeraldPale, borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.download_done_rounded, size: 14, color: AppColors.emerald),
                              const SizedBox(width: 4),
                              Text('On phone'.tr, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.emerald)),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (progress != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(6),
                          color: AppColors.emerald,
                          backgroundColor: AppColors.emeraldPale,
                        ),
                        const SizedBox(height: 4),
                        Text('${'Downloading'.tr} ${LocaleText.digits((progress * 100).round())}%',
                            style: TextStyle(fontSize: 11, color: AppColors.textMid)),
                      ],
                    )
                  else if (!ready)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed: AzanAudioService.supported ? onDownload : null,
                        style: OutlinedButton.styleFrom(side: BorderSide(color: AppColors.emerald)),
                        icon: Icon(Icons.download_rounded, size: 18, color: AppColors.emerald),
                        label: Text('Download (about 7 MB)'.tr, style: TextStyle(color: AppColors.emerald, fontWeight: FontWeight.w700)),
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _PreviewButton(
                          label: 'Azan'.tr,
                          playing: playing == '${muazzin.id}:azan',
                          onTap: () => playing == '${muazzin.id}:azan' ? azan.stopPreview() : azan.preview(muazzin),
                        ),
                        _PreviewButton(
                          label: 'Fajr azan'.tr,
                          playing: playing == '${muazzin.id}:fajr',
                          onTap: () => playing == '${muazzin.id}:fajr' ? azan.stopPreview() : azan.preview(muazzin, fajr: true),
                        ),
                        IconButton(
                          tooltip: 'Remove download'.tr,
                          onPressed: () => azan.delete(muazzin),
                          icon: Icon(Icons.delete_outline_rounded, color: AppColors.textLight),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _PreviewButton extends StatelessWidget {
  final String label;
  final bool playing;
  final VoidCallback onTap;

  const _PreviewButton({required this.label, required this.playing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      backgroundColor: playing ? AppColors.emerald : AppColors.emeraldPale,
      side: BorderSide.none,
      avatar: Icon(playing ? Icons.stop_rounded : Icons.play_arrow_rounded, size: 18, color: playing ? Colors.white : AppColors.emerald),
      label: Text(label, style: TextStyle(fontWeight: FontWeight.w700, color: playing ? Colors.white : AppColors.emerald)),
    );
  }
}
