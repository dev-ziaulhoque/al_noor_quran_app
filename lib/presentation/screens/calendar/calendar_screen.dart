import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/controllers/prayer_controller.dart';
import '../../../app/controllers/settings_controller.dart';
import '../../../core/calendar/bangla_date.dart';
import '../../../core/calendar/islamic_events.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/i18n/locale_text.dart';
import '../../../core/utils/hijri_date.dart';
import '../../widgets/app_surfaces.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late int _year;
  late int _month;
  late DateTime _selected;

  DateTime get _today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  @override
  void initState() {
    super.initState();
    _goToday();
  }

  void _goToday() {
    final h = HijriDate.fromGregorian(_today);
    _year = h.year;
    _month = h.month;
    _selected = _today;
  }

  void _shift(int delta) {
    setState(() {
      _month += delta;
      if (_month > 12) {
        _month = 1;
        _year++;
      } else if (_month < 1) {
        _month = 12;
        _year--;
      }
      final first = HijriDate(_year, _month, 1).toGregorian();
      final h = HijriDate.fromGregorian(_today);
      _selected = (h.year == _year && h.month == _month) ? _today : DateTime(first.year, first.month, first.day);
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Islamic Calendar'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.card,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () => setState(_goToday),
            icon: const Icon(Icons.today_rounded, size: 18),
            label: Text('Today'.tr),
          ),
        ],
      ),
      body: Obx(() {
        settings.hijriAdjust.value;
        settings.appLanguage.value;
        final bangla = LocaleText.isBangla;
        final days = HijriDate.monthLength(_year, _month);
        final first = HijriDate(_year, _month, 1).toGregorian();
        final last = HijriDate(_year, _month, days).toGregorian();
        final upcoming = IslamicEvents.upcoming(_today);

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: [
            _MonthHeader(
              hijri: HijriDate(_year, _month, 1),
              span: '${LocaleText.gregorianShort(first)} – ${LocaleText.gregorian(last)}',
              onPrev: () => _shift(-1),
              onNext: () => _shift(1),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
              decoration: AppSurfaces.card(radius: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      for (final wd in [7, 1, 2, 3, 4, 5, 6])
                        Expanded(
                          child: Center(
                            child: Text(
                              LocaleText.weekdayShort(wd),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: wd == DateTime.friday ? AppColors.emerald : AppColors.textLight,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  GridView.count(
                    crossAxisCount: 7,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    childAspectRatio: 0.82,
                    children: [
                      for (var i = 0; i < first.weekday % 7; i++) const SizedBox.shrink(),
                      for (var d = 1; d <= days; d++) _dayCell(d, first),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    alignment: WrapAlignment.center,
                    children: [
                      _Legend(color: AppColors.gold, label: 'Event'.tr, dot: true),
                      _Legend(color: AppPalette.goldLight.withValues(alpha: 0.35), label: 'White days'.tr),
                      _Legend(color: Colors.redAccent, label: 'No fasting'.tr, dot: true),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _DayDetails(date: _selected, bangla: bangla),
            const SizedBox(height: 12),
            _AdjustCard(settings: settings),
            const SizedBox(height: 18),
            Text('Upcoming'.tr, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            const SizedBox(height: 8),
            for (final item in upcoming.take(10)) _UpcomingTile(item: item, today: _today, bangla: bangla, onTap: () {
              setState(() {
                _year = item.hijri.year;
                _month = item.hijri.month;
                _selected = item.gregorian;
              });
            }),
          ],
        );
      }),
    );
  }

  Widget _dayCell(int day, DateTime first) {
    final g = DateTime(first.year, first.month, first.day + day - 1);
    final hijri = HijriDate(_year, _month, day);
    final isToday = g == _today;
    final isSelected = g == _selected;
    final events = IslamicEvents.on(hijri);
    final fast = IslamicEvents.fastingOn(g);
    final white = day >= 13 && day <= 15 && _month != 9;
    final friday = g.weekday == DateTime.friday;

    final bg = isToday
        ? AppColors.emerald
        : white
            ? AppPalette.goldLight.withValues(alpha: 0.22)
            : Colors.transparent;
    final fg = isToday ? Colors.white : (friday ? AppColors.emerald : AppColors.textDark);

    return GestureDetector(
      onTap: () => setState(() => _selected = g),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: isSelected && !isToday ? Border.all(color: AppColors.emerald, width: 1.6) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(LocaleText.digits(day), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: fg)),
            Text(
              LocaleText.digits(g.day),
              style: TextStyle(fontSize: 9.5, color: isToday ? const Color(0xCCFFFFFF) : AppColors.textLight),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (events.isNotEmpty) _dot(isToday ? AppPalette.goldLight : AppColors.gold),
                if (fast.status == FastStatus.forbidden) _dot(Colors.redAccent),
                if (events.isEmpty && fast.status != FastStatus.forbidden) const SizedBox(height: 5),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot(Color c) => Container(
        width: 5,
        height: 5,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(color: c, shape: BoxShape.circle),
      );
}

class _MonthHeader extends StatelessWidget {
  final HijriDate hijri;
  final String span;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _MonthHeader({required this.hijri, required this.span, required this.onPrev, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      decoration: AppSurfaces.hero(),
      child: Row(
        children: [
          IconButton(onPressed: onPrev, icon: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 28)),
          Expanded(
            child: Column(
              children: [
                Text(hijri.monthNameAr, style: const TextStyle(fontFamily: 'Amiri', fontSize: 24, height: 1.3, color: AppPalette.goldLight)),
                Text(LocaleText.hijriMonth(hijri) + (LocaleText.isBangla ? ' হিজরি' : ' AH'),
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 2),
                Text(span, style: const TextStyle(fontSize: 11.5, color: Color(0xCCFFFFFF))),
              ],
            ),
          ),
          IconButton(onPressed: onNext, icon: const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 28)),
        ],
      ),
    );
  }
}

class _DayDetails extends StatelessWidget {
  final DateTime date;
  final bool bangla;

  const _DayDetails({required this.date, required this.bangla});

  @override
  Widget build(BuildContext context) {
    final hijri = HijriDate.fromGregorian(date);
    final bd = BanglaDate.fromGregorian(date);
    final events = IslamicEvents.on(hijri);
    final fast = IslamicEvents.fastingOn(date);
    final p = Get.find<PrayerController>();
    Map<String, DateTime> waqt = const {};
    try {
      waqt = p.waqtFor(date);
    } catch (_) {}

    final (fastColor, fastIcon) = switch (fast.status) {
      FastStatus.obligatory => (AppColors.emerald, Icons.nightlight_round),
      FastStatus.sunnah => (AppPalette.gold, Icons.star_rounded),
      FastStatus.forbidden => (Colors.redAccent, Icons.block_rounded),
      FastStatus.none => (AppColors.textLight, Icons.info_outline_rounded),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppSurfaces.card(radius: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(LocaleText.weekday(date.weekday), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textLight)),
                    Text(LocaleText.hijri(hijri), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                  ],
                ),
              ),
              Text(
                '${hijri.day} ${hijri.monthNameAr}',
                textDirection: TextDirection.rtl,
                style: TextStyle(fontFamily: 'Amiri', fontSize: 18, color: AppColors.emerald),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _InfoRow(icon: Icons.calendar_today_rounded, label: 'Gregorian'.tr, value: LocaleText.gregorian(date)),
          _InfoRow(
            icon: Icons.local_florist_rounded,
            label: 'Bangla'.tr,
            value: '${LocaleText.digits(bd.day)} ${bd.monthName(bangla)} ${LocaleText.digits(bd.year)} · ${bd.season(bangla)}',
          ),
          if (waqt.isNotEmpty) ...[
            _InfoRow(
              icon: Icons.nights_stay_rounded,
              label: hijri.isRamadan ? 'Sehri ends'.tr : 'Fajr'.tr,
              value: LocaleText.time(waqt['Fajr']!),
            ),
            _InfoRow(icon: Icons.wb_twilight_rounded, label: 'Sunrise'.tr, value: LocaleText.time(waqt['Sunrise']!)),
            _InfoRow(
              icon: Icons.restaurant_rounded,
              label: hijri.isRamadan ? 'Iftar'.tr : 'Sunset'.tr,
              value: LocaleText.time(waqt['Maghrib']!),
            ),
          ],
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(color: fastColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Icon(fastIcon, size: 16, color: fastColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    fast.status == FastStatus.sunnah ? '${'Sunnah fast'.tr}: ${fast.label(bangla)}' : fast.label(bangla),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fastColor),
                  ),
                ),
              ],
            ),
          ),
          for (final e in events) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(e.kind == EventKind.night ? Icons.bedtime_rounded : Icons.star_rounded, size: 16, color: AppColors.gold),
                const SizedBox(width: 6),
                Expanded(child: Text(e.title(bangla), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark))),
              ],
            ),
            const SizedBox(height: 3),
            Text(e.detail(bangla), style: TextStyle(fontSize: 12.5, height: 1.45, color: AppColors.textMid)),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 15, color: AppColors.emerald),
          const SizedBox(width: 8),
          SizedBox(width: 92, child: Text(label, style: TextStyle(fontSize: 12, color: AppColors.textLight))),
          Expanded(child: Text(value, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textDark))),
        ],
      ),
    );
  }
}

