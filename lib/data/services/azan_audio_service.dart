import 'dart:async';
import 'dart:io';

import 'package:alarm/alarm.dart';
import 'package:alarm/utils/alarm_set.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show Color;
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/prayer/prayer_options.dart';
import 'storage_service.dart';

typedef AzanSlot = ({String prayer, DateTime at, String title, String body});

/// Plays the full azan at prayer time through a native alarm, so it sounds
/// even when the app is closed or the phone is on silent. Android only: iOS
/// stops background audio when the app is killed, so iPhones keep the
/// notification.
class AzanAudioService extends GetxService {
  static const _source =
      'https://archive.org/download/adhanclock-qurancube/Adhan%20Clock%20-%20Quran%20Cube%20-%20Final/';
  static const _idBase = 500;
  static const _idEnd = 540;
  static const _previewId = 590;
  static const _minBytes = 200 * 1024;
  static const prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

  static bool get supported => !kIsWeb && Platform.isAndroid;

  /// Call once before runApp.
  static Future<void> initPlatform() async {
    if (!supported) return;
    try {
      await Alarm.init();
    } catch (e) {
      debugPrint('Alarm init skipped: $e');
    }
  }

  final StorageService _storage = Get.find();

  final RxBool enabled = false.obs;
  final RxList<String> audioPrayers = <String>[].obs;
  final RxDouble volume = 0.8.obs;
  final RxString muazzinId = PrayerOptions.defaultMuazzinId.obs;

  /// Muazzin id → both recordings are on the phone.
  final RxMap<String, bool> ready = <String, bool>{}.obs;

  /// Muazzin id → download progress 0..1 while downloading.
  final RxMap<String, double> progress = <String, double>{}.obs;

  /// Recording being previewed ('<muazzin>:fajr' or '<muazzin>:azan').
  final RxnString previewing = RxnString();

  /// Prayer whose azan is sounding right now.
  final RxnString ringing = RxnString();

  StreamSubscription<AlarmSet>? _ringSub;
  Future<void> _queue = Future.value();

  MuazzinOption get voice => PrayerOptions.muazzinById(muazzinId.value);

  /// Full azan will play: switched on, Android, and the voice is downloaded.
  bool get isActive => supported && enabled.value && (ready[voice.id] ?? false);

  /// Short status for settings rows.
  String get statusLabel => isActive
      ? '${'Full azan'.tr} · ${voice.name}'
      : (supported ? 'Notification only · tap to set up the azan'.tr : 'Notification with sound'.tr);

  @override
  void onInit() {
    super.onInit();
    enabled.value = _storage.getAzanAudio();
    audioPrayers.assignAll(_storage.getAzanAudioPrayers());
    volume.value = _storage.getAzanVolume();
    muazzinId.value = _storage.getMuazzin();
    for (final m in PrayerOptions.muazzins) {
      ready[m.id] = _storage.getAzanReady(m.id);
    }
    if (supported) {
      _ringSub = Alarm.ringing.listen(_onRinging);
      _verifyFiles();
    }
  }

  @override
  void onClose() {
    _ringSub?.cancel();
    super.onClose();
  }

  void _onRinging(AlarmSet set) {
    final azan = set.alarms.where((a) => a.id >= _idBase && a.id < _idEnd);
    ringing.value = azan.isEmpty ? null : (azan.first.payload ?? '');
    if (!set.alarms.any((a) => a.id == _previewId)) previewing.value = null;
  }

