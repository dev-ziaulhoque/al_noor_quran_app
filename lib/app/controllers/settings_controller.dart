// lib/app/controllers/settings_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../core/prayer/prayer_options.dart';
import '../../core/quran/quran_catalog.dart';
import '../../core/utils/hijri_date.dart';
import '../../data/services/notification_service.dart';
import '../../data/services/storage_service.dart';
import 'prayer_controller.dart';
import 'quran_controller.dart';

class SettingsController extends GetxController {
  final StorageService _storage = Get.find();

  static const List<String> appLanguages = ['en', 'bn'];

  final RxBool isDarkMode = false.obs;
  final RxString appLanguage = 'en'.obs;
  final RxString userName = 'Abdullah'.obs;
  final RxString translationId = QuranCatalog.defaultTranslation.obs;
  final RxString reciterId = QuranCatalog.defaultReciter.obs;
  final RxString tafsirId = QuranCatalog.defaultTafsir.obs;
  final RxInt arabicFont = 0.obs;
  final RxInt hijriAdjust = 0.obs;
  final RxBool allNotifications = true.obs;
  final RxBool prayerAlerts = true.obs;
  final RxBool dailyVerse = true.obs;
  final RxBool readingGoal = false.obs;
  final RxBool reminders = true.obs;
  final RxString calcMethodId = PrayerOptions.defaultMethodId.obs;
  final RxString madhabId = PrayerOptions.defaultMadhabId.obs;
  final RxString muazzinId = PrayerOptions.defaultMuazzinId.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
    SchedulerBinding.instance.addPostFrameCallback((_) => _applyThemeMode());
  }

  void _applyThemeMode() {
    final dark = isDarkMode.value;
    Get.changeThemeMode(dark ? ThemeMode.dark : ThemeMode.light);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
    ));
  }

  void _loadSettings() {
    isDarkMode.value = _storage.getDarkMode();
    appLanguage.value = _storage.getAppLanguage();
    userName.value = _storage.getUserName();
    allNotifications.value = _storage.getPrayerNotif();
    prayerAlerts.value = _storage.getPrayerAlertsNotif();
    dailyVerse.value = _storage.getDailyVerseNotif();
    readingGoal.value = _storage.getReadingGoalNotif();
    reminders.value = _storage.getRemindersNotif();
    calcMethodId.value = _storage.getCalcMethod();
    madhabId.value = _storage.getMadhab();
    muazzinId.value = _storage.getMuazzin();
    arabicFont.value = _storage.getArabicFont();
    hijriAdjust.value = _storage.getHijriAdjust();
    HijriDate.adjustmentDays = hijriAdjust.value;

    translationId.value = QuranCatalog.migrateTranslation(_storage.getTranslation());
    _storage.saveTranslation(translationId.value);
    reciterId.value = QuranCatalog.migrateReciter(_storage.getReciter());
    _storage.saveReciter(reciterId.value);
    final tafsir = _storage.getTafsir();
    tafsirId.value = tafsir == null || (tafsir != QuranCatalog.noTafsir && QuranCatalog.tafsirById(tafsir) == null)
        ? QuranCatalog.defaultTafsir
        : tafsir;
  }

  void toggleDarkMode(bool val) {
    isDarkMode.value = val;
    _storage.saveDarkMode(val);
    _applyThemeMode();
    Get.forceAppUpdate();
  }

  bool get isBangla => appLanguage.value == 'bn';

  void setAppLanguage(String code) {
    if (!appLanguages.contains(code)) return;
    appLanguage.value = code;
    _storage.saveAppLanguage(code);
    Get.updateLocale(Locale(code));
  }

  TranslationOption get translationOption => QuranCatalog.translationById(translationId.value);
  ReciterOption get reciterOption => QuranCatalog.reciterById(reciterId.value);
  TafsirOption? get tafsirOption => QuranCatalog.tafsirById(tafsirId.value);

  /// Language for word-by-word meanings; Quran.com covers fewer languages.
  String get studyLanguageCode {
    final code = translationOption.languageCode;
    return QuranCatalog.wordByWordLanguages.contains(code) ? code : 'en';
  }

  /// Daily cards and duas carry English and Bangla meanings.
  bool get prefersBanglaMeaning => isBangla || translationOption.languageCode == 'bn';

  String get translationSourceLabel => '${translationOption.translator} · ${translationOption.id}';

  void updateUserName(String name) {
    if (name.isNotEmpty) {
      userName.value = name;
      _storage.saveUserName(name);
      Get.snackbar('Profile Updated'.tr, name, snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 1));
    }
  }

  String getReciterId() => reciterId.value;
  String getTranslationEditionId() => translationId.value;

  void selectReciter(String id) {
    if (reciterId.value == id) return;
    reciterId.value = id;
    _storage.saveReciter(id);
    _reloadActiveQuranReader();
  }

  void selectTranslation(String id) {
    if (translationId.value == id) return;
    translationId.value = id;
    _storage.saveTranslation(id);
    _reloadActiveQuranReader();
  }

  void selectTafsir(String id) {
    tafsirId.value = id;
    _storage.saveTafsir(id);
  }

  void selectArabicFont(int index) {
    arabicFont.value = index;
    _storage.saveArabicFont(index);
  }

  void setHijriAdjust(int days) {
    hijriAdjust.value = days.clamp(-2, 2);
    HijriDate.adjustmentDays = hijriAdjust.value;
    _storage.saveHijriAdjust(hijriAdjust.value);
    _reschedulePrayerAlerts();
  }

  void _reloadActiveQuranReader() {
    if (Get.isRegistered<QuranController>()) {
      final qCtrl = Get.find<QuranController>();
      if (qCtrl.currentSurah.value != null) {
        qCtrl.loadSurahAyahs(qCtrl.currentSurah.value!);
      }
    }
  }

  Future<void> toggleAllNotifications(bool val) async {
    if (val) await _askNotificationPermission();
    allNotifications.value = val;
    prayerAlerts.value = val;
    dailyVerse.value = val;
    readingGoal.value = val;
    reminders.value = val;
    _storage.savePrayerNotif(val);
    _storage.savePrayerAlertsNotif(val);
    _storage.saveDailyVerseNotif(val);
    _storage.saveReadingGoalNotif(val);
    _storage.saveRemindersNotif(val);
    _reschedulePrayerAlerts();
  }

  Future<void> togglePrayerAlerts(bool val) async {
    if (val) await _askNotificationPermission();
    prayerAlerts.value = val;
    _storage.savePrayerAlertsNotif(val);
    _reschedulePrayerAlerts();
  }

  /// Jumu'ah (Al-Kahf) and Ramadan sehri/iftar reminders.
  Future<void> toggleReminders(bool val) async {
    if (val) await _askNotificationPermission();
    reminders.value = val;
    _storage.saveRemindersNotif(val);
    _reschedulePrayerAlerts();
  }

  Future<void> _askNotificationPermission() async {
    final granted = await NotificationService.instance.ensurePermission();
    if (!granted) {
      Get.snackbar(
        'Notifications are off'.tr,
        'Allow notifications for Al-Noor in your phone settings to get alerts.'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void selectCalcMethod(String id) {
    calcMethodId.value = id;
    _storage.saveCalcMethod(id);
    _reschedulePrayerAlerts();
  }

  void selectMadhab(String id) {
    madhabId.value = id;
    _storage.saveMadhab(id);
    _reschedulePrayerAlerts();
  }

  void selectMuazzin(String id) {
    muazzinId.value = id;
    _storage.saveMuazzin(id);
    _reschedulePrayerAlerts();
  }

  void _reschedulePrayerAlerts() {
    if (Get.isRegistered<PrayerController>()) {
      Get.find<PrayerController>().reload();
    }
  }

  Future<void> toggleDailyVerse(bool val) async {
    if (val) await _askNotificationPermission();
    dailyVerse.value = val;
    _storage.saveDailyVerseNotif(val);
    _reschedulePrayerAlerts();
  }

  void toggleReadingGoal(bool val) {
    readingGoal.value = val;
    _storage.saveReadingGoalNotif(val);
  }
}
