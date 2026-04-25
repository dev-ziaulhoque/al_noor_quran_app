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

  // ─── Default Values ───
  static const String defaultTranslation = 'en';
  static const String defaultReciter = 'Abdul_Basit_Murattal_64kbps';
  static const double defaultFontSize = 22.0;

  // ─── Total Surahs ───
  static const int totalSurahs = 114;

  // ─── Dhaka Coordinates (default) ───
  static const double defaultLat = 23.8103;
  static const double defaultLng = 90.4125;
}