  String _localName(String file) {
    final stem = file.replaceAll(RegExp(r'\.mp3$', caseSensitive: false), '');
    return 'azan/${stem.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_').toLowerCase()}.mp3';
  }

  Future<File> _file(String file) async {
    final docs = await getApplicationDocumentsDirectory();
    return File('${docs.path}/${_localName(file)}');
  }

  Future<bool> _hasFile(String file) async {
    final f = await _file(file);
    return await f.exists() && await f.length() > _minBytes;
  }

  Future<void> _verifyFiles() async {
    for (final m in PrayerOptions.muazzins) {
      final ok = await _hasFile(m.azanFile) && await _hasFile(m.fajrFile);
      _setReady(m.id, ok);
    }
  }

  void _setReady(String id, bool ok) {
    ready[id] = ok;
    _storage.saveAzanReady(id, ok);
  }

  /// Downloads both recordings (regular and Fajr). Returns an error message or null.
  Future<String?> download(MuazzinOption m) async {
    if (progress.containsKey(m.id)) return null;
    progress[m.id] = 0;
    try {
      final files = {m.azanFile, m.fajrFile}.toList();
      final dio = Dio();
      for (var i = 0; i < files.length; i++) {
        if (await _hasFile(files[i])) continue;
        final target = await _file(files[i]);
        await target.parent.create(recursive: true);
        final part = File('${target.path}.part');
        await dio.download(
          _source + Uri.encodeComponent(files[i]),
          part.path,
          onReceiveProgress: (got, total) {
            if (total > 0) progress[m.id] = (i + got / total) / files.length;
          },
        );
        if (await part.length() < _minBytes) throw const FileSystemException('Incomplete download');
        await part.rename(target.path);
      }
      _setReady(m.id, true);
      return null;
    } catch (e) {
      debugPrint('Azan download failed: $e');
      return 'Download failed. Check your internet and try again.'.tr;
    } finally {
      progress.remove(m.id);
    }
  }

  /// Removes a voice, keeping recordings another downloaded voice still uses.
  Future<void> delete(MuazzinOption m) async {
    final inUse = {
      for (final other in PrayerOptions.muazzins)
        if (other.id != m.id && (ready[other.id] ?? false)) ...[other.azanFile, other.fajrFile],
    };
    for (final file in {m.azanFile, m.fajrFile}) {
      if (inUse.contains(file)) continue;
      final f = await _file(file);
      if (await f.exists()) await f.delete();
    }
    _setReady(m.id, false);
  }

  Future<void> preview(MuazzinOption m, {bool fajr = false}) async {
    if (!supported) return;
    await stopPreview();
    previewing.value = '${m.id}:${fajr ? 'fajr' : 'azan'}';
    await Alarm.set(
      alarmSettings: _settings(
        id: _previewId,
        at: DateTime.now().add(const Duration(seconds: 1)),
        file: fajr ? m.fajrFile : m.azanFile,
        title: 'Azan preview'.tr,
        body: m.name,
        payload: 'preview',
      ),
    );
  }

  Future<void> stopPreview() async {
    previewing.value = null;
    if (supported) await Alarm.stop(_previewId);
  }

  Future<void> stopRinging() async {
    if (!supported) return;
    for (final a in await Alarm.getAlarms()) {
      if (a.id >= _idBase && a.id < _idEnd && await Alarm.isRinging(a.id)) await Alarm.stop(a.id);
    }
    ringing.value = null;
  }

  /// Exact alarms and no battery limits keep the azan on time on every brand.
  Future<void> requestReliability() async {
    if (!supported) return;
    try {
      if (await Permission.scheduleExactAlarm.isDenied) await Permission.scheduleExactAlarm.request();
      if (!await Permission.ignoreBatteryOptimizations.isGranted) {
        await Permission.ignoreBatteryOptimizations.request();
      }
    } catch (_) {}
  }

  Future<bool> get batteryUnrestricted async {
    if (!supported) return true;
    try {
      return await Permission.ignoreBatteryOptimizations.isGranted;
    } catch (_) {
      return true;
    }
  }

  void setEnabled(bool on) {
    enabled.value = on;
    _storage.saveAzanAudio(on);
  }

  void setMuazzin(String id) {
    muazzinId.value = id;
    _storage.saveMuazzin(id);
  }

  void togglePrayer(String prayer, bool on) {
    if (on) {
      if (!audioPrayers.contains(prayer)) audioPrayers.add(prayer);
    } else {
      audioPrayers.remove(prayer);
    }
    audioPrayers.sort((a, b) => prayers.indexOf(a).compareTo(prayers.indexOf(b)));
    _storage.saveAzanAudioPrayers(audioPrayers.toList());
  }

  void setVolume(double v) {
    volume.value = v;
    _storage.saveAzanVolume(v);
  }

  /// Ids are tied to the date and prayer, so an azan that is ringing is never
  /// replaced when the schedule is refreshed.
  static int _idFor(DateTime at, String prayer) {
    final dayOfYear = at.difference(DateTime(at.year)).inDays;
    return _idBase + (dayOfYear % 7) * 5 + prayers.indexOf(prayer);
  }

  /// Replaces the scheduled azans with [slots] (empty clears them).
  Future<void> schedule(List<AzanSlot> slots) {
    if (!supported) return Future.value();
    return _queue = _queue.then((_) => _apply(slots)).catchError((Object e) {
      debugPrint('Azan schedule skipped: $e');
    });
  }

  Future<void> _apply(List<AzanSlot> slots) async {
    final existing = {for (final a in await Alarm.getAlarms()) a.id: a};
    final now = DateTime.now();
    final wanted = <int>{};
    if (isActive) {
      for (final s in slots) {
        if (!s.at.isAfter(now.add(const Duration(seconds: 5)))) continue;
        final id = _idFor(s.at, s.prayer);
        wanted.add(id);
        final file = s.prayer == 'Fajr' ? voice.fajrFile : voice.azanFile;
        final settings = _settings(id: id, at: s.at, file: file, title: s.title, body: s.body, payload: s.prayer);
        final old = existing[id];
        if (old != null && old == settings) continue;
        if (old != null && await Alarm.isRinging(id)) continue;
        await Alarm.set(alarmSettings: settings);
      }
    }
    for (final id in existing.keys) {
      if (id < _idBase || id >= _idEnd || wanted.contains(id)) continue;
      if (await Alarm.isRinging(id)) continue;
      await Alarm.stop(id);
    }
  }

  AlarmSettings _settings({
    required int id,
    required DateTime at,
    required String file,
    required String title,
    required String body,
    required String payload,
  }) {
    return AlarmSettings(
      id: id,
      dateTime: DateTime(at.year, at.month, at.day, at.hour, at.minute),
      assetAudioPath: _localName(file),
      loopAudio: false,
      vibrate: false,
      warningNotificationOnKill: false,
      androidFullScreenIntent: false,
      androidStopAlarmOnTermination: false,
      allowAlarmOverlap: false,
      androidStaleAfter: const Duration(minutes: 10),
      payload: payload,
      volumeSettings: VolumeSettings.fade(
        fadeDuration: const Duration(seconds: 3),
        volume: volume.value,
      ),
      notificationSettings: NotificationSettings(
        title: title,
        body: body,
        stopButton: 'Stop azan'.tr,
        icon: 'ic_stat_alnoor',
        iconColor: const Color(0xFF1B6B3A),
      ),
    );
  }
}
