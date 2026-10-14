import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/controllers/prayer_controller.dart';
import '../../app/routes/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/i18n/locale_text.dart';
import '../../core/utils/hijri_date.dart';

/// Home hero: next azan with a live countdown, the current waqt, makruh
/// times, all five azan times, and sunrise/sunset (sehri/iftar in Ramadan).
class NextAzanBanner extends StatefulWidget {
  const NextAzanBanner({super.key});

  @override
  State<NextAzanBanner> createState() => _NextAzanBannerState();
}

class _NextAzanBannerState extends State<NextAzanBanner> {
  static const prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
  static const arabic = {
    'Fajr': 'الفجر',
    'Sunrise': 'الشروق',
    'Dhuhr': 'الظهر',
    'Asr': 'العصر',
    'Maghrib': 'المغرب',
    'Isha': 'العشاء',
  };

  final PrayerController _p = Get.find();
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final next = _p.nextAzanAt.value;
      setState(() => _now = DateTime.now());
      if (next != null && !_now.isBefore(next)) _p.reload();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final waqt = _p.todayWaqt;
      final next = _p.nextAzanAt.value;
      _p.azanOffsets.length;
      final location = _p.placeLabel;
      if (waqt.isEmpty || next == null) {
        return Container(
          height: 180,
          decoration: _decoration(),
          child: const Center(child: CircularProgressIndicator(color: Colors.white)),
        );
      }

      final nextName = _p.nextPrayerName.value;
      final azans = {for (final name in prayers) name: _p.azanAt(name, waqt[name]!)};
      final previous = _previousAzan(azans, next);
      final total = next.difference(previous).inSeconds;
      final left = next.difference(_now);
      final progress = total <= 0 ? 0.0 : (1 - left.inSeconds / total).clamp(0.0, 1.0);
      final status = _status(waqt);
      final hijri = HijriDate.fromGregorian(_now);

