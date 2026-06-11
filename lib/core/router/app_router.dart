import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../firebase_availability.dart';
import '../../features/auth/presentation/auth_screen.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/programs/presentation/program_assign_screen.dart';
import '../../features/today/today_screen.dart';
import '../../features/programs/presentation/programs_screen.dart';
import '../../features/programs/presentation/program_detail_screen.dart';
import '../../features/workout/presentation/workout_screen.dart';
import '../../features/workout/presentation/workout_history_screen.dart';
import '../../features/workout/presentation/workout_summary_screen.dart';
import '../../features/progress/presentation/progress_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/paywall_screen.dart';
import '../../features/profile/presentation/legal_screen.dart';
import '../../features/exercises/presentation/exercise_library_screen.dart';
import '../../features/coach/presentation/coach_profile_screen.dart';
import '../../features/coach/presentation/coach_screen.dart';
import '../../features/exercises/presentation/exercise_detail_screen.dart';
import '../../features/workout/domain/workout_log_model.dart';
import '../../features/workout/presentation/workout_log_detail_screen.dart';
import '../../shared/widgets/main_shell.dart';

// ── Route paths ──────────────────────────────────────────
abstract final class AppRoutes {
  static const splash           = '/';
  static const onboarding       = '/onboarding';
  static const programAssign    = '/assign';
  static const login            = '/login';

  // Shell tabs
  static const today            = '/today';
  static const programs         = '/programs';
  static const progress         = '/progress';
  static const coach            = '/coach';
  static const coachProfile     = '/coach/profile';
  static const profile          = '/profile';

  // Full-screen (no shell)
  static const workoutActive    = '/workout/active';
  static const workoutSummary   = '/workout/summary';
  static const workoutHistory   = '/workout/history';
  static const workoutLogDetail = '/workout/history/detail';
  static const exerciseLibrary  = '/exercises';
  static const exerciseDetail   = '/exercises/:id';
  static const paywall          = '/paywall';
  static const privacyPolicy    = '/privacy';
  static const termsOfService   = '/terms';
}

// ── Shell navigation keys ────────────────────────────────
final _rootKey  = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

const _protectedPrefixes = [
  '/today', '/programs', '/progress', '/coach', '/profile',
  '/exercises', '/paywall',
];

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,

    redirect: (context, state) {
      // No auth on platforms where Firebase isn't available (Linux desktop)
      if (!ref.read(firebaseAvailableProvider)) return null;

      final loc = state.matchedLocation;
      final needsAuth = _protectedPrefixes.any((p) => loc.startsWith(p));
      if (!needsAuth) return null;

      final authState = ref.read(authStateChangesProvider);
      if (authState.isLoading) return null; // let splash handle auth wait
      if (authState.value == null) return AppRoutes.login;
      return null;
    },

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

      // ── Program assignment (no shell, post-onboarding) ──
      GoRoute(
        path: AppRoutes.programAssign,
        builder: (_, __) => const ProgramAssignScreen(),
      ),

      // ── Login / Register (no shell) ──
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const AuthScreen(),
      ),

      // ── /home → /today redirect (backward compat) ──
      GoRoute(
        path: '/home',
        redirect: (_, __) => AppRoutes.today,
      ),

      // ── Main app shell (5 tabs) ──
      ShellRoute(
        navigatorKey: _shellKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.today,
            pageBuilder: (_, __) => _noTransitionPage(const TodayScreen()),
          ),
          GoRoute(
            path: AppRoutes.programs,
            pageBuilder: (_, __) => _noTransitionPage(const ProgramsScreen()),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, state) => ProgramDetailScreen(
                  programId: state.pathParameters['id'] ?? '',
                ),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.progress,
            pageBuilder: (_, __) => _noTransitionPage(const ProgressScreen()),
          ),
          GoRoute(
            path: AppRoutes.coach,
            pageBuilder: (_, __) => _noTransitionPage(const CoachScreen()),
            routes: [
              GoRoute(
                path: 'profile',
                builder: (_, __) => const CoachProfileScreen(),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.profile,
            pageBuilder: (_, __) => _noTransitionPage(const ProfileScreen()),
          ),
        ],
      ),

      // ── Active workout (full-screen, no shell) ──
      GoRoute(
        path: AppRoutes.workoutActive,
        builder: (_, state) {
          final workoutId = state.uri.queryParameters['id'];
          return WorkoutActiveScreen(workoutId: workoutId);
        },
      ),

      // ── Post-workout summary (full-screen, no shell) ──
      GoRoute(
        path: AppRoutes.workoutSummary,
        builder: (_, state) => WorkoutSummaryScreen(
          log: state.extra as WorkoutLog,
        ),
      ),

      // ── Workout history (full-screen, no shell) ──
      GoRoute(
        path: AppRoutes.workoutHistory,
        builder: (_, __) => const WorkoutHistoryScreen(),
      ),

      // ── Workout log detail ──
      GoRoute(
        path: AppRoutes.workoutLogDetail,
        builder: (_, state) => WorkoutLogDetailScreen(
          log: state.extra as WorkoutLog,
        ),
      ),

      // ── Exercise library (full-screen, no shell) ──
      GoRoute(
        path: AppRoutes.exerciseLibrary,
        builder: (_, __) => const ExerciseLibraryScreen(),
      ),

      // ── Exercise detail ──
      GoRoute(
        path: AppRoutes.exerciseDetail,
        builder: (_, state) => ExerciseDetailScreen(
          exerciseId: state.pathParameters['id'] ?? '',
        ),
      ),

      // ── Legal screens ──
      GoRoute(
        path: AppRoutes.privacyPolicy,
        builder: (_, __) =>
            const LegalScreen(type: LegalDocType.privacyPolicy),
      ),
      GoRoute(
        path: AppRoutes.termsOfService,
        builder: (_, __) => const LegalScreen(type: LegalDocType.terms),
      ),

      // ── Paywall (slide-up modal, no shell) ──
      GoRoute(
        path: AppRoutes.paywall,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const PaywallScreen(),
          transitionsBuilder: (_, animation, __, child) => SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
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
