// lib/presentation/screens/qibla/qibla_screen.dart
import 'dart:async';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../app/controllers/prayer_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/i18n/locale_text.dart';
import '../../../core/prayer/qibla_math.dart';
import '../../widgets/app_surfaces.dart';
import '../../widgets/location_picker.dart';

/// Qibla from the saved prayer location (no permission prompt on open):
/// smoothed compass dial with a Kaaba marker, turn guidance with haptics,
/// calibration help, AR camera view, and a sun check that needs no compass.
class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  static const _alignedWithin = 3.0;
  static const _cardinalNames = {
    'N': 'North', 'NNE': 'North-northeast', 'NE': 'Northeast', 'ENE': 'East-northeast',
    'E': 'East', 'ESE': 'East-southeast', 'SE': 'Southeast', 'SSE': 'South-southeast',
    'S': 'South', 'SSW': 'South-southwest', 'SW': 'Southwest', 'WSW': 'West-southwest',
    'W': 'West', 'WNW': 'West-northwest', 'NW': 'Northwest', 'NNW': 'North-northwest',
  };

  final PrayerController _p = Get.find();
  StreamSubscription<CompassEvent>? _compassSub;
  Timer? _noCompassTimer;

  /// Unwrapped, smoothed heading so the dial never spins the long way at 0°/360°.
  double? _heading;
  double? _accuracy;
  bool _hasCompass = true;
  bool _wasAligned = false;
  bool _locating = false;

  bool _arMode = false;
  bool _startingCamera = false;
  CameraController? _camera;

  late List<SunQiblaMoment> _sunMoments;
  late DateTime _sunDay;

  double get _lat => _p.latitude;
  double get _lng => _p.longitude;
  double get _qibla => QiblaMath.bearing(_lat, _lng);

  @override
  void initState() {
    super.initState();
    _computeSun();
    final events = FlutterCompass.events;
    if (events == null) {
      _hasCompass = false;
    } else {
      _compassSub = events.listen(_onCompass, onError: (_) => setState(() => _hasCompass = false));
      _noCompassTimer = Timer(const Duration(seconds: 3), () {
        if (mounted && _heading == null) setState(() => _hasCompass = false);
      });
    }
  }

  @override
  void dispose() {
    _compassSub?.cancel();
    _noCompassTimer?.cancel();
    _camera?.dispose();
    super.dispose();
  }

  void _computeSun() {
    _sunDay = DateTime.now();
    _sunMoments = QiblaMath.sunAlignments(_sunDay, _lat, _lng);
  }

  void _onCompass(CompassEvent e) {
    final h = e.heading;
    if (h == null || !mounted) return;
    final prev = _heading;
    final next = prev == null ? QiblaMath.norm(h) : prev + QiblaMath.delta(QiblaMath.norm(prev), h) * 0.22;
    final aligned = QiblaMath.delta(QiblaMath.norm(next), _qibla).abs() <= _alignedWithin;
    if (aligned && !_wasAligned) HapticFeedback.heavyImpact();
    _wasAligned = aligned;
    setState(() {
      _hasCompass = true;
      _heading = next;
      _accuracy = e.accuracy;
    });
  }

  bool get _needsCalibration {
    final a = _accuracy;
    return a != null && (a < 0 || a > 25);
  }

  Future<void> _useGps() async {
    setState(() => _locating = true);
    final error = await _p.useDeviceLocation();
    if (!mounted) return;
    setState(() {
      _locating = false;
      _computeSun();
    });
    if (error != null) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
  }

  Future<void> _changePlace() async {
    final changed = await showLocationPicker(context);
    if (changed && mounted) setState(_computeSun);
  }

  Future<void> _toggleAr() async {
    if (_arMode) {
      final camera = _camera;
      setState(() {
        _arMode = false;
        _camera = null;
      });
      await camera?.dispose();
      return;
    }
    if (_startingCamera) return;
    setState(() => _startingCamera = true);
    try {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        _snack('Camera permission is needed for Qibla AR.'.tr);
        return;
      }
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _snack('No camera found. The compass still works.'.tr);
        return;
      }
      final back = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(back, ResolutionPreset.medium, enableAudio: false);
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _camera = controller;
        _arMode = true;
      });
    } catch (_) {
      _snack('Could not open the camera. Use the compass instead.'.tr);
    } finally {
      if (mounted) setState(() => _startingCamera = false);
    }
  }

  void _snack(String text) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  String _deg(double v, [int decimals = 0]) => '${LocaleText.digits(v.toStringAsFixed(decimals))}°';

  String _km(double km) {
    final s = km.round().toString();
    final grouped = s.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
    return '${LocaleText.digits(grouped)} ${'km'.tr}';
  }

  @override
  Widget build(BuildContext context) {
    final qibla = _qibla;
    final heading = _heading == null ? null : QiblaMath.norm(_heading!);
    final turn = heading == null ? null : QiblaMath.delta(heading, qibla);
    final aligned = turn != null && turn.abs() <= _alignedWithin;

    return Scaffold(
      backgroundColor: _arMode ? Colors.black : AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        foregroundColor: AppColors.textDark,
        title: Column(
          children: [
            Text('Qibla'.tr, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            Text('اتجاه القبلة', style: TextStyle(fontFamily: 'Amiri', fontSize: 12, color: AppColors.textLight)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Calibrate compass'.tr,
            onPressed: () => _showCalibration(context),
            icon: Icon(Icons.all_inclusive_rounded, color: AppColors.emerald),
          ),
          IconButton(
            tooltip: _arMode ? 'Compass'.tr : 'Camera view'.tr,
            onPressed: _startingCamera || !_hasCompass ? null : _toggleAr,
            icon: _startingCamera
                ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.emerald))
                : Icon(_arMode ? Icons.explore_rounded : Icons.view_in_ar_rounded, color: AppColors.emerald),
          ),
        ],
      ),
      body: _arMode && _camera != null && _camera!.value.isInitialized
          ? _arView(turn, aligned)
          : _compassView(qibla, heading, turn, aligned),
    );
  }

  Widget _arView(double? turn, bool aligned) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreview(_camera!),
        Container(color: aligned ? const Color(0x2234A06A) : Colors.transparent),
        Center(
          child: Transform.rotate(
            angle: (turn ?? 0) * math.pi / 180,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.navigation_rounded, size: 96, color: aligned ? AppPalette.goldLight : Colors.white,
                    shadows: const [Shadow(blurRadius: 16, color: Colors.black54)]),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 28,
          child: _TurnPill(turn: turn, aligned: aligned, onDark: true),
        ),
      ],
    );
  }

  Widget _compassView(double qibla, double? heading, double? turn, bool aligned) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      children: [
        _TurnPill(turn: turn, aligned: aligned, noCompass: !_hasCompass),
        if (_needsCalibration) ...[
          const SizedBox(height: 10),
          _Notice(
            icon: Icons.all_inclusive_rounded,
            color: const Color(0xFFE09B2D),
            text: 'Compass accuracy is low. Move your phone in a figure-8 a few times.'.tr,
            action: 'How?'.tr,
            onAction: () => _showCalibration(context),
          ),
        ],
        if (!_hasCompass) ...[
          const SizedBox(height: 10),
          _Notice(
            icon: Icons.explore_off_rounded,
            color: AppColors.textMid,
            text: 'No compass found on this phone. The dial shows north at the top; use the sun times below to find the Qibla.'.tr,
          ),
        ],
        const SizedBox(height: 16),
        LayoutBuilder(builder: (context, box) {
          final size = math.min(box.maxWidth - 8, 330.0);
          return Center(
            child: _Dial(
              size: size,
              qibla: qibla,
              rotation: _heading ?? 0,
              aligned: aligned,
              turn: turn,
            ),
          );
        }),
        const SizedBox(height: 18),
        _infoGrid(qibla, heading),
        const SizedBox(height: 12),
        _locationCard(),
        const SizedBox(height: 12),
        _sunCard(),
        const SizedBox(height: 12),
        _overheadCard(),
        const SizedBox(height: 12),
        _tipsCard(),
      ],
    );
  }

  Widget _infoGrid(double qibla, double? heading) {
    final cardinal = QiblaMath.cardinal(qibla);
    return Row(
      children: [
        Expanded(
          child: _InfoTile(
            icon: Icons.mosque_rounded,
            label: 'Qibla direction'.tr,
            value: _deg(qibla, 1),
            sub: '${(_cardinalNames[cardinal] ?? cardinal).tr} · ${'from north'.tr}',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _InfoTile(
            icon: Icons.straighten_rounded,
            label: 'Distance to Kaaba'.tr,
            value: _km(QiblaMath.distanceKm(_lat, _lng)),
            sub: 'Makkah al-Mukarramah'.tr,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _InfoTile(
            icon: Icons.navigation_outlined,
            label: 'You are facing'.tr,
            value: heading == null ? '--' : _deg(heading),
            sub: heading == null ? 'No compass'.tr : (_cardinalNames[QiblaMath.cardinal(heading)] ?? '').tr,
          ),
        ),
      ],
    );
  }

  Widget _locationCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      decoration: AppSurfaces.card(radius: 18),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: AppColors.emeraldPale, shape: BoxShape.circle),
            child: Icon(_p.usingGps.value ? Icons.my_location_rounded : Icons.location_city_rounded, size: 20, color: AppColors.emerald),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_p.placeLabel, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                Text(
                  _p.usingGps.value ? 'From your phone location (GPS)'.tr : 'City centre. Use GPS for the most exact Qibla.'.tr,
                  style: TextStyle(fontSize: 11.5, color: AppColors.textMid),
                ),
              ],
            ),
          ),
          if (_locating)
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.emerald)),
            )
          else ...[
            IconButton(
              tooltip: 'Use GPS'.tr,
              onPressed: _useGps,
              icon: Icon(Icons.gps_fixed_rounded, color: AppColors.emerald),
            ),
            TextButton(
              onPressed: _changePlace,
              child: Text('Change'.tr, style: TextStyle(color: AppColors.emerald, fontWeight: FontWeight.w700)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _sunCard() {
    final now = DateTime.now();
    return _SectionCard(
      icon: Icons.wb_sunny_rounded,
      title: 'Check with the sun'.tr,
      subtitle: 'Works without a compass. At these times today:'.tr,
      children: _sunMoments.isEmpty
          ? [
              Text('The sun does not line up with the Qibla today from here. Use the compass or check tomorrow.'.tr,
                  style: TextStyle(fontSize: 12.5, height: 1.4, color: AppColors.textMid)),
            ]
          : [
              for (final m in _sunMoments)
                _SunRow(
                  time: LocaleText.time(m.at),
                  text: m.kind == SunQiblaKind.faceSun
                      ? 'Face the sun: you are facing the Qibla'.tr
                      : 'Your shadow points to the Qibla'.tr,
                  icon: m.kind == SunQiblaKind.faceSun ? Icons.wb_sunny_outlined : Icons.accessibility_new_rounded,
                  passed: m.at.isBefore(now),
                ),
            ],
    );
  }

  Widget _overheadCard() {
    final at = QiblaMath.nextKaabaOverhead(DateTime.now());
    final sunUp = QiblaMath.sun(at, _lat, _lng).altitude > 3;
    return _SectionCard(
      icon: Icons.brightness_7_rounded,
      title: 'Sun over the Kaaba'.tr,
      subtitle: '${LocaleText.gregorian(at, withWeekday: true)} · ${LocaleText.time(at)}',
      children: [
        Text(
          sunUp
              ? 'Twice a year the sun stands almost straight over the Kaaba. At this time (±1 day), face the sun from anywhere it is visible and you face the Qibla.'.tr
              : 'Twice a year the sun stands almost straight over the Kaaba. At this time the sun is below the horizon where you are, so use the compass or the daily sun times.'.tr,
          style: TextStyle(fontSize: 12.5, height: 1.45, color: AppColors.textMid),
        ),
      ],
    );
  }

  Widget _tipsCard() {
    return _SectionCard(
      icon: Icons.tips_and_updates_rounded,
      title: 'For an accurate Qibla'.tr,
      children: [
        for (final tip in [
          'Hold the phone flat, screen facing up.',
          'Stay away from metal, magnets, speakers and other phones.',
          'Remove magnetic phone cases or stands.',
          'If the needle jumps, calibrate with a figure-8 motion.',
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Icon(Icons.circle, size: 6, color: AppColors.gold),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(tip.tr, style: TextStyle(fontSize: 12.5, height: 1.4, color: AppColors.textMid))),
              ],
            ),
          ),
      ],
    );
  }

  void _showCalibration(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const _CalibrationSheet(),
    );
  }
}

