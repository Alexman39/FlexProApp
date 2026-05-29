import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/fp_card.dart';
import '../../auth/providers/auth_providers.dart';
import '../../programs/data/programs_data.dart';
import '../../programs/providers/enrollment_provider.dart';
import '../../workout/data/firestore_workout_repository.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enrollment = ref.watch(enrollmentProvider).valueOrNull;
    final historyAsync = ref.watch(workoutHistoryStreamProvider);
    final history = historyAsync.valueOrNull ?? [];
    final appUser = ref.watch(appUserProvider).valueOrNull;
    final enrolledProgram = enrollment != null
        ? kAllPrograms.where((p) => p.id == enrollment.programId).firstOrNull
        : null;

    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header ──
            SliverToBoxAdapter(
              child: _HomeHeader(firstName: appUser?.firstName ?? 'Athlete')
                  .animate()
                  .fadeIn(duration: 400.ms),
            ),

            // ── Hero workout card ──
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              sliver: SliverToBoxAdapter(
                child: _HeroWorkoutCard()
                    .animate(delay: 80.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.1, curve: Curves.easeOut),
              ),
            ),

            // ── Streak card ──
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              sliver: SliverToBoxAdapter(
                child: _StreakCard()
                    .animate(delay: 160.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.1, curve: Curves.easeOut),
              ),
            ),

            // ── Quick stats ──
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              sliver: SliverToBoxAdapter(
                child: _QuickStats()
                    .animate(delay: 220.ms)
                    .fadeIn(duration: 400.ms),
              ),
            ),

            // ── Active program banner ──
            if (enrolledProgram != null)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: _ActiveProgramBanner(
                    programName: enrolledProgram.title,
                    weekLabel: enrollment!.weekLabel,
                    dayLabel: enrollment.dayLabel,
                    completedSessions: enrollment.totalSessions,
                  ).animate(delay: 200.ms).fadeIn(duration: 300.ms),
                ),
              ),

            // ── Quick access row ──
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    _QuickAccessButton(
                      icon: Icons.fitness_center_rounded,
                      label: 'Exercise\nLibrary',
                      count: '${history.isEmpty ? '' : '${history.length} sessions'}',
                      onTap: () => context.push(AppRoutes.exerciseLibrary),
                    ),
                    const SizedBox(width: 10),
                    _QuickAccessButton(
                      icon: Icons.history_rounded,
                      label: 'Workout\nHistory',
                      count: history.isEmpty ? 'No sessions' : '${history.length} sessions',
                      onTap: () => context.push(AppRoutes.workoutHistory),
                    ),
                  ],
                ).animate(delay: 240.ms).fadeIn(duration: 300.ms),
              ),
            ),

            // ── Recommended section ──
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              sliver: SliverToBoxAdapter(
                child: FpSectionHeader(
                  title: 'Recommended for You',
                  action: 'See all',
                  onAction: () => context.go(AppRoutes.programs),
                ).animate(delay: 280.ms).fadeIn(),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _ProgramRow(
                    emoji: '💪',
                    title: 'PPL Hypertrophy 6-Day',
                    subtitle: 'Push · Pull · Legs × 2 per week',
                    level: 'Intermediate',
                    weeks: 12,
                    levelColor: AppColors.intermediateColor,
                  ).animate(delay: 320.ms).fadeIn().slideY(begin: 0.1, curve: Curves.easeOut),
                  const SizedBox(height: 10),
                  _ProgramRow(
                    emoji: '🏋️',
                    title: 'Upper/Lower Strength',
                    subtitle: '4 days · Progressive overload focus',
                    level: 'Beginner',
                    weeks: 8,
                    levelColor: AppColors.beginnerColor,
                  ).animate(delay: 380.ms).fadeIn().slideY(begin: 0.1, curve: Curves.easeOut),
                  const SizedBox(height: 10),
                  _ProgramRow(
                    emoji: '🏆',
                    title: 'TASOS Elite — Pro Split',
                    subtitle: '5 days · Competitive prep methodology',
                    level: 'Advanced',
                    weeks: 16,
                    levelColor: AppColors.advancedColor,
                  ).animate(delay: 440.ms).fadeIn().slideY(begin: 0.1, curve: Curves.easeOut),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────
class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.firstName});
  final String firstName;

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning 👋'
        : hour < 17
            ? 'Good afternoon 👋'
            : 'Good evening 👋';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: context.secondaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  firstName,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: context.primaryText,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => context.go(AppRoutes.profile),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.accent, Color(0xFF66F0FF)],
                ),
                border: Border.all(color: AppColors.accent, width: 2),
              ),
              child: const Center(
                child: Text(
                  'A',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hero workout card ─────────────────────────────────────
class _HeroWorkoutCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FpCard(
      gradient: AppColors.heroCardGradient,
      borderColor: AppColors.accent.withAlpha(51),
      padding: const EdgeInsets.all(22),
      onTap: () => context.go(AppRoutes.workoutActive),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Glow blob
          Positioned(
            top: -50, right: -50,
            child: Container(
              width: 200, height: 200,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppColors.accentGlow, Colors.transparent],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label
              Text(
                'TODAY\'S WORKOUT',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Upper Body — Push A',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Week 3  ·  PPL Hypertrophy  ·  Day 2 of 5',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: Colors.white.withAlpha(153),
                ),
              ),
              const SizedBox(height: 20),

              // Stats row
              Row(
                children: [
                  _HeroStat(value: '7',  label: 'Exercises'),
                  const SizedBox(width: 24),
                  _HeroStat(value: '52', label: 'Est. min'),
                  const SizedBox(width: 24),
                  _HeroStat(value: '21', label: 'Sets'),
                ],
              ),
              const SizedBox(height: 22),

              // Start button
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withAlpha(77),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.play_arrow_rounded, color: Colors.black, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Start Workout',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: AppColors.accent,
          ),
        ),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF606060),
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }
}

