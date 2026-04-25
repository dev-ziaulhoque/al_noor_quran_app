// lib/presentation/screens/splash/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );
    _ctrl.forward();
    Future.delayed(const Duration(seconds: 2, milliseconds: 500), () {
      Get.offNamed(AppRoutes.home);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1B6B3A), Color(0xFF0D4223), Color(0xFF2D8B52)],
            stops: [0.0, 0.58, 1.0],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Decorative rings
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.gold.withOpacity(0.15),
                            width: 1,
                          ),
                        ),
                      ),
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.gold.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                      ),
                      // Logo gem
                      Transform.rotate(
                        angle: 0.785, // 45 degrees
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.goldLight, AppColors.gold],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Transform.rotate(
                              angle: -0.785,
                              child: const Text(
                                '☪',
                                style: TextStyle(
                                  fontSize: 26,
                                  color: Colors.white,
                                  fontFamily: 'Amiri',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  // App name Arabic
                  const Text(
                    'النور',
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 42,
                      color: Colors.white,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Subtitle
                  const Text(
                    'القرآن الكريم',
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 20,
                      color: Color(0xBFFFFFFF),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Divider
                  Container(
                    width: 50,
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.transparent, AppColors.goldLight, Colors.transparent],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'AL-NOOR',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0x66FFFFFF),
                      letterSpacing: 6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