class _TurnPill extends StatelessWidget {
  final double? turn;
  final bool aligned;
  final bool onDark;
  final bool noCompass;
  const _TurnPill({required this.turn, required this.aligned, this.onDark = false, this.noCompass = false});

  @override
  Widget build(BuildContext context) {
    final String text;
    final IconData icon;
    if (noCompass || turn == null) {
      text = noCompass ? 'Compass not available'.tr : 'Reading the compass…'.tr;
      icon = Icons.explore_outlined;
    } else if (aligned) {
      text = 'You are facing the Qibla'.tr;
      icon = Icons.check_circle_rounded;
    } else {
      final deg = LocaleText.digits(turn!.abs().round());
      text = (turn! > 0 ? 'Turn right @deg°' : 'Turn left @deg°').trParams({'deg': deg});
      icon = turn! > 0 ? Icons.turn_right_rounded : Icons.turn_left_rounded;
    }
    final bg = aligned
        ? const LinearGradient(colors: [Color(0xFF1F7A42), Color(0xFF0E3D22)])
        : null;
    final fg = aligned || onDark ? Colors.white : AppColors.textDark;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: bg,
        color: bg != null ? null : (onDark ? const Color(0x99000000) : AppColors.card),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: aligned ? AppPalette.goldLight : AppColors.gold.withValues(alpha: 0.35)),
        boxShadow: aligned ? const [BoxShadow(color: Color(0x5534A06A), blurRadius: 18, offset: Offset(0, 6))] : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: aligned ? AppPalette.goldLight : (onDark ? Colors.white : AppColors.emerald), size: 22),
          const SizedBox(width: 8),
          Flexible(
            child: Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: fg)),
          ),
        ],
      ),
    );
  }
}