      return GestureDetector(
        onTap: () => Get.toNamed(AppRoutes.azan),
        child: Container(
          decoration: _decoration(),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned(right: -40, top: -40, child: CustomPaint(size: const Size(190, 190), painter: _PatternPainter())),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 10, 10, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(Icons.location_on_rounded, size: 14, color: Color(0xCCFFFFFF)),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.today_rounded, size: 13, color: Color(0xCCFFFFFF)),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  LocaleText.gregorian(_now, withWeekday: true, withYear: false),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 11, color: Color(0xCCFFFFFF)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        _RoundAction(icon: Icons.explore_rounded, tooltip: 'Qibla'.tr, onTap: () => Get.toNamed(AppRoutes.qibla)),
                        const SizedBox(width: 6),
                        _RoundAction(icon: Icons.tune_rounded, tooltip: 'Azan settings'.tr, onTap: () => Get.toNamed(AppRoutes.azan)),
                      ],
                    ),
                  ),
                  Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('NEXT AZAN'.tr,
                                  style: const TextStyle(fontSize: 10, letterSpacing: 1.6, fontWeight: FontWeight.w800, color: AppPalette.goldLight)),
                              const SizedBox(height: 2),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Flexible(
                                    child: Text(
                                      nextName.tr,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(arabic[nextName] ?? '',
                                      style: const TextStyle(fontFamily: 'Amiri', fontSize: 18, color: AppPalette.goldLight)),
                                ],
                              ),
                              Text(
                                LocaleText.time(next),
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${'Waqt starts'.tr} ${LocaleText.time(_waqtFor(nextName, waqt, next))}',
                                style: const TextStyle(fontSize: 11, color: Color(0xB3FFFFFF)),
                              ),
                            ],
                          ),
                        ),
                        _CountdownRing(progress: progress, label: LocaleText.clock(left)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color: status.warning ? const Color(0x33FFB74D) : const Color(0x1FFFFFFF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(status.warning ? Icons.warning_amber_rounded : Icons.schedule_rounded,
                              size: 15, color: status.warning ? const Color(0xFFFFCC80) : Colors.white),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(status.text,
                                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: status.warning ? const Color(0xFFFFE0B2) : Colors.white)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _Schedule(
                      prayers: [
                        for (final name in prayers)
                          (
                            name: name,
                            at: azans[name]!,
                            isNext: name == nextName && next.day == _now.day,
                            passed: azans[name]!.isBefore(_now),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 14,
                            runSpacing: 4,
                            children: hijri.isRamadan
                                ? [
                                    _Fact(icon: Icons.nights_stay_rounded, label: 'Sehri ends'.tr, value: LocaleText.time(waqt['Fajr']!)),
                                    _Fact(icon: Icons.restaurant_rounded, label: 'Iftar'.tr, value: LocaleText.time(waqt['Maghrib']!)),
                                  ]
                                : [
                                    _Fact(icon: Icons.wb_twilight_rounded, label: 'Sunrise'.tr, value: LocaleText.time(waqt['Sunrise']!)),
                                    _Fact(icon: Icons.wb_sunny_outlined, label: 'Sunset'.tr, value: LocaleText.time(waqt['Maghrib']!)),
                                  ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right_rounded, size: 20, color: AppPalette.goldLight),
                      ],
                    ),
                  ],
                ),
              ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  BoxDecoration _decoration() => BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1F7A42), Color(0xFF0B3A20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0x66E8C96A)),
        boxShadow: const [BoxShadow(color: Color(0x401B6B3A), blurRadius: 26, offset: Offset(0, 14))],
      );

  DateTime _previousAzan(Map<String, DateTime> azans, DateTime next) {
    DateTime? prev;
    for (final t in azans.values) {
      if (t.isBefore(next) && !t.isAfter(_now) && (prev == null || t.isAfter(prev))) prev = t;
    }
    return prev ?? azans['Isha']!.subtract(const Duration(days: 1));
  }

  DateTime _waqtFor(String name, Map<String, DateTime> waqt, DateTime nextAzan) {
    final offset = _p.azanOffsets[name] ?? 0;
    return nextAzan.subtract(Duration(minutes: offset));
  }

  ({String text, bool warning}) _status(Map<String, DateTime> w) {
    final now = _now;
    final sunrise = w['Sunrise']!;
    final dhuhr = w['Dhuhr']!;
    final maghrib = w['Maghrib']!;
    if (!now.isBefore(sunrise) && now.isBefore(sunrise.add(const Duration(minutes: 15)))) {
      return (
        text: '${'Makruh time (sunrise). Avoid nafl prayer until'.tr} ${LocaleText.time(sunrise.add(const Duration(minutes: 15)))}',
        warning: true,
      );
    }
    if (now.isAfter(dhuhr.subtract(const Duration(minutes: 8))) && now.isBefore(dhuhr)) {
      return (text: '${'Makruh time (zawal). Dhuhr begins at'.tr} ${LocaleText.time(dhuhr)}', warning: true);
    }
    if (now.isAfter(maghrib.subtract(const Duration(minutes: 15))) && now.isBefore(maghrib)) {
      return (text: '${'The sun is setting. Avoid nafl prayer until Maghrib'.tr} ${LocaleText.time(maghrib)}', warning: true);
    }
    String current;
    DateTime ends;
    if (now.isBefore(w['Fajr']!)) {
      current = 'Isha';
      ends = w['Fajr']!;
    } else if (now.isBefore(sunrise)) {
      current = 'Fajr';
      ends = sunrise;
    } else if (now.isBefore(dhuhr)) {
      return (text: '${'Fajr time has ended. Duha (Ishraq) time until'.tr} ${LocaleText.time(dhuhr.subtract(const Duration(minutes: 8)))}', warning: false);
    } else if (now.isBefore(w['Asr']!)) {
      current = 'Dhuhr';
      ends = w['Asr']!;
    } else if (now.isBefore(maghrib)) {
      current = 'Asr';
      ends = maghrib;
    } else if (now.isBefore(w['Isha']!)) {
      current = 'Maghrib';
      ends = w['Isha']!;
    } else {
      current = 'Isha';
      ends = w['Fajr']!.add(const Duration(days: 1));
    }
    final remaining = ends.difference(now);
    return (
      text: '${'Now'.tr}: ${current.tr} ${'waqt'.tr} · ${'ends'.tr} ${LocaleText.time(ends)} (${LocaleText.duration(remaining)})',
      warning: false,
    );
  }
}

class _CountdownRing extends StatelessWidget {
  final double progress;
  final String label;

