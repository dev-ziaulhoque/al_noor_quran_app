import 'package:get/get.dart';

import '../../data/services/azan_audio_service.dart';
import '../../data/services/notification_service.dart';
import '../../presentation/widgets/azan_ringing_sheet.dart';
import '../controllers/quran_controller.dart';
import 'app_routes.dart';

/// Opens the screen a notification points to, from a running app or a cold start.
class NotificationRouter {
  static bool _attached = false;

  /// Call once the home screen is showing.
  static void attach() {
    final service = NotificationService.instance;
    service.onOpen = open;
    if (_attached) return;
    _attached = true;
    if (Get.isRegistered<AzanAudioService>()) {
      final azan = Get.find<AzanAudioService>();
      void onRing(String? prayer) {
        if (prayer == null || prayer.isEmpty) {
          AzanRingingSheet.close();
          return;
        }
        AzanRingingSheet.showFor(prayer);
      }

      ever(azan.ringing, onRing);
      onRing(azan.ringing.value);
    }
    final pending = service.takePendingPayload();
    if (pending != null) Future.delayed(const Duration(milliseconds: 300), () => open(pending));
  }

  static Future<void> open(String payload) async {
    final current = Get.currentRoute;
    if (current == AppRoutes.splash || current == AppRoutes.onboarding) return;

    if (payload.startsWith('ayah:')) {
      final parts = payload.split(':');
      final surah = int.tryParse(parts.length > 1 ? parts[1] : '');
      final ayah = int.tryParse(parts.length > 2 ? parts[2] : '') ?? 1;
      if (surah != null) await _openAyah(surah, ayah);
      return;
    }

    final route = switch (payload) {
      NotificationPayload.azan => AppRoutes.azan,
      NotificationPayload.qibla => AppRoutes.qibla,
      NotificationPayload.ramadan => AppRoutes.ramadan,
      NotificationPayload.calendar => AppRoutes.calendar,
      _ => null,
    };
    if (route == null) return;
    if (current == route) return;
    Get.toNamed(route);
  }

  static Future<void> _openAyah(int surahNumber, int ayah) async {
    if (!Get.isRegistered<QuranController>()) return;
    final ctrl = Get.find<QuranController>();
    for (var i = 0; i < 50 && ctrl.surahList.isEmpty; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    final surah = ctrl.surahList.firstWhereOrNull((s) => s.number == surahNumber);
    if (surah == null) {
      Get.toNamed(AppRoutes.quranList);
      return;
    }
    ctrl.loadSurahAyahs(surah, startAyah: ayah);
    if (Get.currentRoute != AppRoutes.quranReader) Get.toNamed(AppRoutes.quranReader);
  }
}