class _Dial extends StatelessWidget {
  final double size;
  final double qibla;
  final double rotation;
  final bool aligned;
  final double? turn;

  const _Dial({required this.size, required this.qibla, required this.rotation, required this.aligned, required this.turn});

  @override
  Widget build(BuildContext context) {
    final dark = ThemeColors.isDark;
    final ring = aligned ? AppColors.emerald : AppColors.gold;
    return SizedBox(
      width: size,
      height: size + 14,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 14,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.card,
                border: Border.all(color: ring.withValues(alpha: aligned ? 0.9 : 0.45), width: aligned ? 3 : 1.5),
                boxShadow: [
                  BoxShadow(
                    color: aligned ? AppColors.emerald.withValues(alpha: 0.35) : Colors.black.withValues(alpha: dark ? 0.4 : 0.08),
                    blurRadius: aligned ? 30 : 22,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Transform.rotate(
                angle: -rotation * math.pi / 180,
                child: CustomPaint(
                  painter: _DialPainter(
                    qibla: qibla,
                    tick: AppColors.textLight,
                    major: AppColors.textMid,
                    label: AppColors.textDark,
                    north: const Color(0xFFD9534F),
                    gold: AppColors.gold,
                    emerald: AppColors.emerald,
                    aligned: aligned,
                  ),
                ),
              ),
            ),
          ),
          // Phone direction pointer, fixed at the top.
          Positioned(
            top: 0,
            child: CustomPaint(size: const Size(22, 20), painter: _PointerPainter(aligned ? AppColors.emerald : AppColors.textDark)),
          ),
          Positioned(
            top: 14 + size / 2 - 42,
            child: Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: aligned ? AppColors.emerald : AppColors.card,
                border: Border.all(color: ring.withValues(alpha: 0.6), width: 1.5),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: dark ? 0.35 : 0.08), blurRadius: 10)],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    turn == null ? '${LocaleText.digits(qibla.round())}°' : '${LocaleText.digits(turn!.abs().round())}°',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: aligned ? Colors.white : AppColors.textDark),
                  ),
                  Text(
                    aligned ? 'Qibla'.tr : (turn == null ? 'from north'.tr : 'to Qibla'.tr),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: aligned ? AppPalette.goldLight : AppColors.textLight),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DialPainter extends CustomPainter {
  final double qibla;
  final Color tick, major, label, north, gold, emerald;
  final bool aligned;

  _DialPainter({
    required this.qibla,
    required this.tick,
    required this.major,
    required this.label,
    required this.north,
    required this.gold,
    required this.emerald,
    required this.aligned,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;

    Offset at(double deg, double radius) {
      final a = (deg - 90) * math.pi / 180;
      return c + Offset(math.cos(a), math.sin(a)) * radius;
    }

    // Qibla sector glow.
    final sector = Paint()
      ..shader = RadialGradient(colors: [gold.withValues(alpha: 0.0), gold.withValues(alpha: aligned ? 0.35 : 0.22)])
          .createShader(Rect.fromCircle(center: c, radius: r));
    canvas.drawArc(Rect.fromCircle(center: c, radius: r - 2), (qibla - 90 - 6) * math.pi / 180, 12 * math.pi / 180, true, sector);

    for (var d = 0; d < 360; d += 5) {
      final isMajor = d % 30 == 0;
      final len = isMajor ? 12.0 : (d % 10 == 0 ? 8.0 : 5.0);
      canvas.drawLine(
        at(d.toDouble(), r - 6),
        at(d.toDouble(), r - 6 - len),
        Paint()
          ..color = isMajor ? major : tick.withValues(alpha: 0.7)
          ..strokeWidth = isMajor ? 2 : 1
          ..strokeCap = StrokeCap.round,
      );
    }

    const cardinals = {0: 'N', 90: 'E', 180: 'S', 270: 'W'};
    for (var d = 0; d < 360; d += 30) {
      final card = cardinals[d];
      final text = card ?? LocaleText.digits(d);
      _text(
        canvas,
        text,
        at(d.toDouble(), r - 34),
        TextStyle(
          fontSize: card != null ? 17 : 10,
          fontWeight: card != null ? FontWeight.w900 : FontWeight.w600,
          color: d == 0 ? north : (card != null ? label : major),
        ),
      );
    }

    // Line to the Kaaba with the marker on the rim.
    final marker = at(qibla, r - 62);
    canvas.drawLine(
      c,
      marker,
      Paint()
        ..shader = LinearGradient(colors: [gold.withValues(alpha: 0.1), gold]).createShader(Rect.fromPoints(c, marker))
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    canvas.save();
    canvas.translate(marker.dx, marker.dy);
    canvas.rotate(qibla * math.pi / 180);
    canvas.drawCircle(Offset.zero, 17, Paint()..color = aligned ? emerald : gold);
    canvas.drawCircle(Offset.zero, 17, Paint()..color = Colors.white.withValues(alpha: 0.85)..style = PaintingStyle.stroke..strokeWidth = 2);
    final cube = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: 16, height: 16), const Radius.circular(2.5));
    canvas.drawRRect(cube, Paint()..color = const Color(0xFF151515));
    canvas.drawRect(Rect.fromLTWH(-8, -3.5, 16, 2.6), Paint()..color = const Color(0xFFE8C96A));
    canvas.restore();
  }

  void _text(Canvas canvas, String text, Offset center, TextStyle style) {
    final tp = TextPainter(text: TextSpan(text: text, style: style), textDirection: TextDirection.ltr)..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_DialPainter old) =>
      old.qibla != qibla || old.aligned != aligned || old.label != label || old.tick != tick;
}

