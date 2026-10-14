import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/controllers/prayer_controller.dart';
import '../../../app/controllers/quran_controller.dart';
import '../../../app/controllers/settings_controller.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/i18n/locale_text.dart';
import '../../../core/utils/hijri_date.dart';
import '../../../data/content/duas.dart';
import '../../../data/services/storage_service.dart';
import '../../widgets/app_surfaces.dart';
import '../../widgets/ayah_share_card.dart';
import '../../widgets/content_card.dart';

class RamadanScreen extends StatefulWidget {
  const RamadanScreen({super.key});

  @override
  State<RamadanScreen> createState() => _RamadanScreenState();
}

class _RamadanScreenState extends State<RamadanScreen> {
  static const _checklist = [
    ('sehri', 'Sehri taken', Icons.free_breakfast_rounded),
    ('fajr', 'Fajr prayed', Icons.wb_twilight_rounded),
    ('quran', 'Quran portion read', Icons.menu_book_rounded),
    ('dhikr', 'Morning and evening adhkar', Icons.auto_awesome_rounded),
    ('iftar', 'Iftar with dua', Icons.restaurant_rounded),
    ('taraweeh', 'Taraweeh prayed', Icons.nightlight_round),
    ('charity', 'Some charity given', Icons.volunteer_activism_rounded),
  ];

  final _storage = Get.find<StorageService>();
  final _prayer = Get.find<PrayerController>();
  Timer? _timer;
  DateTime _now = DateTime.now();
  late Set<String> _done;
  late int _year;
  late Map<int, String> _fasts;

  DateTime get _today => DateTime(_now.year, _now.month, _now.day);

  String get _checkKey {
    final h = HijriDate.fromGregorian(_now);
    return '${h.year}-${h.month}-${h.day}';
  }

