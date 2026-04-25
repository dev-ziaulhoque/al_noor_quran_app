// lib/app/routes/app_pages.dart
import 'package:get/get.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/home/main_screen.dart';
import '../../presentation/screens/quran/quran_list_screen.dart';
import '../../presentation/screens/quran/quran_reader_screen.dart';
import '../../presentation/screens/search/search_screen.dart';
import '../../presentation/screens/qibla/qibla_screen.dart';
import '../../presentation/screens/tasbih/tasbih_screen.dart';
import '../../presentation/screens/hadith/hadith_screen.dart';
import '../../presentation/screens/dua/dua_screen.dart';
import '../../presentation/screens/azan/azan_screen.dart';
import '../../presentation/screens/tracker/tracker_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import 'app_routes.dart';

class AppPages {
  static final List<GetPage> pages = [
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen(), transition: Transition.fadeIn),
    GetPage(name: AppRoutes.home, page: () => const MainScreen(), transition: Transition.fadeIn),
    GetPage(name: AppRoutes.quranList, page: () => const QuranListScreen(), transition: Transition.rightToLeft),
    GetPage(name: AppRoutes.quranReader, page: () => const QuranReaderScreen(), transition: Transition.rightToLeft),
    GetPage(name: AppRoutes.search, page: () => const SearchScreen(), transition: Transition.rightToLeft),
    GetPage(name: AppRoutes.qibla, page: () => const QiblaScreen(), transition: Transition.rightToLeft),
    GetPage(name: AppRoutes.tasbih, page: () => const TasbihScreen(), transition: Transition.rightToLeft),
    GetPage(name: AppRoutes.hadith, page: () => const HadithScreen(), transition: Transition.rightToLeft),
    GetPage(name: AppRoutes.dua, page: () => const DuaScreen(), transition: Transition.rightToLeft),
    GetPage(name: AppRoutes.azan, page: () => const AzanScreen(), transition: Transition.rightToLeft),
    GetPage(name: AppRoutes.tracker, page: () => const TrackerScreen(), transition: Transition.rightToLeft),
    GetPage(name: AppRoutes.settings, page: () => const SettingsScreen(), transition: Transition.rightToLeft),
  ];
}
