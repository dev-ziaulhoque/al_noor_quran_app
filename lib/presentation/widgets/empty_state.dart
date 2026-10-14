import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Friendly placeholder for empty lists, missing data and errors.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? actionIcon;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final bool compact;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.actionIcon,
    this.secondaryLabel,
    this.onSecondary,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final medal = compact ? 96.0 : 132.0;
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 28, vertical: compact ? 16 : 32),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 520),
          curve: Curves.easeOutCubic,
          builder: (context, t, child) => Opacity(
            opacity: t,
            child: Transform.translate(offset: Offset(0, 16 * (1 - t)), child: child),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: medal,
                height: medal,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [AppColors.emerald.withValues(alpha: 0.16), AppColors.emerald.withValues(alpha: 0.02)],
                        ),
                      ),
                    ),
                    CustomPaint(
                      size: Size.square(medal * 0.82),
                      painter: _StarPainter(AppColors.gold.withValues(alpha: 0.55)),
                    ),
                    Container(
                      width: medal * 0.44,
                      height: medal * 0.44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [AppColors.emerald, AppColors.emerald.withValues(alpha: 0.78)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [BoxShadow(color: AppColors.emerald.withValues(alpha: 0.3), blurRadius: 18, offset: const Offset(0, 8))],
                      ),
                      child: Icon(icon, color: Colors.white, size: medal * 0.22),
                    ),
                  ],
                ),
              ),
              SizedBox(height: compact ? 12 : 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: compact ? 15 : 17, fontWeight: FontWeight.w800, color: AppColors.textDark),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, height: 1.45, color: AppColors.textMid),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: onAction,
                  icon: Icon(actionIcon ?? Icons.arrow_forward_rounded, size: 18, color: Colors.white),
                  label: Text(actionLabel!, style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.emerald,
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                ),
              ],
              if (secondaryLabel != null && onSecondary != null)
                TextButton(
                  onPressed: onSecondary,
                  child: Text(secondaryLabel!, style: TextStyle(color: AppColors.emerald, fontWeight: FontWeight.w600)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Rub el Hizb: two squares, one turned 45°.
class _StarPainter extends CustomPainter {
  final Color color;
  _StarPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final c = size.center(Offset.zero);
    final half = size.width * 0.36;
    for (final angle in [0.0, math.pi / 4]) {
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(angle);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: half * 2, height: half * 2), const Radius.circular(4)),
        paint,
      );
      canvas.restore();
    }
    canvas.drawCircle(c, size.width * 0.5, paint..color = color.withValues(alpha: color.a * 0.4));
  }

  @override
  bool shouldRepaint(_StarPainter old) => old.color != color;
}
