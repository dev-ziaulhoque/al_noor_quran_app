// lib/data/services/storage_service.dart
import 'package:get_storage/get_storage.dart';
import '../../core/constants/app_constants.dart';
import '../models/models.dart';
import 'dart:convert';

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
  bool getDarkMode() => _box.read<bool>(AppConstants.keyDarkMode) ?? false;
  void saveDarkMode(bool val) => _box.write(AppConstants.keyDarkMode, val);

  double getFontSize() => _box.read<double>(AppConstants.keyFontSize) ?? AppConstants.defaultFontSize;
  void saveFontSize(double size) => _box.write(AppConstants.keyFontSize, size);

  String getTranslation() => _box.read<String>(AppConstants.keyTranslation) ?? AppConstants.defaultTranslation;
  void saveTranslation(String lang) => _box.write(AppConstants.keyTranslation, lang);

  String getReciter() => _box.read<String>(AppConstants.keyReciter) ?? AppConstants.defaultReciter;
  void saveReciter(String reciter) => _box.write(AppConstants.keyReciter, reciter);

  String getUserName() => _box.read<String>(AppConstants.keyUserName) ?? 'Abdullah';
  void saveUserName(String name) => _box.write(AppConstants.keyUserName, name);

  bool getPrayerNotif() => _box.read<bool>(AppConstants.keyPrayerNotif) ?? true;
  void savePrayerNotif(bool val) => _box.write(AppConstants.keyPrayerNotif, val);

  bool getDailyVerseNotif() => _box.read<bool>(AppConstants.keyDailyVerseNotif) ?? true;
  void saveDailyVerseNotif(bool val) => _box.write(AppConstants.keyDailyVerseNotif, val);

  // ─── Tracker ───
  Map<String, dynamic> getTrackerData() {
    final raw = _box.read<String>(AppConstants.keyTrackerData);
    if (raw == null) return {};
    return Map<String, dynamic>.from(jsonDecode(raw));
  }

  void saveTrackerData(Map<String, dynamic> data) {
    _box.write(AppConstants.keyTrackerData, jsonEncode(data));
  }
}