class _PointerPainter extends CustomPainter {
  final Color color;
  _PointerPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_PointerPainter old) => old.color != color;
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String sub;

  const _InfoTile({required this.icon, required this.label, required this.value, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
      decoration: AppSurfaces.card(radius: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.gold),
          const SizedBox(height: 6),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10.5, color: AppColors.textLight)),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.emerald)),
          ),
          Text(sub, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10, height: 1.3, color: AppColors.textMid)),
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  final String? action;
  final VoidCallback? onAction;

  const _Notice({required this.icon, required this.color, required this.text, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: TextStyle(fontSize: 12, height: 1.4, color: AppColors.textDark))),
          if (action != null)
            TextButton(onPressed: onAction, child: Text(action!, style: TextStyle(color: color, fontWeight: FontWeight.w800))),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final List<Widget> children;

  const _SectionCard({required this.icon, required this.title, this.subtitle, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      decoration: AppSurfaces.card(radius: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(color: AppColors.goldPale, shape: BoxShape.circle),
                child: Icon(icon, size: 18, color: AppColors.gold),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                    if (subtitle != null)
                      Text(subtitle!, style: TextStyle(fontSize: 11.5, color: AppColors.textMid)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _SunRow extends StatelessWidget {
  final String time;
  final String text;
  final IconData icon;
  final bool passed;

  const _SunRow({required this.time, required this.text, required this.icon, required this.passed});

  @override
  Widget build(BuildContext context) {
    final color = passed ? AppColors.textLight : AppColors.textDark;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: passed ? Colors.transparent : AppColors.emeraldPale,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.emerald.withValues(alpha: passed ? 0.15 : 0.3)),
      ),
      child: Row(
        children: [
          Icon(passed ? Icons.check_rounded : icon, size: 18, color: passed ? AppColors.textLight : AppColors.emerald),
          const SizedBox(width: 10),
          Text(time, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: passed ? AppColors.textLight : AppColors.emerald)),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: TextStyle(fontSize: 12, color: color))),
        ],
      ),
    );
  }
}

