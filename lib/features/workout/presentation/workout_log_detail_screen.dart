import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/workout_log_model.dart';

class WorkoutLogDetailScreen extends StatelessWidget {
  const WorkoutLogDetailScreen({super.key, required this.log});

  final WorkoutLog log;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEEE, MMMM d · h:mm a').format(log.startedAt);

    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: context.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: context.border),
                        ),
                        child: Icon(Icons.arrow_back_ios_rounded,
                            size: 16, color: context.primaryText),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        log.workoutName,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: context.primaryText,
                          letterSpacing: -0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms),
            ),

            // ── Date + summary stats ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: context.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _StatBadge(
                          icon: Icons.timer_outlined,
                          value: log.formattedDuration,
                          label: 'Duration',
                        ),
                        const SizedBox(width: 10),
                        _StatBadge(
                          icon: Icons.fitness_center_rounded,
                          value: '${log.exercises.length}',
                          label: 'Exercises',
                        ),
                        const SizedBox(width: 10),
                        _StatBadge(
                          icon: Icons.trending_up_rounded,
                          value: log.formattedVolume,
                          label: 'Volume',
                          accent: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate(delay: 60.ms).fadeIn(),
            ),

            // ── Exercise breakdown ──
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ExerciseBlock(
                      exercise: log.exercises[i],
                      index: i,
                    ).animate(delay: (80 + i * 40).ms)
                        .fadeIn(duration: 250.ms)
                        .slideY(begin: 0.06, curve: Curves.easeOut),
                  ),
                  childCount: log.exercises.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stat badge ────────────────────────────────────────────
class _StatBadge extends StatelessWidget {
  const _StatBadge({
    required this.icon,
    required this.value,
    required this.label,
    this.accent = false,
  });

  final IconData icon;
  final String value;
  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final color = accent ? AppColors.accent : context.secondaryText;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: accent ? AppColors.accentDim : context.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: accent ? AppColors.accent.withAlpha(77) : context.border,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: context.tertiaryText,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Exercise block ────────────────────────────────────────
class _ExerciseBlock extends StatelessWidget {
  const _ExerciseBlock({required this.exercise, required this.index});

  final LoggedExercise exercise;
  final int index;

  @override
  Widget build(BuildContext context) {
    final volume = exercise.sets
        .fold(0.0, (sum, s) => sum + s.weight * s.reps);
    final best = exercise.sets
        .map((s) => s.weight)
        .fold(0.0, (a, b) => a > b ? a : b);

    return Container(
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.accentDim,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    exercise.exerciseName,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: context.primaryText,
                    ),
                  ),
                ),
                Text(
                  '${volume.toStringAsFixed(0)} kg',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Sets table header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _TH('SET', flex: 1),
                _TH('WEIGHT', flex: 3),
                _TH('REPS', flex: 2),
                _TH('RPE', flex: 2),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // Set rows
          ...exercise.sets.asMap().entries.map((e) {
            final set = e.value;
            final isBest = set.weight == best && best > 0;
            return Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 4),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                color: isBest
                    ? AppColors.accent.withAlpha(12)
                    : context.surface2,
                borderRadius: BorderRadius.circular(8),
                border: isBest
                    ? Border.all(color: AppColors.accent.withAlpha(51))
                    : null,
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: isBest
                          ? const Icon(Icons.emoji_events_rounded,
                              size: 16, color: AppColors.accent)
                          : Text(
                              '${e.key + 1}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: context.secondaryText,
                              ),
                            ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      '${set.weight.toStringAsFixed(set.weight % 1 == 0 ? 0 : 1)} kg',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isBest ? AppColors.accent : context.primaryText,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${set.reps}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: context.primaryText,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      set.rpe != null
                          ? set.rpe!.toStringAsFixed(1)
                          : '—',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: context.tertiaryText,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _TH extends StatelessWidget {
  const _TH(this.label, {required this.flex});
  final String label;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: context.tertiaryText,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