  @override
  void initState() {
    super.initState();
    final h = HijriDate.fromGregorian(_now);
    _year = h.month <= 9 ? h.year : h.year + 1;
    _done = _storage.getRamadanChecks(_checkKey);
    _fasts = _storage.getRamadanFasts(_year);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleCheck(String id) {
    setState(() => _done.contains(id) ? _done.remove(id) : _done.add(id));
    _storage.saveRamadanChecks(_checkKey, _done);
  }

  void _cycleFast(int day) {
    const order = ['', 'kept', 'missed', 'excused'];
    final current = _fasts[day] ?? '';
    final next = order[(order.indexOf(current) + 1) % order.length];
    setState(() => next.isEmpty ? _fasts.remove(day) : _fasts[day] = next);
    _storage.saveRamadanFasts(_year, _fasts);
  }

  Map<String, DateTime> _waqt(DateTime day) {
    try {
      return _prayer.waqtFor(day);
    } catch (_) {
      return const {};
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    final hijri = HijriDate.fromGregorian(_now);
    final inRamadan = hijri.isRamadan;
    final start = HijriDate(_year, 9, 1).toGregorian();
    final length = HijriDate.monthLength(_year, 9);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Ramadan'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.card,
        elevation: 0,
      ),
      body: Obx(() {
        settings.appLanguage.value;
        settings.hijriAdjust.value;
        _prayer.prayerTimes.value;
        final bangla = settings.prefersBanglaMeaning;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: [
            inRamadan ? _liveHero(hijri.day, length) : _beforeHero(start),
            const SizedBox(height: 14),
            if (inRamadan) ...[
              _khatamCard(hijri.day),
              const SizedBox(height: 14),
            ],
            _sectionTitle('Fast tracker'.tr, '${'Ramadan'.tr} ${LocaleText.digits(_year)} · ${'Tap a day to mark it'.tr}'),
            _fastTracker(start, length),
            const SizedBox(height: 18),
            if (inRamadan) ...[
              _sectionTitle("Today's checklist".tr, 'Stored only on this phone.'.tr),
              _checklistCard(),
              const SizedBox(height: 18),
            ],
            _sectionTitle('Sehri & Iftar timetable'.tr, '${_prayer.placeLabel} · ${_prayer.methodName.value}'),
            _timetable(start, length),
            const SizedBox(height: 6),
            Text(
              'Sehri ends at Fajr and iftar is at Maghrib, from your prayer settings. Many stop eating a few minutes before Fajr for caution.'.tr,
              style: TextStyle(fontSize: 11, height: 1.4, color: AppColors.textLight),
            ),
            const SizedBox(height: 18),
            _sectionTitle('Ramadan duas'.tr, null),
            for (final d in Duas.inCategory('ramadan'))
              ContentCard(
                title: d.title(bangla),
                badge: 'Ramadan'.tr,
                arabic: d.arabic,
                meaning: d.meaning(bangla),
                note: d.note(bangla),
                source: d.source,
                onShare: () => showAyahShareSheet(
                  context,
                  AyahCardContent.text(
                    arabic: d.arabic,
                    meaning: d.meaning(bangla),
                    heading: '${'Dua'.tr} · ${d.title(bangla)}',
                    reference: d.source,
                    fileId: 'dua_${d.id}',
                  ),
                ),
              ),
            const SizedBox(height: 6),
            _InfoPanel(
              icon: Icons.nightlight_round,
              title: 'Taraweeh'.tr,
              body: 'Taraweeh is the night prayer of Ramadan after Isha, alone or in congregation. Sahih al-Bukhari records that the Prophet ﷺ led it in the mosque for some nights, then prayed at home so it would not become obligatory. Some pray 8 rak\'ahs and some pray 20, followed by witr; both are practised. Follow your imam in congregation.'.tr,
            ),
            const SizedBox(height: 10),
            _InfoPanel(
              icon: Icons.volunteer_activism_rounded,
              title: 'Zakat al-Fitr (Fitra)'.tr,
              body: 'Due on every Muslim who has food beyond the day\'s need, for each family member, before the Eid prayer. Islamic Foundation Bangladesh announces the yearly rate.'.tr,
              action: 'Calculate fitra'.tr,
              onAction: () => Get.toNamed(AppRoutes.zakat, arguments: {'tab': 'fitra'}),
            ),
          ],
        );
      }),
    );
  }

  Widget _liveHero(int day, int length) {
    final today = _waqt(_today);
    final tomorrow = _waqt(_today.add(const Duration(days: 1)));
    if (today.isEmpty) return const SizedBox(height: 160, child: Center(child: CircularProgressIndicator()));
    final fajr = today['Fajr']!;
    final maghrib = today['Maghrib']!;
    late String label;
    late DateTime target;
    if (_now.isBefore(fajr)) {
      label = 'Sehri ends in';
      target = fajr;
    } else if (_now.isBefore(maghrib)) {
      label = 'Iftar in';
      target = maghrib;
    } else {
      label = 'Sehri ends in';
      target = tomorrow['Fajr'] ?? fajr.add(const Duration(days: 1));
    }
    final tonight = day + 1;
    final oddNight = tonight >= 21 && tonight.isOdd && tonight <= length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppSurfaces.hero(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('رَمَضَانُ كَرِيم', style: TextStyle(fontFamily: 'Amiri', fontSize: 22, color: AppPalette.goldLight)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0x26FFFFFF), borderRadius: BorderRadius.circular(20)),
                child: Text(
                  'Day @d of @n'.trParams({'d': LocaleText.digits(day), 'n': LocaleText.digits(length)}),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: day / length,
              minHeight: 6,
              backgroundColor: const Color(0x26FFFFFF),
              valueColor: const AlwaysStoppedAnimation(AppPalette.goldLight),
            ),
          ),
          const SizedBox(height: 14),
          Text(label.tr, style: const TextStyle(fontSize: 12, color: Color(0xCCFFFFFF))),
          Text(
            LocaleText.clock(target.difference(_now)),
            style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: Colors.white, fontFeatures: [FontFeature.tabularFigures()]),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _HeroTime(label: 'Sehri ends'.tr, time: LocaleText.time(fajr), icon: Icons.nights_stay_rounded)),
              Container(width: 1, height: 34, color: const Color(0x33FFFFFF)),
              Expanded(child: _HeroTime(label: 'Iftar'.tr, time: LocaleText.time(maghrib), icon: Icons.restaurant_rounded)),
            ],
          ),
          if (day >= 20) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0x33E8C96A), borderRadius: BorderRadius.circular(12)),
              child: Text(
                oddNight
                    ? 'Tonight is the @n night. Seek Laylat al-Qadr in the odd nights.'.trParams({'n': LocaleText.digits(tonight)})
                    : 'The last ten nights. Increase prayer, Quran and dua.'.tr,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _beforeHero(DateTime start) {
    final days = DateTime(start.year, start.month, start.day).difference(_today).inDays;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppSurfaces.hero(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('اللَّهُمَّ بَلِّغْنَا رَمَضَان', style: TextStyle(fontFamily: 'Amiri', fontSize: 22, color: AppPalette.goldLight)),
          Text('O Allah, let us reach Ramadan'.tr, style: const TextStyle(fontSize: 12, color: Color(0xCCFFFFFF))),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(LocaleText.digits(days),
                  style: const TextStyle(fontSize: 46, height: 1, fontWeight: FontWeight.w900, color: Colors.white)),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('days to Ramadan'.tr, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${'Expected first fast'.tr}: ${LocaleText.gregorian(start, withWeekday: true)}',
            style: const TextStyle(fontSize: 12, color: Color(0xCCFFFFFF)),
          ),
          const SizedBox(height: 10),
          Text(
            'The start depends on the moon sighting. Use the calendar adjustment to match your country.'.tr,
            style: const TextStyle(fontSize: 11, height: 1.4, color: Color(0xB3FFFFFF)),
          ),
        ],
      ),
    );
  }

  Widget _khatamCard(int day) {
    final q = Get.find<QuranController>();
    final juz = day.clamp(1, 30);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppSurfaces.card(radius: 18),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.emeraldPale, borderRadius: BorderRadius.circular(16)),
            child: Text(LocaleText.digits(juz), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.emerald)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Khatam plan: one juz a day'.tr, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                const SizedBox(height: 2),
                Obx(() => Text(
                      '${'Today: Juz @n'.trParams({'n': LocaleText.digits(juz)})} · ${'@n ayahs read today'.trParams({'n': LocaleText.digits(q.todayRead.value)})}',
                      style: TextStyle(fontSize: 12, color: AppColors.textMid),
                    )),
              ],
            ),
          ),
          IconButton.filled(
            onPressed: () => Get.toNamed(AppRoutes.quranList),
            style: IconButton.styleFrom(backgroundColor: AppColors.emerald),
            icon: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _fastTracker(DateTime start, int length) {
    final kept = _fasts.values.where((v) => v == 'kept').length;
    final missed = _fasts.values.where((v) => v == 'missed').length;
    final excused = _fasts.values.where((v) => v == 'excused').length;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppSurfaces.card(radius: 18),
      child: Column(
        children: [
          GridView.count(
            crossAxisCount: 6,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            children: [
              for (var d = 1; d <= length; d++) _fastCell(d, DateTime(start.year, start.month, start.day + d - 1)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _Stat(color: AppColors.emerald, label: 'Kept'.tr, value: kept),
              _Stat(color: Colors.redAccent, label: 'To make up'.tr, value: missed + excused),
              _Stat(color: AppPalette.gold, label: 'Excused'.tr, value: excused),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Tap once: kept · twice: missed · three times: excused (travel, illness, menstruation).'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10.5, color: AppColors.textLight),
          ),
        ],
      ),
    );
  }

  Widget _fastCell(int day, DateTime date) {
    final status = _fasts[day] ?? '';
    final future = date.isAfter(_today);
    final isToday = date == _today;
    final (Color bg, Color fg, IconData? icon) = switch (status) {
      'kept' => (AppColors.emerald, Colors.white, Icons.check_rounded),
      'missed' => (Colors.redAccent.withValues(alpha: 0.15), Colors.redAccent, Icons.close_rounded),
      'excused' => (AppPalette.gold.withValues(alpha: 0.18), AppPalette.gold, Icons.remove_rounded),
      _ => (AppColors.emeraldPale, future ? AppColors.textLight : AppColors.textDark, null),
    };
    return GestureDetector(
      onTap: future ? null : () => _cycleFast(day),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: isToday ? Border.all(color: AppPalette.gold, width: 1.6) : null,
        ),
        child: Center(
          child: icon == null
              ? Text(LocaleText.digits(day), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: fg))
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 15, color: fg),
                    Text(LocaleText.digits(day), style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: fg)),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _checklistCard() {
    return Container(
      decoration: AppSurfaces.card(radius: 18),
      child: Column(
        children: [
          for (final item in _checklist)
            CheckboxListTile(
              value: _done.contains(item.$1),
              onChanged: (_) => _toggleCheck(item.$1),
              activeColor: AppColors.emerald,
              dense: true,
              secondary: Icon(item.$3, size: 20, color: AppColors.emerald),
              title: Text(item.$2.tr, style: TextStyle(fontSize: 13.5, color: AppColors.textDark)),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: _done.length / _checklist.length,
                minHeight: 6,
                backgroundColor: AppColors.emeraldPale,
                valueColor: AlwaysStoppedAnimation(AppColors.emerald),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _timetable(DateTime start, int length) {
    final header = TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textLight);
    return Container(
      decoration: AppSurfaces.card(radius: 18),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            color: AppColors.emeraldPale,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: Row(
              children: [
                SizedBox(width: 34, child: Text('Day'.tr, style: header)),
                Expanded(child: Text('Date'.tr, style: header)),
                SizedBox(width: 78, child: Text('Sehri ends'.tr, style: header, textAlign: TextAlign.end)),
                SizedBox(width: 78, child: Text('Iftar'.tr, style: header, textAlign: TextAlign.end)),
              ],
            ),
          ),
          for (var d = 1; d <= length; d++) _timetableRow(d, DateTime(start.year, start.month, start.day + d - 1)),
        ],
      ),
    );
  }

  Widget _timetableRow(int day, DateTime date) {
    final w = _waqt(date);
    final isToday = date == _today;
    final lastTen = day >= 21;
    final style = TextStyle(
      fontSize: 12.5,
      fontWeight: isToday ? FontWeight.w900 : FontWeight.w600,
      color: isToday ? Colors.white : AppColors.textDark,
    );
    return Container(
      color: isToday ? AppColors.emerald : (lastTen ? AppPalette.goldLight.withValues(alpha: 0.08) : null),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          SizedBox(width: 34, child: Text(LocaleText.digits(day), style: style)),
          Expanded(
            child: Text(
              '${LocaleText.weekdayShort(date.weekday)}, ${LocaleText.gregorianShort(date)}',
              style: style.copyWith(fontWeight: FontWeight.w500, color: isToday ? const Color(0xE6FFFFFF) : AppColors.textMid),
            ),
          ),
          SizedBox(width: 78, child: Text(w.isEmpty ? '--' : LocaleText.time(w['Fajr']!), style: style, textAlign: TextAlign.end)),
          SizedBox(width: 78, child: Text(w.isEmpty ? '--' : LocaleText.time(w['Maghrib']!), style: style, textAlign: TextAlign.end)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, String? subtitle) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            if (subtitle != null) Text(subtitle, style: TextStyle(fontSize: 11, color: AppColors.textLight)),
          ],
        ),
      );
}

class _HeroTime extends StatelessWidget {
  final String label;
  final String time;
  final IconData icon;

  const _HeroTime({required this.label, required this.time, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: AppPalette.goldLight),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 11, color: Color(0xCCFFFFFF))),
          ],
        ),
        const SizedBox(height: 2),
        Text(time, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final Color color;
  final String label;
  final int value;

  const _Stat({required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(LocaleText.digits(value), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
          Text(label, style: TextStyle(fontSize: 10.5, color: AppColors.textMid)),
        ],
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final String? action;
  final VoidCallback? onAction;

  const _InfoPanel({required this.icon, required this.title, required this.body, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppSurfaces.card(radius: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.emerald),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            ],
          ),
          const SizedBox(height: 6),
          Text(body, style: TextStyle(fontSize: 12.5, height: 1.5, color: AppColors.textMid)),
          if (action != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: onAction, child: Text(action!)),
            ),
        ],
      ),
    );
  }
}
