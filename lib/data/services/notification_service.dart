import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Each kind has its own Android channel, so people can tune azan, Ramadan
/// and gentle reminders separately in system settings.
enum AlertKind { azan, ramadan, dailyAyah, jumuah, islamicDate }

class ScheduledAlert {
  final int id;
  final AlertKind kind;
  final String title;
  final String body;
  final DateTime when;

  /// Longer text shown when the notification is expanded.
  final String? bigText;

  /// Small line next to the app name (place, reference…).
  final String? subText;

  /// Where a tap opens the app; see [NotificationPayload].
  final String? payload;

  const ScheduledAlert({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.when,
    this.bigText,
    this.subText,
    this.payload,
  });
}

/// Tap targets carried in a notification payload.
class NotificationPayload {
  static const azan = 'azan';
  static const qibla = 'qibla';
  static const ramadan = 'ramadan';
  static const calendar = 'calendar';
  static String ayah(int surah, int ayah) => 'ayah:$surah:$ayah';
}

class _Channel {
  final String id;
  final String name;
  final String description;
  final Importance importance;
  final Int64List? vibration;
  const _Channel(this.id, this.name, this.description, this.importance, [this.vibration]);
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  static const _brand = Color(0xFF1B6B3A);
  static const _icon = 'ic_stat_alnoor';
  static const _legacyChannels = ['azan_channel'];
  static const _actionQibla = 'open_qibla';
  static const _actionRead = 'open_read';

  static final Map<AlertKind, _Channel> _channels = {
    AlertKind.azan: _Channel('alnoor_azan', 'Azan', 'At each azan time, on screen', Importance.max,
        Int64List.fromList([0, 500, 250, 500, 250, 800])),
    AlertKind.ramadan: _Channel('alnoor_ramadan', 'Sehri & Iftar', 'Sehri ending and iftar reminders in Ramadan', Importance.max,
        Int64List.fromList([0, 400, 200, 400])),
    AlertKind.dailyAyah: _Channel('alnoor_ayah', 'Ayah of the day', 'One ayah with meaning every morning', Importance.high),
    AlertKind.jumuah: _Channel('alnoor_jumuah', "Jumu'ah", 'Friday reminder for Surah Al-Kahf and salawat', Importance.high),
    AlertKind.islamicDate: _Channel('alnoor_dates', 'Islamic dates', 'Upcoming Islamic days and fasts', Importance.high),
  };

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;
  bool _askedPermission = false;

  /// Set by the app once navigation is ready; receives tap payloads.
  void Function(String payload)? onOpen;
  String? _pendingPayload;

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  Future<void> init() async {
    if (_ready || kIsWeb) return;
    try {
      tzdata.initializeTimeZones();
      tz.setLocalLocation(tz.UTC);
      const settings = InitializationSettings(
        android: AndroidInitializationSettings(_icon),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      );
      await _plugin.initialize(settings, onDidReceiveNotificationResponse: _onResponse);
      await _createChannels();
      final launch = await _plugin.getNotificationAppLaunchDetails();
      if (launch?.didNotificationLaunchApp == true && launch!.notificationResponse != null) {
        _pendingPayload = _target(launch.notificationResponse!);
      }
      _ready = true;
    } catch (e) {
      debugPrint('Notification init skipped: $e');
    }
  }

  Future<void> _createChannels() async {
    final android = _android;
    if (android == null) return;
    for (final id in _legacyChannels) {
      await android.deleteNotificationChannel(id);
    }
    for (final c in _channels.values) {
      await android.createNotificationChannel(AndroidNotificationChannel(
        c.id,
        c.name,
        description: c.description,
        importance: c.importance,
        playSound: true,
        enableVibration: true,
        vibrationPattern: c.vibration,
        enableLights: true,
        ledColor: _brand,
        showBadge: true,
      ));
    }
  }

  String? _target(NotificationResponse r) {
    if (r.actionId == _actionQibla) return NotificationPayload.qibla;
    return r.payload;
  }

  void _onResponse(NotificationResponse r) {
    final target = _target(r);
    if (target == null || target.isEmpty) return;
    final open = onOpen;
    if (open == null) {
      _pendingPayload = target;
    } else {
      open(target);
    }
  }

  /// Payload of the notification that launched the app, used once.
  String? takePendingPayload() {
    final p = _pendingPayload;
    _pendingPayload = null;
    return p;
  }

  Future<void> replaceAlerts(List<ScheduledAlert> alerts, {required bool enabled}) async {
    await init();
    if (!_ready) return;
    try {
      await _plugin.cancelAll();
      if (!enabled || !await isGranted()) return;
      final exact = await _canScheduleExact();
      final now = DateTime.now();
      for (final alert in alerts) {
        if (!alert.when.isAfter(now)) continue;
        await _schedule(alert, exact: exact);
      }
    } catch (e) {
      debugPrint('Notification schedule skipped: $e');
    }
  }

