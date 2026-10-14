// lib/presentation/screens/azan/azan_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/controllers/prayer_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/services/azan_audio_service.dart';
import '../../../data/services/storage_service.dart';
import '../../widgets/app_surfaces.dart';
import '../../widgets/prayer_pickers.dart';

class AzanScreen extends StatelessWidget {
  const AzanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pCtrl = Get.find<PrayerController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          children: [
            Text('Azan Times', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            Text('مواقيت الصلاة', style: TextStyle(fontFamily: 'Amiri', fontSize: 12, color: AppColors.getTextLight())),
          ],
        ),
        backgroundColor: AppColors.card,
        elevation: 0,
      ),
      body: Obx(() {
        if (pCtrl.isLoading.value) {
          return Center(child: CircularProgressIndicator(color: AppColors.getEmerald()));
        }

        final prayers = pCtrl.getPrayerList();

        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            // Next Prayer Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppSurfaces.hero(),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_on_rounded, size: 12, color: AppColors.goldLight),
                      const SizedBox(width: 4),
                      Text(
                        pCtrl.placeLabel.toUpperCase(),
                        style: const TextStyle(fontSize: 10, color: Color(0xCCFFFFFF), letterSpacing: 1.2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('NEXT PRAYER', style: TextStyle(fontSize: 9, color: Color(0x80FFFFFF), letterSpacing: 1.5)),
                  const SizedBox(height: 8),
                  Text(
                    pCtrl.nextPrayerName.value,
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  Text(
                    pCtrl.nextPrayerTimeStr.value,
                    style: TextStyle(fontSize: 18, color: AppColors.goldLight, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    pCtrl.timeRemainingStr.value,
                    style: const TextStyle(fontSize: 13, color: Color(0xBFFFFFFF)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Prayer List
            Container(
              decoration: AppSurfaces.card(radius: 20),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: prayers.asMap().entries.map((entry) {
                  final i = entry.key;
                  final p = entry.value;
                  final isNext = p['next'] as bool;
                  final isLast = i == prayers.length - 1;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isNext ? AppColors.emeraldPale : Colors.transparent,
                      border: isLast ? null : const Border(bottom: BorderSide(color: Color(0x0D000000), width: 0.5)),
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p['name'] as String,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isNext ? AppColors.emerald : AppColors.textDark,
                              ),
                            ),
                            if ((p['offset'] as int) != 0)
                              Text(
                                'Waqt starts ${p['waqt']}',
                                style: TextStyle(fontSize: 11, color: AppColors.textLight),
                              ),
                          ],
                        ),
                        const Spacer(),
                        if (isNext) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.emerald,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text('Next', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(width: 10),
                        ],
                        Text(
                          p['time'] as String,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isNext ? AppColors.emerald : AppColors.textMid,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            _ChoiceTile(
              title: 'Masjid azan time',
              value: _offsetSummary(pCtrl.azanOffsets),
              onTap: () => _showAzanOffsetSheet(context, pCtrl),
            ),
            _ChoiceTile(
              title: 'Calculation method',
              value: pCtrl.methodName.value,
              onTap: () => showPrayerMethodPicker(context),
            ),
            _ChoiceTile(
              title: 'Asr madhab',
              value: pCtrl.madhabName.value,
              onTap: () => showMadhabPicker(context),
            ),
            Obx(() {
              final azan = Get.find<AzanAudioService>();
              azan.enabled.value;
              azan.ready.length;
              azan.muazzinId.value;
              return _ChoiceTile(
                title: 'Azan sound'.tr,
                value: azan.statusLabel,
                onTap: () => Get.toNamed(AppRoutes.azanSetup),
              );
            }),
            const SizedBox(height: 8),
            Text(
              'Times show when the masjid gives the azan, set by the minutes above. Waqt starts is when the prayer time begins. Alerts use the azan time and your phone’s notification tone. Turn alerts on or off in Settings.',
              style: TextStyle(fontSize: 11, height: 1.4, color: AppColors.textLight),
            ),
          ],
        );
      }),
    );
  }
}

String _offsetSummary(Map<String, int> offsets) {
  if (offsets.values.every((m) => m == 0)) return 'Same as waqt start';
  final dhuhr = offsets['Dhuhr'] ?? 0;
  return 'Dhuhr +$dhuhr min · tap to match your masjid';
}

void _showAzanOffsetSheet(BuildContext context, PrayerController pCtrl) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.card,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => _AzanOffsetSheet(pCtrl: pCtrl),
  );
}

class _AzanOffsetSheet extends StatefulWidget {
  final PrayerController pCtrl;
  const _AzanOffsetSheet({required this.pCtrl});

  @override
  State<_AzanOffsetSheet> createState() => _AzanOffsetSheetState();
}

class _AzanOffsetSheetState extends State<_AzanOffsetSheet> {
  late Map<String, int> _offsets;

  @override
  void initState() {
    super.initState();
    _offsets = Map<String, int>.from(widget.pCtrl.azanOffsets);
  }

  void _change(String name, int delta) {
    setState(() => _offsets[name] = ((_offsets[name] ?? 0) + delta).clamp(0, 120));
  }

  @override
  Widget build(BuildContext context) {
    final waqt = {
      for (final row in widget.pCtrl.getPrayerList()) row['name'] as String: row['waqt'] as String,
    };

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Masjid azan time', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            const SizedBox(height: 4),
            Text(
              'Minutes after the waqt begins. Set these to match the azan at your masjid.',
              style: TextStyle(fontSize: 12, height: 1.4, color: AppColors.textMid),
            ),
            const SizedBox(height: 12),
            for (final name in StorageService.bangladeshAzanOffsets.keys)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                          Text('Waqt ${waqt[name] ?? '--:--'}', style: TextStyle(fontSize: 11, color: AppColors.textLight)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _change(name, -5),
                      icon: Icon(Icons.remove_circle_outline_rounded, color: AppColors.emerald),
                    ),
                    SizedBox(
                      width: 56,
                      child: Text(
                        '+${_offsets[name] ?? 0} min',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _change(name, 5),
                      icon: Icon(Icons.add_circle_outline_rounded, color: AppColors.emerald),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _offsets = Map<String, int>.from(StorageService.bangladeshAzanOffsets)),
                    child: const Text('Bangladesh typical'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _offsets = {for (final k in _offsets.keys) k: 0}),
                    child: const Text('Waqt start'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () {
                widget.pCtrl.saveAzanOffsets(_offsets);
                Navigator.of(context).pop();
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.emerald,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback onTap;

  const _ChoiceTile({required this.title, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            decoration: AppSurfaces.card(radius: 18),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: TextStyle(fontSize: 11, color: AppColors.textLight)),
                        Text(
                          value,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
