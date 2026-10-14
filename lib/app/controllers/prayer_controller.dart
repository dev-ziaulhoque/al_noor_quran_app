import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/calendar/islamic_events.dart';
import '../../core/i18n/locale_text.dart';
import '../../core/prayer/cities.dart';
import '../../core/prayer/prayer_options.dart';
import '../../core/utils/hijri_date.dart';
import '../../data/content/daily_ayahs.dart';
import '../../data/services/azan_audio_service.dart';
import '../../data/services/notification_service.dart';
import '../../data/services/storage_service.dart';
import 'settings_controller.dart';

class PrayerController extends GetxController {
  final RxBool isLoading = true.obs;
  final RxString locationName = 'Dhaka'.obs;
  final Rx<PrayerTimes?> prayerTimes = Rx<PrayerTimes?>(null);
  final RxString nextPrayerName = 'Fajr'.obs;
  final RxString nextPrayerTimeStr = '--:--'.obs;
  final RxString timeRemainingStr = '--'.obs;
  final RxString methodName = ''.obs;
  final RxString madhabName = ''.obs;
  final RxString muazzinName = ''.obs;

  double latitude = 23.8103;
  double longitude = 90.4125;
  final RxBool usingGps = false.obs;
  String? country = 'BD';

  StorageService get _storage => Get.find<StorageService>();

  @override
  void onInit() {
    super.onInit();
    final saved = _storage.getLocation();
    if (saved != null) {
      latitude = (saved['lat'] as num).toDouble();
      longitude = (saved['lng'] as num).toDouble();
      locationName.value = saved['name'] as String? ?? 'Dhaka';
      country = saved['country'] as String?;
      usingGps.value = saved['gps'] == true;
    }
    calculatePrayerTimes();
    if (Get.isRegistered<AzanAudioService>()) {
      ever(Get.find<AzanAudioService>().ready, (_) => syncNotifications());
    }
    if (saved == null || usingGps.value) _refreshGpsSilently();
  }

