import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/firebase_availability.dart';
import '../../../core/router/app_router.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2400));
    if (!mounted) return;

    final firebaseAvailable = ref.read(firebaseAvailableProvider);

    if (firebaseAvailable) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        context.go(AppRoutes.home);
        return;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final hasOnboarded = prefs.getBool('onboarded') ?? false;

    if (!mounted) return;
    // On Linux (no Firebase): go straight to home after onboarding
    if (!firebaseAvailable) {
      context.go(hasOnboarded ? AppRoutes.home : AppRoutes.onboarding);
      return;
    }
    context.go(hasOnboarded ? AppRoutes.login : AppRoutes.onboarding);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          // Radial glow background
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: AppColors.splashGlow,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo mark
                _LogoMark()
                    .animate()
                    .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                    .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack),
                const SizedBox(height: 28),

                // App name
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Flex',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFF0F0F0),
                          letterSpacing: -0.8,
                        ),
                      ),
                      TextSpan(
                        text: 'Pro',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: AppColors.accent,
                          letterSpacing: -0.8,
                        ),
                      ),
                    ],
                  ),
                )
                    .animate(delay: 300.ms)
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.2, curve: Curves.easeOut),

                const SizedBox(height: 6),
                const Text(
                  'Premium Coaching',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFA0A0A0),
                    letterSpacing: 0.3,
                  ),
                ).animate(delay: 400.ms).fadeIn(duration: 500.ms),

                const SizedBox(height: 4),
                const Text(
                  'by Tasos Misailidis',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF606060),
                  ),
                ).animate(delay: 500.ms).fadeIn(duration: 500.ms),

                const SizedBox(height: 60),

                // Loading bar
                _LoadingBar()
                    .animate(delay: 600.ms)
                    .fadeIn(duration: 300.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A3F44), Color(0xFF0D2228)],
        ),
        border: Border.all(
          color: AppColors.accent.withAlpha(77),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withAlpha(51),
            blurRadius: 40,
            spreadRadius: 0,
          ),
        ],
      ),
      child: const CustomPaint(
        painter: _BarPainter(),
      ),
    );
  }
}

class _BarPainter extends CustomPainter {
  const _BarPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    final stroke = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Left plate
    final leftRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx - 18, cy), width: 8, height: 22),
      const Radius.circular(4),
    );
    canvas.drawRRect(leftRect, paint..color = AppColors.accent.withAlpha(230));

    // Right plate
    final rightRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx + 18, cy), width: 8, height: 22),
      const Radius.circular(4),
    );
    canvas.drawRRect(rightRect, paint..color = AppColors.accent.withAlpha(230));

    // Bar
    canvas.drawLine(
      Offset(cx - 14, cy), Offset(cx + 14, cy), stroke,
    );

    // Inner ring
    final ringRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: 20, height: 14),
      const Radius.circular(4),
    );
    canvas.drawRRect(ringRect, stroke..color = AppColors.accent);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LoadingBar extends StatefulWidget {
  @override
  State<_LoadingBar> createState() => _LoadingBarState();
}

class _LoadingBarState extends State<_LoadingBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..forward();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => LinearProgressIndicator(
            value: _ctrl.value,
            backgroundColor: const Color(0xFF2A2A2A),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
          ),
        ),
      ),
    );
  }
}