  /// Never asks; alerts are only scheduled once the user has said yes.
  Future<bool> isGranted() async {
    if (kIsWeb) return false;
    try {
      return await Permission.notification.isGranted;
    } catch (_) {
      return false;
    }
  }

  /// Asks only when the user turns something on (alerts, recitation).
  /// Android 13+ also hides the recitation controls without it.
  Future<bool> ensurePermission() async {
    if (kIsWeb) return false;
    if (await isGranted()) return true;
    if (_askedPermission) return false;
    _askedPermission = true;
    try {
      final granted = (await Permission.notification.request()).isGranted;
      if (granted && !await _canScheduleExact()) await _android?.requestExactAlarmsPermission();
      return granted;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _canScheduleExact() async {
    try {
      return await _android?.canScheduleExactNotifications() ?? true;
    } catch (_) {
      return true;
    }
  }

  /// Shows a sample azan alert right away so people can check it pops up.
  Future<bool> showTest({required String title, required String body}) async {
    await init();
    if (!_ready || !await ensurePermission()) return false;
    await _plugin.show(
      999,
      title,
      body,
      _details(ScheduledAlert(
        id: 999,
        kind: AlertKind.azan,
        title: title,
        body: body,
        when: DateTime.now(),
        payload: NotificationPayload.azan,
      )),
      payload: NotificationPayload.azan,
    );
    return true;
  }

  NotificationDetails _details(ScheduledAlert a) {
    final c = _channels[a.kind]!;
    final urgent = a.kind == AlertKind.azan || a.kind == AlertKind.ramadan;
    final actions = <AndroidNotificationAction>[
      if (a.kind == AlertKind.azan)
        AndroidNotificationAction(_actionQibla, 'Qibla direction'.tr, showsUserInterface: true, cancelNotification: true),
      if (a.kind == AlertKind.dailyAyah || a.kind == AlertKind.jumuah)
        AndroidNotificationAction(_actionRead, 'Read now'.tr, showsUserInterface: true, cancelNotification: true),
    ];
    return NotificationDetails(
      android: AndroidNotificationDetails(
        c.id,
        c.name,
        channelDescription: c.description,
        importance: c.importance,
        priority: urgent ? Priority.max : Priority.high,
        category: urgent ? AndroidNotificationCategory.alarm : AndroidNotificationCategory.reminder,
        visibility: NotificationVisibility.public,
        icon: _icon,
        color: _brand,
        enableLights: true,
        ledColor: _brand,
        ledOnMs: 800,
        ledOffMs: 1600,
        vibrationPattern: c.vibration,
        ticker: a.title,
        subText: a.subText,
        when: a.when.millisecondsSinceEpoch,
        showWhen: true,
        autoCancel: true,
        groupKey: 'alnoor.${a.kind.name}',
        timeoutAfter: a.kind == AlertKind.azan ? const Duration(minutes: 50).inMilliseconds : null,
        styleInformation: BigTextStyleInformation(
          a.bigText ?? a.body,
          contentTitle: a.title,
          summaryText: a.subText,
        ),
        actions: actions,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBanner: true,
        presentList: true,
        presentSound: true,
        subtitle: a.subText,
        threadIdentifier: 'alnoor.${a.kind.name}',
        interruptionLevel: urgent ? InterruptionLevel.timeSensitive : InterruptionLevel.active,
      ),
    );
  }

  Future<void> _schedule(ScheduledAlert alert, {required bool exact}) async {
    final details = _details(alert);
    final when = _asUtc(alert.when);
    // Azan and Ramadan use alarm-clock alarms: they fire on the minute even in
    // Doze and on phones that delay ordinary exact alarms.
    final urgent = alert.kind == AlertKind.azan || alert.kind == AlertKind.ramadan;
    final mode = !exact
        ? AndroidScheduleMode.inexactAllowWhileIdle
        : (urgent ? AndroidScheduleMode.alarmClock : AndroidScheduleMode.exactAllowWhileIdle);
    try {
      await _plugin.zonedSchedule(
        alert.id,
        alert.title,
        alert.body,
        when,
        details,
        payload: alert.payload,
        androidScheduleMode: mode,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (_) {
      await _plugin.zonedSchedule(
        alert.id,
        alert.title,
        alert.body,
        when,
        details,
        payload: alert.payload,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  tz.TZDateTime _asUtc(DateTime local) {
    final utc = local.toUtc();
    return tz.TZDateTime.utc(utc.year, utc.month, utc.day, utc.hour, utc.minute, utc.second);
  }
}
