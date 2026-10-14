// lib/data/services/storage_service.dart
import 'package:get_storage/get_storage.dart';
import '../../core/constants/app_constants.dart';
import '../models/models.dart';
import 'dart:convert';
import 'dart:ui' as ui;

class StorageService {
  final GetStorage _box = GetStorage();

  // ─── Last Read ───
  void saveLastRead(LastReadModel data) {
    _box.write(AppConstants.keyLastRead, jsonEncode(data.toJson()));
  }

  LastReadModel? getLastRead() {
    final raw = _box.read<String>(AppConstants.keyLastRead);
    if (raw == null) return null;
    return LastReadModel.fromJson(jsonDecode(raw));
  }

  // ─── Bookmarks ───
  List<BookmarkModel> getBookmarks() {
    final raw = _box.read<String>(AppConstants.keyBookmarks);
    if (raw == null) return [];
    final List list = jsonDecode(raw);
    return list.map((e) => BookmarkModel.fromJson(e)).toList();
  }

  void saveBookmark(BookmarkModel bm) {
    final list = getBookmarks();
    list.removeWhere(
        (b) => b.surahNumber == bm.surahNumber && b.ayahNumber == bm.ayahNumber);
    list.insert(0, bm);
    _box.write(AppConstants.keyBookmarks, jsonEncode(list.map((e) => e.toJson()).toList()));
  }

  void removeBookmark(int surahNum, int ayahNum) {
    final list = getBookmarks();
    list.removeWhere((b) => b.surahNumber == surahNum && b.ayahNumber == ayahNum);
    _box.write(AppConstants.keyBookmarks, jsonEncode(list.map((e) => e.toJson()).toList()));
  }

  bool isBookmarked(int surahNum, int ayahNum) {
    return getBookmarks()
        .any((b) => b.surahNumber == surahNum && b.ayahNumber == ayahNum);
  }

  // ─── Tasbih ───
  int getTasbihCount() => _box.read<int>(AppConstants.keyTasbihCount) ?? 0;
  void saveTasbihCount(int count) => _box.write(AppConstants.keyTasbihCount, count);

  int getTasbihTotal() => _box.read<int>(AppConstants.keyTasbihTotal) ?? 0;
  void saveTasbihTotal(int total) => _box.write(AppConstants.keyTasbihTotal, total);

  int getTasbihStreak() => _box.read<int>(AppConstants.keyTasbihStreak) ?? 0;
  void saveTasbihStreak(int streak) => _box.write(AppConstants.keyTasbihStreak, streak);

  String? getTasbihLastDate() => _box.read<String>(AppConstants.keyTasbihLastDate);
  void saveTasbihLastDate(String date) => _box.write(AppConstants.keyTasbihLastDate, date);

  // ─── Settings ───
  /// Follows the phone's dark mode until the user picks one.
  bool getDarkMode() =>
      _box.read<bool>(AppConstants.keyDarkMode) ??
      ui.PlatformDispatcher.instance.platformBrightness == ui.Brightness.dark;
  void saveDarkMode(bool val) => _box.write(AppConstants.keyDarkMode, val);

  double getFontSize() => _box.read<double>(AppConstants.keyFontSize) ?? AppConstants.defaultFontSize;
  void saveFontSize(double size) => _box.write(AppConstants.keyFontSize, size);

  String getTranslation() => _box.read<String>(AppConstants.keyTranslation) ?? AppConstants.defaultTranslation;
  void saveTranslation(String lang) => _box.write(AppConstants.keyTranslation, lang);

  String getReciter() => _box.read<String>(AppConstants.keyReciter) ?? AppConstants.defaultReciter;
  void saveReciter(String reciter) => _box.write(AppConstants.keyReciter, reciter);

  String getUserName() => _box.read<String>(AppConstants.keyUserName) ?? '';
  void saveUserName(String name) => _box.write(AppConstants.keyUserName, name);

  bool getPrayerNotif() => _box.read<bool>(AppConstants.keyPrayerNotif) ?? true;
  void savePrayerNotif(bool val) => _box.write(AppConstants.keyPrayerNotif, val);

  bool getPrayerAlertsNotif() => _box.read<bool>('key_prayer_alerts_notif') ?? true;
  void savePrayerAlertsNotif(bool val) => _box.write('key_prayer_alerts_notif', val);

  bool getDailyVerseNotif() => _box.read<bool>(AppConstants.keyDailyVerseNotif) ?? true;
  void saveDailyVerseNotif(bool val) => _box.write(AppConstants.keyDailyVerseNotif, val);

