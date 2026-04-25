// lib/app/bindings/initial_binding.dart
import 'package:get/get.dart';
import '../../data/services/quran_service.dart';
import '../../data/services/storage_service.dart';
import '../controllers/quran_controller.dart';
import '../controllers/settings_controller.dart';
import '../controllers/tasbih_controller.dart';
import '../controllers/home_controller.dart';
import '../controllers/audio_controller.dart';
import '../services/audio_handler.dart';
import 'package:audio_service/audio_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(StorageService(), permanent: true);
    Get.put(QuranService(), permanent: true);
    
    // Provide AudioHandler to GetX
    Get.lazyPut<MyAudioHandler>(() => AudioService.init(
      builder: () => MyAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.example.al_noor_app',
        androidNotificationChannelName: 'Quran Playback',
        androidNotificationOngoing: true,
      ),
    ) as MyAudioHandler);

    Get.put(HomeController(), permanent: true);
    Get.put(QuranController(), permanent: true);
    Get.put(AudioController(), permanent: true);
    Get.put(TasbihController(), permanent: true);
    Get.put(SettingsController(), permanent: true);
  }
}