class _AdjustCard extends StatelessWidget {
  final SettingsController settings;
  const _AdjustCard({required this.settings});

  @override
  Widget build(BuildContext context) {
    final adjust = settings.hijriAdjust.value;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
      decoration: BoxDecoration(
        color: AppColors.emeraldPale,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.brightness_3_rounded, color: AppColors.emerald, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Moon sighting adjustment'.tr, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                const SizedBox(height: 2),
                Text(
                  'Dates are calculated offline. Bangladesh is often one day behind; match your local announcement.'.tr,
                  style: TextStyle(fontSize: 11, height: 1.35, color: AppColors.textMid),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: adjust <= -2 ? null : () => settings.setHijriAdjust(adjust - 1),
            icon: const Icon(Icons.remove_circle_outline_rounded),
            color: AppColors.emerald,
          ),
          Text(
            LocaleText.digits(adjust > 0 ? '+$adjust' : '$adjust'),
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark),
          ),
          IconButton(
            onPressed: adjust >= 2 ? null : () => settings.setHijriAdjust(adjust + 1),
            icon: const Icon(Icons.add_circle_outline_rounded),
            color: AppColors.emerald,
          ),
        ],
      ),
    );
  }
}

class _UpcomingTile extends StatelessWidget {
  final UpcomingIslamicDate item;
  final DateTime today;
  final bool bangla;
  final VoidCallback onTap;

