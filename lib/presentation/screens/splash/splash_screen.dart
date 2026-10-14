// lib/presentation/screens/splash/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/services/storage_service.dart';
import '../../widgets/app_logo.dart';

/// Same colour and logo size as the native splash (flutter_native_splash in
/// pubspec.yaml) so the hand-off from the OS splash is invisible.
const _splashBg = Color(0xFF021B1D);
const _logoSize = 256.0;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
  late final Animation<double> _glow = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
  late final Animation<double> _footer = CurvedAnimation(parent: _ctrl, curve: const Interval(0.35, 1, curve: Curves.easeOut));

  @override
  void initState() {
    super.initState();
    final onboarded = Get.find<StorageService>().isOnboarded();
    Future.delayed(const Duration(milliseconds: 1300), () {
      Get.offNamed(onboarded ? AppRoutes.home : AppRoutes.onboarding);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    AppLogo.precache(context);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _splashBg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: _glow,
            builder: (_, __) => DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  radius: 0.75,
                  colors: [
                    AppPalette.gold.withValues(alpha: 0.10 * _glow.value),
                    _splashBg.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          const Center(child: AppLogo.full(size: _logoSize)),
          Positioned(
            left: 0,
            right: 0,
            bottom: 56,
            child: FadeTransition(
              opacity: _footer,
              child: Column(
                children: [
                  const Text(
                    'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(fontFamily: 'Amiri', fontSize: 18, color: AppPalette.goldLight),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppPalette.goldLight.withValues(alpha: 0.8),
                    ),
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
