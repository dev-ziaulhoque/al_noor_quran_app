// lib/app/routes/app_pages.dart
import 'package:get/get.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/home/main_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/quran/quran_list_screen.dart';
import '../../presentation/screens/quran/quran_reader_screen.dart';
import '../../presentation/screens/search/search_screen.dart';
import '../../presentation/screens/qibla/qibla_screen.dart';
import '../../presentation/screens/tasbih/tasbih_screen.dart';
import '../../presentation/screens/hadith/hadith_screen.dart';
import '../../presentation/screens/dua/dua_screen.dart';
import '../../presentation/screens/azan/azan_screen.dart';
import '../../presentation/screens/azan/azan_setup_screen.dart';
import '../../presentation/screens/tracker/tracker_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/calendar/calendar_screen.dart';
import '../../presentation/screens/ramadan/ramadan_screen.dart';
import '../../presentation/screens/zakat/zakat_screen.dart';
import '../../presentation/screens/journal/journal_screen.dart';
import '../../presentation/screens/journal/reflection_editor_screen.dart';
import '../../presentation/screens/journal/reflection_theme_screen.dart';
import '../../presentation/screens/quran/bookmarks_screen.dart';
import '../../presentation/screens/quran/downloads_screen.dart';
import 'app_routes.dart';

class AppPages {
  static final List<GetPage> pages = [
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen(), transition: Transition.fadeIn),
    GetPage(name: AppRoutes.home, page: () => MainScreen(), transition: Transition.fadeIn),
    GetPage(name: AppRoutes.onboarding, page: () => const OnboardingScreen(), transition: Transition.fadeIn),
    GetPage(name: AppRoutes.quranList, page: () => QuranListScreen(), transition: Transition.rightToLeft),
    GetPage(name: AppRoutes.quranReader, page: () => const QuranReaderScreen(), transition: Transition.rightToLeft),
    GetPage(name: AppRoutes.search, page: () => SearchScreen(), transition: Transition.rightToLeft),
    GetPage(name: AppRoutes.qibla, page: () => QiblaScreen(), transition: Transition.rightToLeft),
    GetPage(name: AppRoutes.tasbih, page: () => TasbihScreen(), transition: Transition.rightToLeft),
    GetPage(name: AppRoutes.hadith, page: () => HadithScreen(), transition: Transition.rightToLeft),
    GetPage(name: AppRoutes.dua, page: () => DuaScreen(), transition: Transition.rightToLeft),
    GetPage(name: AppRoutes.azan, page: () => const AzanScreen(), transition: Transition.rightToLeft),
    GetPage(name: AppRoutes.azanSetup, page: () => const AzanSetupScreen(), transition: Transition.rightToLeft),
    GetPage(name: AppRoutes.tracker, page: () => TrackerScreen(), transition: Transition.rightToLeft),
    GetPage(name: AppRoutes.settings, page: () => SettingsScreen(), transition: Transition.rightToLeft),
    GetPage(name: AppRoutes.calendar, page: () => const CalendarScreen(), transition: Transition.rightToLeft),
    GetPage(name: AppRoutes.ramadan, page: () => const RamadanScreen(), transition: Transition.rightToLeft),
    GetPage(name: AppRoutes.zakat, page: () => const ZakatScreen(), transition: Transition.rightToLeft),
    GetPage(name: AppRoutes.journal, page: () => const JournalScreen(), transition: Transition.rightToLeft),
    GetPage(name: AppRoutes.reflectTheme, page: () => const ReflectionThemeScreen(), transition: Transition.rightToLeft),
    GetPage(name: AppRoutes.reflectEditor, page: () => const ReflectionEditorScreen(), transition: Transition.downToUp),
    GetPage(name: AppRoutes.downloads, page: () => const DownloadsScreen(), transition: Transition.rightToLeft),
    GetPage(name: AppRoutes.bookmarks, page: () => const BookmarksScreen(), transition: Transition.rightToLeft),
  ];
}
