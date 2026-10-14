// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'app/bindings/initial_binding.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'core/constants/app_constants.dart';
import 'core/i18n/app_translations.dart';
import 'core/theme/app_theme.dart';
import 'data/services/azan_audio_service.dart';
import 'data/services/notification_service.dart';
import 'data/services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.alnoor.quran.recitation',
    androidNotificationChannelName: 'Quran recitation',
    androidNotificationOngoing: true,
    androidNotificationIcon: 'drawable/ic_stat_alnoor',
    androidShowNotificationBadge: true,
  );
  await NotificationService.instance.init();
  await AzanAudioService.initPlatform();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  final language = GetStorage().read<String>(AppConstants.keyAppLanguage) ?? StorageService.deviceLanguage();
  runApp(AlNoorApp(language: language));
}

class AlNoorApp extends StatelessWidget {
  final String language;
  const AlNoorApp({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Al Noor Quran',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      translations: AppTranslations(),
      locale: Locale(language),
      fallbackLocale: const Locale('en'),
      initialBinding: InitialBinding(),
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
      defaultTransition: Transition.fadeIn,
    );
  }
}
