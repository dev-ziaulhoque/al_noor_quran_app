import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Decorative layers for share cards: girih star lattice, mihrab arch with a
/// mosque skyline, arabesque border with rosettes, or none.
enum IslamicArt { lattice, mihrab, arabesque, simple }

extension IslamicArtName on IslamicArt {
  String get label => switch (this) {
        IslamicArt.lattice => 'Star lattice',
        IslamicArt.mihrab => 'Mihrab',
        IslamicArt.arabesque => 'Arabesque',
        IslamicArt.simple => 'Simple',
      };
}

/// Eight-point star (khatam) centred on [c].
Path octagram(Offset c, double r, {double inner = 0.62}) {
  final path = Path();
  for (var i = 0; i < 16; i++) {
    final radius = i.isEven ? r : r * inner;
    final a = -math.pi / 2 + i * math.pi / 8;
    final p = Offset(c.dx + radius * math.cos(a), c.dy + radius * math.sin(a));
    i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
  }
  return path..close();
}

class IslamicArtPainter extends CustomPainter {
  final IslamicArt art;
  final Color accent;
  final bool compact;

  IslamicArtPainter({required this.art, required this.accent, this.compact = false});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    final glow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.6),
        radius: 0.9,
        colors: [Colors.white.withValues(alpha: 0.10), Colors.transparent],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, glow);

    switch (art) {
      case IslamicArt.lattice:
        _lattice(canvas, size);
      case IslamicArt.mihrab:
        _mihrab(canvas, size);
      case IslamicArt.arabesque:
        _arabesque(canvas, size);
      case IslamicArt.simple:
        break;
    }
  }

  void _lattice(Canvas canvas, Size size) {
    final s = (size.shortestSide / 4.2).clamp(34.0, 72.0);
    final centre = size.center(Offset.zero);
    final maxDist = centre.distance;
    var row = 0;
    for (var y = -s / 2; y < size.height + s; y += s * 0.86, row++) {
      final shift = row.isOdd ? s / 2 : 0.0;
      for (var x = -s + shift; x < size.width + s; x += s) {
        final c = Offset(x, y);
        // Stronger at the edges, faint behind the text.
        final t = ((c - centre).distance / maxDist).clamp(0.0, 1.0);
        final alpha = 0.05 + 0.20 * t;
        final star = Paint()
          ..color = accent.withValues(alpha: alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = compact ? 0.8 : 1.1;
        canvas.drawPath(octagram(c, s * 0.36), star);
        canvas.drawCircle(c, s * 0.08, star);
        canvas.drawPath(
          octagram(Offset(x + s / 2, y), s * 0.1, inner: 0.5),
          Paint()..color = accent.withValues(alpha: alpha * 0.7),
        );
      }
    }
    _cornerRosette(canvas, Offset(size.width, size.height), size.shortestSide * 0.42, 0.10);
  }

  void _mihrab(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final m = compact ? 8.0 : 12.0;
    final spring = m + math.min(w * 0.30, h * 0.32);
    Path arch(double inset) {
      final left = m + inset;
      final right = w - m - inset;
      final top = m + inset;
      final bottom = h - m - inset * 0.3;
      final sp = spring + inset * 0.4;
      return Path()
        ..moveTo(left, bottom)
        ..lineTo(left, sp)
        ..cubicTo(left, sp - (sp - top) * 0.55, w / 2 - w * 0.10, top + (sp - top) * 0.25, w / 2, top)
        ..cubicTo(w / 2 + w * 0.10, top + (sp - top) * 0.25, right, sp - (sp - top) * 0.55, right, sp)
        ..lineTo(right, bottom);
    }

    final line = Paint()
      ..color = accent.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = compact ? 1.0 : 1.4;
    canvas.drawPath(arch(0), line);
    canvas.drawPath(arch(compact ? 4 : 6), line..color = accent.withValues(alpha: 0.25));

    // Spandrel stars.
    final fill = Paint()..color = accent.withValues(alpha: 0.35);
    canvas.drawPath(octagram(Offset(m + w * 0.08, m + spring * 0.25), compact ? 4 : 6), fill);
    canvas.drawPath(octagram(Offset(w - m - w * 0.08, m + spring * 0.25), compact ? 4 : 6), fill);

    // Lantern hanging from the apex.
    final apex = Offset(w / 2, m + (compact ? 4 : 6));
    final lanternTop = apex.dy + (compact ? 10 : 18);
    final thin = Paint()
      ..color = accent.withValues(alpha: 0.6)
      ..strokeWidth = 1;
    canvas.drawLine(apex, Offset(w / 2, lanternTop), thin);
    final lw = compact ? 5.0 : 8.0;
    final lantern = Path()
      ..moveTo(w / 2, lanternTop)
      ..lineTo(w / 2 + lw, lanternTop + lw * 1.4)
      ..lineTo(w / 2, lanternTop + lw * 2.8)
      ..lineTo(w / 2 - lw, lanternTop + lw * 1.4)
      ..close();
    canvas.drawPath(lantern, Paint()..color = accent.withValues(alpha: 0.75));
    canvas.drawCircle(Offset(w / 2, lanternTop + lw * 1.4), lw * 0.35, Paint()..color = Colors.white.withValues(alpha: 0.8));

    _skyline(canvas, size, m);
  }

  void _skyline(Canvas canvas, Size size, double m) {
    final w = size.width;
    final base = size.height - m;
    final unit = (w * 0.03).clamp(7.0, 13.0) * (compact ? 0.7 : 1.0);
    final paint = Paint()..color = accent.withValues(alpha: 0.16);
    final cx = w / 2;
    final path = Path()
      // Main hall.
      ..addRect(Rect.fromLTRB(cx - unit * 3, base - unit * 1.6, cx + unit * 3, base))
      // Central dome.
      ..addOval(Rect.fromCircle(center: Offset(cx, base - unit * 1.6), radius: unit * 1.7))
      // Side domes.
      ..addOval(Rect.fromCircle(center: Offset(cx - unit * 2.3, base - unit * 1.6), radius: unit * 0.8))
      ..addOval(Rect.fromCircle(center: Offset(cx + unit * 2.3, base - unit * 1.6), radius: unit * 0.8));
    for (final x in [cx - unit * 4.2, cx + unit * 4.2]) {
      path
        ..addRect(Rect.fromLTRB(x - unit * 0.3, base - unit * 4.2, x + unit * 0.3, base))
        ..moveTo(x - unit * 0.42, base - unit * 4.2)
        ..lineTo(x, base - unit * 5.2)
        ..lineTo(x + unit * 0.42, base - unit * 4.2)
        ..close();
    }
    canvas.drawPath(path, paint);
    // Crescent on the dome.
    final top = Offset(cx, base - unit * 3.6);
    canvas.drawLine(top, top.translate(0, -unit * 0.5), Paint()..color = accent.withValues(alpha: 0.3)..strokeWidth = 1);
    _crescent(canvas, top.translate(0, -unit * 0.85), unit * 0.35, accent.withValues(alpha: 0.35));
  }

  void _arabesque(Canvas canvas, Size size) {
    final m = compact ? 7.0 : 10.0;
    final r = compact ? 12.0 : 18.0;
    final outer = RRect.fromRectAndRadius(Rect.fromLTWH(m, m, size.width - m * 2, size.height - m * 2), Radius.circular(r));
    final inner = outer.deflate(compact ? 4 : 6);
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = compact ? 1.0 : 1.4
      ..color = accent.withValues(alpha: 0.6);
    canvas.drawRRect(outer, line);
    canvas.drawRRect(inner, line..color = accent.withValues(alpha: 0.28)..strokeWidth = 0.8);

    _cornerRosette(canvas, Offset(size.width, 0), size.shortestSide * 0.45, 0.09);
    _cornerRosette(canvas, Offset(0, size.height), size.shortestSide * 0.45, 0.09);

    final rose = compact ? 5.0 : 8.0;
    final fill = Paint()..color = accent.withValues(alpha: 0.9);
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = accent.withValues(alpha: 0.6);
    for (final c in [
      Offset(m, m),
      Offset(size.width - m, m),
      Offset(m, size.height - m),
      Offset(size.width - m, size.height - m),
    ]) {
      canvas.drawCircle(c, rose * 1.5, Paint()..color = Colors.black.withValues(alpha: 0.15));
      canvas.drawCircle(c, rose * 1.5, ring);
      canvas.drawPath(octagram(c, rose), fill);
    }
    // Small ornaments on the side midpoints.
    for (final c in [Offset(m, size.height / 2), Offset(size.width - m, size.height / 2)]) {
      canvas.drawPath(octagram(c, rose * 0.6, inner: 0.45), fill);
    }
  }

  /// Faint 12-petal rosette, centred on a corner and clipped by the card.
  void _cornerRosette(Canvas canvas, Offset c, double radius, double alpha) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = accent.withValues(alpha: alpha);
    for (var i = 0; i < 12; i++) {
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(i * math.pi / 6);
      canvas.drawOval(Rect.fromCenter(center: Offset(0, -radius * 0.5), width: radius * 0.32, height: radius), paint);
      canvas.restore();
    }
    canvas.drawCircle(c, radius * 0.22, paint);
    canvas.drawCircle(c, radius * 1.02, paint);
  }

  void _crescent(Canvas canvas, Offset c, double r, Color color) {
    final path = Path.combine(
      PathOperation.difference,
      Path()..addOval(Rect.fromCircle(center: c, radius: r)),
      Path()..addOval(Rect.fromCircle(center: c.translate(r * 0.45, -r * 0.15), radius: r * 0.85)),
    );
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(IslamicArtPainter old) => old.art != art || old.accent != accent || old.compact != compact;
}

