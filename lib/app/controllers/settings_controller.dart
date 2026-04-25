// lib/app/controllers/settings_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/storage_service.dart';

class SettingsController extends GetxController {
  final StorageService _storage = Get.find();

  final RxBool isDarkMode = false.obs;
  final RxString userName = 'Abdullah'.obs;
  final RxString translation = 'English'.obs;
  final RxString reciter = 'Abdul Basit Samad'.obs;
  final RxBool allNotifications = true.obs;
  final RxBool prayerAlerts = true.obs;
  final RxBool dailyVerse = true.obs;
  final RxBool readingGoal = false.obs;
  final RxInt selectedTheme = 0.obs;

  static const List<Color> themeColors = [
    Color(0xFF1B6B3A),
    Color(0xFF1E3A5F),
    Color(0xFF92400E),
    Color(0xFF881337),
  ];

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = _storage.getDarkMode();
    userName.value = _storage.getUserName();
    translation.value = _storage.getTranslation() == 'en' ? 'English' : 'Bengali';
    allNotifications.value = _storage.getPrayerNotif();
    dailyVerse.value = _storage.getDailyVerseNotif();
  }

  void toggleDarkMode(bool val) {
    isDarkMode.value = val;
    _storage.saveDarkMode(val);
    Get.changeThemeMode(val ? ThemeMode.dark : ThemeMode.light);
  }

  void updateUserName(String name) {
    userName.value = name;
    _storage.saveUserName(name);
  }

  void toggleAllNotifications(bool val) {
    allNotifications.value = val;
    _storage.savePrayerNotif(val);
  }

  void togglePrayerAlerts(bool val) => prayerAlerts.value = val;
  void toggleDailyVerse(bool val) { dailyVerse.value = val; _storage.saveDailyVerseNotif(val); }
  void toggleReadingGoal(bool val) => readingGoal.value = val;
  void selectTheme(int index) => selectedTheme.value = index;
}
