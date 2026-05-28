import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/splash/presentation/splash_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/programs/presentation/programs_screen.dart';
import '../../features/workout/presentation/workout_screen.dart';
import '../../features/progress/presentation/progress_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/paywall_screen.dart';
import '../../shared/widgets/main_shell.dart';

// ── Route paths ──────────────────────────────────────────
abstract final class AppRoutes {
  static const splash      = '/';
  static const onboarding  = '/onboarding';
  static const home        = '/home';
  static const programs    = '/programs';
  static const workout     = '/workout';
  static const workoutActive = '/workout/active';
  static const progress    = '/progress';
  static const profile     = '/profile';
  static const paywall     = '/paywall';
}

// ── Shell navigation keys ────────────────────────────────
final _rootKey  = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,

    routes: [
      // ── Splash (no shell) ──
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashScreen(),
      ),

      // ── Onboarding (no shell) ──
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),

      // ── Main app shell (bottom nav) ──
      ShellRoute(
        navigatorKey: _shellKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (_, __) => _noTransitionPage(const HomeScreen()),
          ),
          GoRoute(
            path: AppRoutes.programs,
            pageBuilder: (_, __) => _noTransitionPage(const ProgramsScreen()),
          ),
          GoRoute(
            path: AppRoutes.workout,
            pageBuilder: (_, __) => _noTransitionPage(const WorkoutScreen()),
          ),
          GoRoute(
            path: AppRoutes.progress,
            pageBuilder: (_, __) => _noTransitionPage(const ProgressScreen()),
          ),
          GoRoute(
            path: AppRoutes.profile,
            pageBuilder: (_, __) => _noTransitionPage(const ProfileScreen()),
          ),
        ],
      ),

      // ── Active workout overlay (full-screen, no shell) ──
      GoRoute(
        path: AppRoutes.workoutActive,
        builder: (_, state) {
          final workoutId = state.uri.queryParameters['id'];
          return WorkoutActiveScreen(workoutId: workoutId);
        },
      ),

      // ── Paywall (modal-style, no shell) ──
      GoRoute(
        path: AppRoutes.paywall,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const PaywallScreen(),
          transitionsBuilder: (_, animation, __, child) => SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          ),
        ),
      ),
    ],
  );
});

CustomTransitionPage<void> _noTransitionPage(Widget child) =>
    CustomTransitionPage<void>(
      child: child,
      transitionsBuilder: (_, __, ___, w) => w,
    );