/// Line · star · line, used between the Arabic and the meaning.
class OrnamentDivider extends StatelessWidget {
  final Color color;
  final double size;

  const OrnamentDivider({super.key, required this.color, this.size = 10});

  @override
  Widget build(BuildContext context) {
    Widget line(bool reverse) => Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: reverse
                    ? [color.withValues(alpha: 0.7), color.withValues(alpha: 0)]
                    : [color.withValues(alpha: 0), color.withValues(alpha: 0.7)],
              ),
            ),
          ),
        );
    return Row(
      children: [
        const Spacer(),
        line(false),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: size * 0.6),
          child: StarGlyph(color: color, size: size),
        ),
        line(true),
        const Spacer(),
      ],
    );
  }
}

class StarGlyph extends StatelessWidget {
  final Color color;
  final double size;
  const StarGlyph({super.key, required this.color, this.size = 10});

  @override
  Widget build(BuildContext context) => CustomPaint(size: Size.square(size), painter: _StarGlyphPainter(color));
}

class _StarGlyphPainter extends CustomPainter {
  final Color color;
  _StarGlyphPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    canvas.drawPath(octagram(c, size.width / 2), Paint()..color = color);
    canvas.drawCircle(c, size.width * 0.14, Paint()..color = Colors.black.withValues(alpha: 0.25));
  }

  @override
  bool shouldRepaint(_StarGlyphPainter old) => old.color != color;
}
