// lib/app/bindings/initial_binding.dart
import 'package:get/get.dart';
import '../../data/services/azan_audio_service.dart';
import '../../data/services/quran_service.dart';
import '../../data/services/quran_study_service.dart';
import '../../data/services/storage_service.dart';
import '../controllers/quran_controller.dart';
import '../controllers/settings_controller.dart';
import '../controllers/tasbih_controller.dart';
import '../controllers/home_controller.dart';
import '../controllers/prayer_controller.dart';
import '../controllers/quran_download_controller.dart';
import '../controllers/reflection_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(StorageService(), permanent: true);
    final quranService = Get.put(QuranService(), permanent: true);
    Get.put(QuranStudyService(quranService.store), permanent: true);
    final settings = Get.put(SettingsController(), permanent: true); // Settings first
    // Copy the bundled Quran text into the offline store after the first frames.
    Future.delayed(const Duration(seconds: 2), () => quranService.warmUp(settings.translationId.value));
    Get.put(HomeController(), permanent: true);
    Get.put(AzanAudioService(), permanent: true);
    Get.put(PrayerController(), permanent: true);
    Get.put(QuranController(), permanent: true);
    Get.put(QuranDownloadController(), permanent: true);
    Get.put(TasbihController(), permanent: true);
    Get.put(ReflectionController(), permanent: true);
  }
}