  bool getReadingGoalNotif() => _box.read<bool>('key_reading_goal_notif') ?? false;
  void saveReadingGoalNotif(bool val) => _box.write('key_reading_goal_notif', val);

  int getThemeIndex() => _box.read<int>(AppConstants.keyThemeColor) ?? 0;
  void saveThemeIndex(int index) => _box.write(AppConstants.keyThemeColor, index);

  // ─── Recent Searches ───
  List<String> getRecentSearches() {
    final List? list = _box.read<List>('key_recent_searches');
    if (list == null) return ['Ar-Rahman', 'Yaseen', 'Al-Mulk', 'Al-Ikhlas'];
    return list.cast<String>();
  }

  void saveRecentSearch(String term) {
    if (term.trim().isEmpty) return;
    final list = getRecentSearches();
    list.removeWhere((item) => item.toLowerCase() == term.toLowerCase());
    list.insert(0, term.trim());
    if (list.length > 8) list.removeLast();
    _box.write('key_recent_searches', list);
  }

  void clearRecentSearches() {
    _box.write('key_recent_searches', <String>[]);
  }

  // ─── Tracker ───
  Map<String, dynamic> getTrackerData() {
    final raw = _box.read<String>(AppConstants.keyTrackerData);
    if (raw == null) return {};
    return Map<String, dynamic>.from(jsonDecode(raw));
  }

  void saveTrackerData(Map<String, dynamic> data) {
    _box.write(AppConstants.keyTrackerData, jsonEncode(data));
  }

  // ─── Prayer calculation ───
  String getCalcMethod() => _box.read<String>(AppConstants.keyCalcMethod) ?? 'karachi';
  void saveCalcMethod(String id) => _box.write(AppConstants.keyCalcMethod, id);

  String getMadhab() => _box.read<String>(AppConstants.keyMadhab) ?? 'hanafi';
  void saveMadhab(String id) => _box.write(AppConstants.keyMadhab, id);

  String getMuazzin() => _box.read<String>(AppConstants.keyMuazzin) ?? 'makkah';
  void saveMuazzin(String id) => _box.write(AppConstants.keyMuazzin, id);

  /// Full azan audio at prayer time instead of a notification (Android).
  bool getAzanAudio() => _box.read<bool>('azan_audio_on') ?? false;
  void saveAzanAudio(bool on) => _box.write('azan_audio_on', on);