// ── Streak card ───────────────────────────────────────────
class _StreakCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FpCard(
      gradient: AppColors.streakGradient,
      borderColor: AppColors.warning.withAlpha(77),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 34)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '12 Day Streak',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Keep it going! Next badge at 14 days.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: context.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.warning, size: 22),
        ],
      ),
    );
  }
}

// ── Quick stats row ───────────────────────────────────────
class _QuickStats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(value: '24',   label: 'Workouts'),
        const SizedBox(width: 10),
        _StatCard(value: '8.4t', label: 'Volume'),
        const SizedBox(width: 10),
        _StatCard(value: '+12%', label: 'Strength', valueColor: AppColors.success),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label, this.valueColor});

  final String value;
  final String label;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FpCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: valueColor ?? AppColors.accent,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: context.tertiaryText,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Program row ───────────────────────────────────────────
class _ProgramRow extends StatelessWidget {
  const _ProgramRow({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.level,
    required this.weeks,
    required this.levelColor,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final String level;
  final int weeks;
  final Color levelColor;

  @override
  Widget build(BuildContext context) {
    return FpCard(
      onTap: () => context.go(AppRoutes.programs),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: AppColors.accentDim,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: context.primaryText,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: context.secondaryText,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    FpChip(label: level, color: levelColor,
                        backgroundColor: levelColor.withAlpha(26)),
                    FpChip(label: '$weeks Weeks'),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              color: context.tertiaryText, size: 20),
        ],
      ),
    );
  }
}

// ── Active program banner ─────────────────────────────────
class _ActiveProgramBanner extends StatelessWidget {
  const _ActiveProgramBanner({
    required this.programName,
    required this.weekLabel,
    required this.dayLabel,
    required this.completedSessions,
  });

  final String programName;
  final String weekLabel;
  final String dayLabel;
  final int completedSessions;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.accent.withAlpha(12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.accent.withAlpha(50)),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.accent.withAlpha(26),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.flag_rounded,
                color: AppColors.accent, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Program',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  programName,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: context.primaryText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                weekLabel,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                ),
              ),
              Text(
                dayLabel,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: context.secondaryText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Quick access button ───────────────────────────────────
class _QuickAccessButton extends StatelessWidget {
  const _QuickAccessButton({
    required this.icon,
    required this.label,
    required this.count,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: FpCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AppColors.accentDim,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.accent, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: context.primaryText,
                        height: 1.2,
                      ),
                    ),
                    if (count.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        count,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          color: context.tertiaryText,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
