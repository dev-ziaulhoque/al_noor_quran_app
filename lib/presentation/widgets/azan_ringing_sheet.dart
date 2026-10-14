import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../data/services/azan_audio_service.dart';

/// Shown over the app while a full azan is playing.
class AzanRingingSheet extends StatelessWidget {
  final String prayer;
  const AzanRingingSheet({super.key, required this.prayer});

  static bool _open = false;

  static Future<void> showFor(String prayer) async {
    if (_open || Get.isBottomSheetOpen == true) return;
    _open = true;
    await Get.bottomSheet(AzanRingingSheet(prayer: prayer), isDismissible: true, enableDrag: true);
    _open = false;
  }

  static void close() {
    if (_open) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final azan = Get.find<AzanAudioService>();
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1F7A42), Color(0xFF0B3A20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [Color(0xFFF3DC8E), AppPalette.gold]),
                boxShadow: [BoxShadow(color: Color(0x88E8C96A), blurRadius: 24)],
              ),
              child: const Icon(Icons.volume_up_rounded, color: Color(0xFF0B3A20), size: 32),
            ),
            const SizedBox(height: 14),
            Text('@prayer azan'.trParams({'prayer': prayer.tr}),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
            const SizedBox(height: 4),
            const Text('اللَّهُ أَكْبَرُ اللَّهُ أَكْبَرُ', style: TextStyle(fontFamily: 'Amiri', fontSize: 20, color: AppPalette.goldLight)),
            const SizedBox(height: 6),
            Text('Listen and repeat the words of the azan, then make dua.'.tr,
                textAlign: TextAlign.center, style: const TextStyle(fontSize: 12.5, height: 1.4, color: Color(0xCCFFFFFF))),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () async {
                  await azan.stopRinging();
                  close();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.stop_rounded, color: Color(0xFF0B3A20)),
                label: Text('Stop azan'.tr, style: const TextStyle(color: Color(0xFF0B3A20), fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