  const _CountdownRing({required this.progress, required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      height: 96,
      child: CustomPaint(
        painter: _RingPainter(progress),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white, fontFeatures: [FontFeature.tabularFigures()])),
              Text('left'.tr, style: const TextStyle(fontSize: 10, color: Color(0xB3FFFFFF))),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final inner = rect.deflate(5);
    canvas.drawArc(inner, 0, math.pi * 2, false,
        Paint()
          ..color = const Color(0x26FFFFFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6);
    canvas.drawArc(inner, -math.pi / 2, math.pi * 2 * progress, false,
        Paint()
          ..shader = const SweepGradient(colors: [AppPalette.goldLight, AppPalette.gold, AppPalette.goldLight]).createShader(inner)
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 6);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

/// Faint eight-point star lattice in the corner of the hero.
class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x1AE8C96A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final c = size.center(Offset.zero);
    for (var r = size.width * 0.18; r < size.width * 0.55; r += size.width * 0.12) {
      for (final angle in [0.0, math.pi / 4]) {
        canvas.save();
        canvas.translate(c.dx, c.dy);
        canvas.rotate(angle);
        canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: r * 2, height: r * 2), paint);
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

typedef _Slot = ({String name, DateTime at, bool isNext, bool passed});

/// Five azan times on a glass panel joined by a day timeline; the next azan
/// is lifted in gold and passed ones are dimmed with a check.
class _Schedule extends StatelessWidget {
  final List<_Slot> prayers;
  const _Schedule({required this.prayers});

  static const _icons = {
    'Fajr': Icons.wb_twilight_rounded,
    'Dhuhr': Icons.wb_sunny_rounded,
    'Asr': Icons.light_mode_outlined,
    'Maghrib': Icons.nightlight_round,
    'Isha': Icons.dark_mode_rounded,
  };
  static const _iconTop = 10.0;
  static const _iconSize = 30.0;

  @override
  Widget build(BuildContext context) {
    final nextIdx = prayers.indexWhere((p) => p.isNext);
    final reached = nextIdx >= 0 ? nextIdx : prayers.lastIndexWhere((p) => p.passed);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0x1FFFFFFF), Color(0x0AFFFFFF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x33E8C96A)),
      ),
      child: LayoutBuilder(builder: (context, box) {
        final step = box.maxWidth / prayers.length;
        final lineY = _iconTop + _iconSize / 2;
        final reachedX = reached < 0 ? step / 2 : step * reached + step / 2;
        return Stack(
          children: [
            Positioned(
              left: step / 2,
              right: step / 2,
              top: lineY - 1,
              child: Container(height: 2, color: const Color(0x26FFFFFF)),
            ),
            if (reached > 0)
              Positioned(
                left: step / 2,
                width: reachedX - step / 2,
                top: lineY - 1,
                child: Container(
                  height: 2,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0x80E8C96A), AppPalette.goldLight]),
                  ),
                ),
              ),
            Row(
              children: [
                for (final p in prayers) Expanded(child: _cell(p)),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _cell(_Slot p) {
    final t = LocaleText.time(p.at);
    final split = t.lastIndexOf(' ');
    final clock = split > 0 ? t.substring(0, split) : t;
    final suffix = split > 0 ? t.substring(split + 1) : '';
    final fg = p.isNext ? AppPalette.goldLight : (p.passed ? const Color(0x8CFFFFFF) : Colors.white);

    final icon = Container(
      width: _iconSize,
      height: _iconSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: p.isNext
            ? const LinearGradient(
                colors: [Color(0xFFF3DC8E), AppPalette.gold],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: p.isNext ? null : (p.passed ? const Color(0xFF1A4D30) : const Color(0xFF1F5E3A)),
        border: p.isNext ? null : Border.all(color: p.passed ? const Color(0x33E8C96A) : const Color(0x4DFFFFFF)),
        boxShadow: p.isNext ? const [BoxShadow(color: Color(0x99E8C96A), blurRadius: 14)] : null,
      ),
      child: Icon(
        p.passed ? Icons.check_rounded : _icons[p.name],
        size: p.passed ? 15 : 16,
        color: p.isNext ? const Color(0xFF0B3A20) : (p.passed ? AppPalette.goldLight.withValues(alpha: 0.75) : Colors.white),
      ),
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 4),
      padding: const EdgeInsets.fromLTRB(2, _iconTop - 4, 2, 8),
      decoration: p.isNext
          ? BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0x40E8C96A), Color(0x0DE8C96A)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0x8CE8C96A)),
            )
          : null,
      child: Column(
        children: [
          icon,
          const SizedBox(height: 6),
          Text(
            p.name.tr,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 10, fontWeight: p.isNext ? FontWeight.w800 : FontWeight.w600, color: fg, letterSpacing: 0.2),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text.rich(
              TextSpan(children: [
                TextSpan(text: clock, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: fg)),
                if (suffix.isNotEmpty)
                  TextSpan(text: ' $suffix', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: fg.withValues(alpha: 0.75))),
              ]),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _Fact({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppPalette.goldLight),
        const SizedBox(width: 4),
        Text('$label ', style: const TextStyle(fontSize: 11, color: Color(0xB3FFFFFF))),
        Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)),
      ],
    );
  }
}

class _RoundAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _RoundAction({required this.icon, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(color: Color(0x26FFFFFF), shape: BoxShape.circle),
          child: Icon(icon, size: 16, color: Colors.white),
        ),
      ),
    );
  }
}