  /// Prayers that play the full azan; the others get a notification.
  List<String> getAzanAudioPrayers() =>
      (_box.read<List>('azan_audio_prayers') ?? const ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']).cast<String>();
  void saveAzanAudioPrayers(List<String> prayers) => _box.write('azan_audio_prayers', prayers);

  bool getAzanReady(String muazzinId) => _box.read<bool>('azan_ready_$muazzinId') ?? false;
  void saveAzanReady(String muazzinId, bool ready) => _box.write('azan_ready_$muazzinId', ready);

  double getAzanVolume() => (_box.read<num>('azan_volume') ?? 0.8).toDouble();
  void saveAzanVolume(double v) => _box.write('azan_volume', v);

  /// Minutes after the waqt begins that the masjid gives the azan.
  static const Map<String, int> bangladeshAzanOffsets = {
    'Fajr': 15,
    'Dhuhr': 60,
    'Asr': 10,
    'Maghrib': 3,
    'Isha': 20,
  };

  Map<String, int> getAzanOffsets() {
    final raw = _box.read<String>(AppConstants.keyAzanOffsets);
    if (raw == null) return Map<String, int>.from(bangladeshAzanOffsets);
    final decoded = Map<String, dynamic>.from(jsonDecode(raw) as Map);
    return {
      for (final name in bangladeshAzanOffsets.keys) name: (decoded[name] as num?)?.toInt() ?? 0,
    };
  }

  void saveAzanOffsets(Map<String, int> offsets) => _box.write(AppConstants.keyAzanOffsets, jsonEncode(offsets));

  // ─── Quran text cache (per surah and edition) ───
  // ─── Quran reading progress (device only) ───
  Map<int, Set<int>> getReadAyahs() {
    final raw = _box.read<String>(AppConstants.keyQuranReadAyahs);
    if (raw == null) return {};
    final decoded = Map<String, dynamic>.from(jsonDecode(raw) as Map);
    return decoded.map((k, v) => MapEntry(int.parse(k), (v as List).map((e) => (e as num).toInt()).toSet()));
  }

  void saveReadAyahs(Map<int, Set<int>> read) {
    _box.write(
      AppConstants.keyQuranReadAyahs,
      jsonEncode(read.map((k, v) => MapEntry(k.toString(), v.toList()..sort()))),
    );
  }

  Map<String, int> getReadDays() {
    final raw = _box.read<String>(AppConstants.keyQuranReadDays);
    if (raw == null) return {};
    return Map<String, dynamic>.from(jsonDecode(raw) as Map).map((k, v) => MapEntry(k, (v as num).toInt()));
  }

  void saveReadDays(Map<String, int> days) => _box.write(AppConstants.keyQuranReadDays, jsonEncode(days));

  int getDailyAyahGoal() => _box.read<int>(AppConstants.keyQuranDailyGoal) ?? 10;
  void saveDailyAyahGoal(int goal) => _box.write(AppConstants.keyQuranDailyGoal, goal);

  /// Quran text now lives in files (see QuranOfflineStore). Older builds kept
  /// it here, and GetStorage loads every key into memory at start.
  void purgeLegacyQuranCache() {
    final keys = _box.getKeys<Iterable<String>>().where((k) => k.startsWith('quran_cache_')).toList();
    for (final k in keys) {
      _box.remove(k);
    }
  }

  // ─── App language and reader ───
  String getAppLanguage() => _box.read<String>(AppConstants.keyAppLanguage) ?? deviceLanguage();
  void saveAppLanguage(String code) => _box.write(AppConstants.keyAppLanguage, code);

  /// Bangla when the phone is set to Bangla, otherwise English.
  static String deviceLanguage() =>
      ui.PlatformDispatcher.instance.locales.any((l) => l.languageCode == 'bn') ? 'bn' : 'en';

  // ─── First launch ───
  /// Older installs already set things up, so they skip onboarding.
  bool isOnboarded() =>
      _box.read<bool>(AppConstants.keyOnboarded) ??
      (_box.hasData(AppConstants.keyAppLanguage) || _box.hasData(AppConstants.keyUserName));
  void setOnboarded() => _box.write(AppConstants.keyOnboarded, true);

  /// Last place used for prayer times: `{lat, lng, name, country, gps}`.
  /// Only the current place is kept on the phone; it is not in backups.
  Map<String, dynamic>? getLocation() {
    final raw = _box.read<String>(AppConstants.keyLocation);
    if (raw == null) return null;
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  void saveLocation({
    required double lat,
    required double lng,
    required String name,
    String? country,
    required bool gps,
  }) =>
      _box.write(
        AppConstants.keyLocation,
        jsonEncode({'lat': lat, 'lng': lng, 'name': name, 'country': country, 'gps': gps}),
      );

  bool getRemindersNotif() => _box.read<bool>(AppConstants.keyRemindersNotif) ?? true;
  void saveRemindersNotif(bool val) => _box.write(AppConstants.keyRemindersNotif, val);

  String? getTafsir() => _box.read<String>(AppConstants.keyTafsir);
  void saveTafsir(String id) => _box.write(AppConstants.keyTafsir, id);

  int getArabicFont() => _box.read<int>(AppConstants.keyArabicFont) ?? 0;
  void saveArabicFont(int index) => _box.write(AppConstants.keyArabicFont, index);

  int getHijriAdjust() => _box.read<int>(AppConstants.keyHijriAdjust) ?? 0;
  void saveHijriAdjust(int days) => _box.write(AppConstants.keyHijriAdjust, days);

  // ─── Ramadan fasts: hijri year → day → status ───
  Map<int, String> getRamadanFasts(int hijriYear) {
    final raw = _box.read<String>(AppConstants.keyRamadanFasts);
    if (raw == null) return {};
    final all = Map<String, dynamic>.from(jsonDecode(raw) as Map);
    final year = all['$hijriYear'];
    if (year is! Map) return {};
    return year.map((k, v) => MapEntry(int.parse(k.toString()), v.toString()));
  }

  void saveRamadanFasts(int hijriYear, Map<int, String> fasts) {
    final raw = _box.read<String>(AppConstants.keyRamadanFasts);
    final all = raw == null ? <String, dynamic>{} : Map<String, dynamic>.from(jsonDecode(raw) as Map);
    all['$hijriYear'] = fasts.map((k, v) => MapEntry('$k', v));
    _box.write(AppConstants.keyRamadanFasts, jsonEncode(all));
  }

  Map<String, String> getZakatInputs() {
    final raw = _box.read<String>(AppConstants.keyZakatInputs);
    if (raw == null) return {};
    return Map<String, dynamic>.from(jsonDecode(raw) as Map).map((k, v) => MapEntry(k, v.toString()));
  }

  void saveZakatInputs(Map<String, String> values) => _box.write(AppConstants.keyZakatInputs, jsonEncode(values));

  // ─── Reflection journal (device only) ───
  List<Map<String, dynamic>> getJournal() {
    final raw = _box.read<String>(AppConstants.keyJournal);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  void addJournalNote({
    required String text,
    String? reference,
    int? surah,
    int? ayah,
  }) {
    final list = getJournal();
    list.insert(0, {
      'id': DateTime.now().microsecondsSinceEpoch.toString(),
      'text': text,
      'reference': reference ?? '',
      'surah': surah,
      'ayah': ayah,
      'createdAt': DateTime.now().toIso8601String(),
    });
    _box.write(AppConstants.keyJournal, jsonEncode(list));
  }

  void removeJournalNote(String id) {
    final list = getJournal()..removeWhere((n) => n['id'] == id);
    _box.write(AppConstants.keyJournal, jsonEncode(list));
  }

  void saveJournal(List<Map<String, dynamic>> notes) => _box.write(AppConstants.keyJournal, jsonEncode(notes));

  /// Ayahs the user added to a theme: themeId -> ['surah:from:to', ...].
  Map<String, List<String>> getThemeSaves() {
    final raw = _box.read<String>(AppConstants.keyThemeSaves);
    if (raw == null) return {};
    final map = Map<String, dynamic>.from(jsonDecode(raw) as Map);
    return map.map((k, v) => MapEntry(k, (v as List).map((e) => e.toString()).toList()));
  }

  void saveThemeSaves(Map<String, List<String>> saves) =>
      _box.write(AppConstants.keyThemeSaves, jsonEncode(saves));

  // ─── Ramadan checklist ───
  Set<String> getRamadanChecks(String dateKey) {
    final raw = _box.read<String>(AppConstants.keyRamadanChecks);
    if (raw == null) return {};
    final map = Map<String, dynamic>.from(jsonDecode(raw) as Map);
    final items = map[dateKey];
    if (items is! List) return {};
    return items.map((e) => e.toString()).toSet();
  }

  void saveRamadanChecks(String dateKey, Set<String> items) {
    final raw = _box.read<String>(AppConstants.keyRamadanChecks);
    final map = raw == null ? <String, dynamic>{} : Map<String, dynamic>.from(jsonDecode(raw) as Map);
    map[dateKey] = items.toList();
    _box.write(AppConstants.keyRamadanChecks, jsonEncode(map));
  }

  int getAyahCardBackground() => _box.read<int>(AppConstants.keyAyahCardBg) ?? 0;
  void saveAyahCardBackground(int index) => _box.write(AppConstants.keyAyahCardBg, index);

  bool getAyahCardAmiri() => _box.read<bool>(AppConstants.keyAyahCardAmiri) ?? true;
  void saveAyahCardAmiri(bool value) => _box.write(AppConstants.keyAyahCardAmiri, value);

  int getAyahCardFont() => _box.read<int>(AppConstants.keyAyahCardFont) ?? 0;
  void saveAyahCardFont(int index) => _box.write(AppConstants.keyAyahCardFont, index);

  int getAyahCardArt() => _box.read<int>(AppConstants.keyAyahCardArt) ?? 0;
  void saveAyahCardArt(int index) => _box.write(AppConstants.keyAyahCardArt, index);

  String exportBackupJson() {
    return jsonEncode({
      'app': 'al_noor',
      'exportedAt': DateTime.now().toIso8601String(),
      'userName': getUserName(),
      'bookmarks': getBookmarks().map((e) => e.toJson()).toList(),
      'lastRead': getLastRead()?.toJson(),
      'quranReadAyahs': _box.read<String>(AppConstants.keyQuranReadAyahs),
      'quranReadDays': getReadDays(),
      'quranDailyGoal': getDailyAyahGoal(),
      'journal': getJournal(),
      'themeSaves': getThemeSaves(),
      'ramadanChecks': _box.read<String>(AppConstants.keyRamadanChecks),
      'ramadanFasts': _box.read<String>(AppConstants.keyRamadanFasts),
      'appLanguage': getAppLanguage(),
      'translation': getTranslation(),
      'reciter': getReciter(),
      'hijriAdjust': getHijriAdjust(),
      'calcMethod': getCalcMethod(),
      'madhab': getMadhab(),
      'muazzin': getMuazzin(),
      'azanOffsets': getAzanOffsets(),
    });
  }
}