class _CalibrationSheet extends StatefulWidget {
  const _CalibrationSheet();

  @override
  State<_CalibrationSheet> createState() => _CalibrationSheetState();
}

class _CalibrationSheetState extends State<_CalibrationSheet> with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Calibrate the compass'.tr, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            const SizedBox(height: 16),
            SizedBox(
              width: 180,
              height: 90,
              child: AnimatedBuilder(
                animation: _anim,
                builder: (_, __) {
                  final t = _anim.value * 2 * math.pi;
                  final dx = math.sin(t) * 60;
                  final dy = math.sin(2 * t) * 22;
                  return Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      Icon(Icons.all_inclusive_rounded, size: 150, color: AppColors.gold.withValues(alpha: 0.35)),
                      Transform.translate(
                        offset: Offset(dx, dy),
                        child: Transform.rotate(
                          angle: math.cos(t) * 0.5,
                          child: Icon(Icons.smartphone_rounded, size: 34, color: AppColors.emerald),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Hold the phone and draw a large figure-8 in the air 3 times, tilting it as you go. Then lay it flat and wait a moment.'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, height: 1.5, color: AppColors.textMid),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(backgroundColor: AppColors.emerald, padding: const EdgeInsets.symmetric(vertical: 14)),
                child: Text('Done'.tr, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
