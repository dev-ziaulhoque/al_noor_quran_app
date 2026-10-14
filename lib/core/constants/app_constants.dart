// lib/core/constants/app_constants.dart

class AppConstants {
  // ─── GlobalQuran API ───
  static const String globalQuranApiKey = 'HYCalg7yI7txDPa3UZIjhCRim4zQmvH0qWFdFHnrnq0SY';
  static const String globalQuranBaseUrl = 'https://quranapi.pages.dev/api';

  // ─── App Meta ───
  static const String appName = 'Al-Noor';
  static const String appNameAr = 'النور';
  static const String appTagline = 'القرآن الكريم';

  // ─── Storage Keys ───
  static const String keyLastRead = 'last_read';
  static const String keyBookmarks = 'bookmarks';
  static const String keyTasbihCount = 'tasbih_count';
  static const String keyTasbihTotal = 'tasbih_total';
  static const String keyTasbihStreak = 'tasbih_streak';
  static const String keyUserName = 'user_name';
  static const String keyDarkMode = 'dark_mode';
  static const String keyFontSize = 'font_size';
  static const String keyThemeColor = 'theme_color';
  static const String keyTranslation = 'translation';
  static const String keyReciter = 'reciter';
  static const String keyPrayerNotif = 'prayer_notif';
  static const String keyDailyVerseNotif = 'daily_verse_notif';
  static const String keyTrackerData = 'tracker_data';
  static const String keyTasbihLastDate = 'tasbih_last_date';
  static const String keyCalcMethod = 'prayer_calc_method';
  static const String keyMadhab = 'prayer_madhab';
  static const String keyMuazzin = 'prayer_muazzin';
  static const String keyAzanOffsets = 'prayer_azan_offsets';
  static const String keyQuranReadAyahs = 'quran_read_ayahs';
  static const String keyQuranReadDays = 'quran_read_days';
  static const String keyQuranDailyGoal = 'quran_daily_goal';
  static const String keyJournal = 'reflection_journal';
  static const String keyRamadanChecks = 'ramadan_checks';
  static const String keyAyahCardBg = 'ayah_card_bg';
  static const String keyAyahCardAmiri = 'ayah_card_amiri';
  static const String keyAyahCardFont = 'ayah_card_font';
  static const String keyAyahCardArt = 'ayah_card_art';
  static const String keyThemeSaves = 'reflection_theme_saves';
  static const String keyAppLanguage = 'app_language';
  static const String keyTafsir = 'quran_tafsir';
  static const String keyArabicFont = 'quran_arabic_font';
  static const String keyHijriAdjust = 'hijri_adjust_days';
  static const String keyRamadanFasts = 'ramadan_fasts';
  static const String keyZakatInputs = 'zakat_inputs';
  static const String keyOnboarded = 'onboarding_done';
  static const String keyLocation = 'prayer_location';
  static const String keyRemindersNotif = 'reminders_notif';

  // ─── Default Values ───
  static const String defaultTranslation = 'en.sahih';
  static const String defaultReciter = 'ar.alafasy';
  static const double defaultFontSize = 22.0;

  // ─── Total Surahs ───
  static const int totalSurahs = 114;

  // ─── Dhaka Coordinates (default) ───
  static const double defaultLat = 23.8103;
  static const double defaultLng = 90.4125;
}