  /// Updates a GPS place only when location access was already given, so
  /// opening the app never shows a permission prompt.
  Future<void> _refreshGpsSilently() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return;
      final permission = await Geolocator.checkPermission();
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) return;
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low)
          .timeout(const Duration(seconds: 12));
      _applyGps(position.latitude, position.longitude, autoMethod: false);
    } catch (_) {
      // Keep the saved place.
    }
  }

  /// Asks for location (from onboarding or settings). Returns null on
  /// success, otherwise a message to show.
  Future<String?> useDeviceLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return 'Turn on location (GPS) on your phone, or choose your city.'.tr;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
        return 'Location was not allowed. You can choose your city instead.'.tr;
      }
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low)
          .timeout(const Duration(seconds: 20));
      _applyGps(position.latitude, position.longitude, autoMethod: true);
      return null;
    } catch (_) {
      return 'Could not get your location. Please choose your city.'.tr;
    }
  }

  void _applyGps(double lat, double lng, {required bool autoMethod}) {
    final match = Cities.nearest(lat, lng);
    final near = Cities.countryNear(lat, lng);
    final name = match.km <= 40 ? match.city.name : (near == null ? 'Your location' : 'Near ${match.city.name}');
    _setPlace(lat, lng, name, near, gps: true, autoMethod: autoMethod);
  }

  void setCity(City city) => _setPlace(city.lat, city.lng, city.name, city.country, gps: false, autoMethod: true);

  void _setPlace(double lat, double lng, String name, String? countryCode, {required bool gps, required bool autoMethod}) {
    latitude = lat;
    longitude = lng;
    locationName.value = name;
    country = countryCode;
    usingGps.value = gps;
    _storage.saveLocation(lat: lat, lng: lng, name: name, country: countryCode, gps: gps);
    if (autoMethod) {
      final (method, madhab) = Cities.prayerDefaults(countryCode);
      _storage.saveCalcMethod(method);
      _storage.saveMadhab(madhab);
      if (Get.isRegistered<SettingsController>()) {
        final s = Get.find<SettingsController>();
        s.calcMethodId.value = method;
        s.madhabId.value = madhab;
      }
    }
    calculatePrayerTimes();
  }

  /// Place name in the app language ("Near Sylhet" -> "সিলেটের কাছে").
  String get placeLabel {
    final raw = locationName.value;
    if (raw == 'Your location') return 'Your location'.tr;
    final near = raw.startsWith('Near ');
    final city = Cities.byName(near ? raw.substring(5) : raw);
    if (city == null) return raw;
    final label = city.label(LocaleText.isBangla);
    return near ? 'Near @city'.trParams({'city': label}) : label;
  }

  void reload() => calculatePrayerTimes();

  CalculationParameters _parameters() {
    final method = PrayerOptions.methodById(_storage.getCalcMethod());
    final madhab = PrayerOptions.madhabById(_storage.getMadhab());
    final params = method.method.getParameters();
    params.madhab = madhab.madhab;
    methodName.value = method.name;
    madhabName.value = madhab.name;
    muazzinName.value = PrayerOptions.muazzinById(_storage.getMuazzin()).name;
    return params;
  }

  void calculatePrayerTimes() {
    final coordinates = Coordinates(latitude, longitude);
    final params = _parameters();
    final now = DateTime.now();
    azanOffsets.assignAll(_storage.getAzanOffsets());
    final pTimes = PrayerTimes(coordinates, DateComponents.from(now), params);
    prayerTimes.value = pTimes;
    _updateNextPrayer(pTimes, now, params);
    isLoading.value = false;
    syncNotifications();
  }

  final RxMap<String, int> azanOffsets = <String, int>{}.obs;

  void saveAzanOffsets(Map<String, int> offsets) {
    _storage.saveAzanOffsets(offsets);
    calculatePrayerTimes();
  }

  final Rx<DateTime?> nextAzanAt = Rx<DateTime?>(null);

  /// Waqt start times for any day, in local time.
  Map<String, DateTime> waqtFor(DateTime day) =>
      _waqtTimes(PrayerTimes(Coordinates(latitude, longitude), DateComponents.from(day), _parameters()));

  Map<String, DateTime> get todayWaqt {
    final pt = prayerTimes.value;
    return pt == null ? {} : _waqtTimes(pt);
  }

  DateTime azanAt(String name, DateTime waqt) => _azanTime(name, waqt);

  Map<String, DateTime> _waqtTimes(PrayerTimes pt) => {
        'Fajr': pt.fajr.toLocal(),
        'Sunrise': pt.sunrise.toLocal(),
        'Dhuhr': pt.dhuhr.toLocal(),
        'Asr': pt.asr.toLocal(),
        'Maghrib': pt.maghrib.toLocal(),
        'Isha': pt.isha.toLocal(),
      };

  DateTime _azanTime(String name, DateTime waqt) => waqt.add(Duration(minutes: azanOffsets[name] ?? 0));

  void _updateNextPrayer(PrayerTimes pTimes, DateTime now, CalculationParameters params) {
    var name = 'Fajr';
    DateTime? nextTime;
    for (final entry in _waqtTimes(pTimes).entries) {
      if (entry.key == 'Sunrise') continue;
      final azan = _azanTime(entry.key, entry.value);
      if (azan.isAfter(now)) {
        name = entry.key;
        nextTime = azan;
        break;
      }
    }
    if (nextTime == null) {
      final tomorrow = DateComponents.from(now.add(const Duration(days: 1)));
      final tomorrowTimes = PrayerTimes(Coordinates(latitude, longitude), tomorrow, params);
      name = 'Fajr';
      nextTime = _azanTime('Fajr', tomorrowTimes.fajr.toLocal());
    }

    nextPrayerName.value = name;
    nextAzanAt.value = nextTime;
    nextPrayerTimeStr.value = DateFormat.jm().format(nextTime);
    final diff = nextTime.difference(now);
    if (diff.inHours > 0) {
      timeRemainingStr.value = 'In ${diff.inHours} hr ${diff.inMinutes.remainder(60)} min';
    } else if (diff.inMinutes > 0) {
      timeRemainingStr.value = 'In ${diff.inMinutes} min';
    } else {
      timeRemainingStr.value = 'Right Now';
    }
  }

  String formatPrayerTime(DateTime? time) {
    if (time == null) return '--:--';
    return DateFormat.jm().format(time.toLocal());
  }

  /// `time` is the masjid azan time. `waqt` is when the prayer time begins
  /// (use it for sehri and iftar).
  List<Map<String, dynamic>> getPrayerList() {
    final pt = prayerTimes.value;
    if (pt == null) return [];
    final next = nextPrayerName.value;

    return _waqtTimes(pt).entries.map((entry) {
      final azan = _azanTime(entry.key, entry.value);
      return {
        'name': entry.key,
        'time': formatPrayerTime(azan),
        'waqt': formatPrayerTime(entry.value),
        'offset': azanOffsets[entry.key] ?? 0,
        'next': next == entry.key,
      };
    }).toList();
  }

  int get nextPrayerIndex {
    final list = getPrayerList();
    final idx = list.indexWhere((p) => p['next'] == true);
    return idx >= 0 ? idx : 0;
  }

  Future<void> syncNotifications() async {
    final master = _storage.getPrayerNotif();
    final alerts = <ScheduledAlert>[];
    final azan = Get.isRegistered<AzanAudioService>() ? Get.find<AzanAudioService>() : null;
    var azanSlots = const <AzanSlot>[];
    if (master && _storage.getPrayerAlertsNotif()) {
      final audio = azan != null && azan.isActive ? azan.audioPrayers.toSet() : const <String>{};
      final (prayerAlerts, slots) = _prayerAlerts(audio: audio);
      alerts.addAll(prayerAlerts);
      azanSlots = slots;
      alerts.addAll(_dateAlerts());
    }
    await azan?.schedule(azanSlots);
    if (master && _storage.getDailyVerseNotif()) alerts.addAll(_dailyAyahAlerts());
    if (master && _storage.getRemindersNotif()) {
      alerts.addAll(_jumuahAlerts());
      alerts.addAll(_ramadanAlerts());
    }
    await NotificationService.instance.replaceAlerts(alerts, enabled: alerts.isNotEmpty);
  }

  /// Ayah of the day at 7 AM for the coming week.
  List<ScheduledAlert> _dailyAyahAlerts() {
    final bn = LocaleText.isBangla;
    final now = DateTime.now();
    return [
      for (var d = 0; d < 7; d++)
        () {
          final day = DateTime(now.year, now.month, now.day + d, 7);
          final ayah = DailyAyahs.forDate(day);
          final meaning = bn ? ayah.meaningBn : ayah.meaningEn;
          return ScheduledAlert(
            id: 200 + d,
            kind: AlertKind.dailyAyah,
            title: '${'Ayah of the day'.tr} · ${ayah.reference}',
            body: meaning,
            bigText: '${ayah.arabic}\n\n$meaning',
            subText: 'Tap to read with meaning'.tr,
            payload: NotificationPayload.ayah(ayah.surah, ayah.ayah),
            when: day,
          );
        }(),
    ];
  }

  /// Surah Al-Kahf on Friday morning, for the next two Fridays.
  List<ScheduledAlert> _jumuahAlerts() {
    final now = DateTime.now();
    final alerts = <ScheduledAlert>[];
    var day = DateTime(now.year, now.month, now.day, 9);
    var id = 220;
    while (alerts.length < 2) {
      if (day.weekday == DateTime.friday && day.isAfter(now)) {
        alerts.add(ScheduledAlert(
          id: id++,
          kind: AlertKind.jumuah,
          title: "Jumu'ah Mubarak".tr,
          body: 'A good day to read Surah Al-Kahf and send salawat on the Prophet ﷺ.'.tr,
          subText: 'Surah Al-Kahf'.tr,
          payload: NotificationPayload.ayah(18, 1),
          when: day,
        ));
      }
      day = day.add(const Duration(days: 1));
    }
    return alerts;
  }

  /// Sehri ends and iftar reminders during Ramadan, for today and tomorrow.
  List<ScheduledAlert> _ramadanAlerts() {
    final alerts = <ScheduledAlert>[];
    final now = DateTime.now();
    for (var d = 0; d < 2; d++) {
      final day = DateTime(now.year, now.month, now.day + d);
      if (HijriDate.fromGregorian(day).month != 9) continue;
      final w = waqtFor(day);
      final fajr = w['Fajr']!;
      final maghrib = w['Maghrib']!;
      alerts.add(ScheduledAlert(
        id: 230 + d * 2,
        kind: AlertKind.ramadan,
        title: 'Sehri ends soon'.tr,
        body: 'Sehri ends at @time.'.trParams({'time': LocaleText.time(fajr)}),
        subText: placeLabel,
        payload: NotificationPayload.ramadan,
        when: fajr.subtract(const Duration(minutes: 30)),
      ));
      alerts.add(ScheduledAlert(
        id: 231 + d * 2,
        kind: AlertKind.ramadan,
        title: 'Iftar is near'.tr,
        body: 'Iftar at @time. Make dua before you break your fast.'.trParams({'time': LocaleText.time(maghrib)}),
        subText: placeLabel,
        payload: NotificationPayload.ramadan,
        when: maghrib.subtract(const Duration(minutes: 10)),
      ));
    }
    return alerts;
  }

  static const _alertDays = 6;

  /// Words from the azan itself, shown when the alert is expanded.
  static const _azanCall = {
    'Fajr': 'الصَّلَاةُ خَيْرٌ مِنَ النَّوْمِ',
    'default': 'حَيَّ عَلَى الصَّلَاةِ · حَيَّ عَلَى الْفَلَاحِ',
  };

  /// Azan alerts; prayers in [audio] play the full azan instead and are
  /// returned as [AzanSlot]s rather than notifications.
  (List<ScheduledAlert>, List<AzanSlot>) _prayerAlerts({Set<String> audio = const {}}) {
    final params = _parameters();
    final coordinates = Coordinates(latitude, longitude);
    final now = DateTime.now();
    final place = placeLabel;
    final alerts = <ScheduledAlert>[];
    final azans = <AzanSlot>[];

    // Six days ahead so alerts keep coming even if the app is not opened;
    // stays under iOS's 64 pending notification limit with the other kinds.
    for (var offset = 0; offset < _alertDays; offset++) {
      final day = now.add(Duration(days: offset));
      final times = PrayerTimes(coordinates, DateComponents.from(day), params);
      final slots = {
        'Fajr': times.fajr,
        'Dhuhr': times.dhuhr,
        'Asr': times.asr,
        'Maghrib': times.maghrib,
        'Isha': times.isha,
      };
      var index = 0;
      for (final entry in slots.entries) {
        final at = _azanTime(entry.key, entry.value.toLocal());
        final prayer = entry.key.tr;
        final body = (entry.key == 'Fajr'
                ? "It's time for @prayer. Prayer is better than sleep."
                : "It's time for @prayer. Come to prayer, come to success.")
            .trParams({'prayer': prayer});
        final title = '@prayer azan · @time'.trParams({'prayer': prayer, 'time': LocaleText.time(at)});
        if (audio.contains(entry.key)) {
          azans.add((prayer: entry.key, at: at, title: title, body: '$body · $place'));
        } else {
          alerts.add(ScheduledAlert(
            id: 10 + offset * 10 + index,
            kind: AlertKind.azan,
            title: title,
            body: body,
            bigText: '${_azanCall[entry.key] ?? _azanCall['default']!}\n$body',
            subText: place,
            payload: NotificationPayload.azan,
            when: at,
          ));
        }
        index++;
      }
    }
    return (alerts, azans);
  }

  List<ScheduledAlert> _dateAlerts() {
    final upcoming = IslamicEvents.upcoming(DateTime.now());
    final alerts = <ScheduledAlert>[];
    var id = 100;
    for (final item in upcoming.take(8)) {
      final bn = LocaleText.isBangla;
      alerts.add(ScheduledAlert(
        id: id++,
        kind: AlertKind.islamicDate,
        title: bn ? item.event.nameBn : item.event.name,
        body: 'Expected @date. Confirm the moon sighting with your local mosque.'
            .trParams({'date': LocaleText.hijri(item.hijri)}),
        bigText: '${bn ? item.event.noteBn : item.event.note}\n\n${'Expected @date. Confirm the moon sighting with your local mosque.'.trParams({'date': LocaleText.hijri(item.hijri)})}',
        subText: 'Islamic calendar'.tr,
        payload: NotificationPayload.calendar,
        when: DateTime(item.gregorian.year, item.gregorian.month, item.gregorian.day, 8),
      ));
    }
    return alerts;
  }
}