  const _UpcomingTile({required this.item, required this.today, required this.bangla, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final daysLeft = item.daysFrom(today);
    final when = daysLeft == 0
        ? 'Today'.tr
        : daysLeft == 1
            ? 'Tomorrow'.tr
            : 'In @n days'.trParams({'n': LocaleText.digits(daysLeft)});
    final major = item.event.kind == EventKind.major;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: AppSurfaces.card(radius: 16),
        child: Row(
          children: [
            Container(
              width: 50,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: major ? AppColors.emerald : AppColors.emeraldPale,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(LocaleText.digits(item.gregorian.day),
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: major ? Colors.white : AppColors.emerald)),
                  Text(
                    LocaleText.gregorianShort(item.gregorian).split(' ').last,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: major ? const Color(0xCCFFFFFF) : AppColors.emerald),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.event.title(bangla), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                  const SizedBox(height: 2),
                  Text(LocaleText.hijri(item.hijri), style: TextStyle(fontSize: 11, color: AppColors.textLight)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: AppPalette.gold.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(10)),
              child: Text(when, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppPalette.gold)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  final bool dot;

  const _Legend({required this.color, required this.label, this.dot = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: dot ? 7 : 12,
          height: dot ? 7 : 12,
          decoration: BoxDecoration(color: color, shape: dot ? BoxShape.circle : BoxShape.rectangle, borderRadius: dot ? null : BorderRadius.circular(3)),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 10.5, color: AppColors.textMid)),
      ],
    );
  }
}
