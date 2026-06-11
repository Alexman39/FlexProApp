import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flexpro_coaching/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/fp_button.dart';
import '../../../shared/widgets/fp_card.dart';
import '../../coach/providers/coach_providers.dart';
import '../data/firestore_workout_repository.dart';
import '../data/workout_repository.dart';
import '../domain/workout_log_model.dart';

class WorkoutSummaryScreen extends ConsumerWidget {
  const WorkoutSummaryScreen({super.key, required this.log});

  final WorkoutLog log;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;

    // PR detection: prefer Firestore stream, fall back to Hive
    final firestoreHistory = ref.watch(workoutHistoryStreamProvider).valueOrNull;
    final hiveHistory = ref.watch(workoutHistoryProvider);
    final allHistory = firestoreHistory ?? hiveHistory;
    final prevLogs = allHistory.where((h) => h.id != log.id).toList();

    // Build per-exercise historical best weight (excluding current log)
    final historicalBests = <String, double>{};
    for (final pastLog in prevLogs) {
      for (final ex in pastLog.exercises) {
        historicalBests[ex.exerciseId] = math.max(
          historicalBests[ex.exerciseId] ?? 0.0,
          ex.bestSet,
        );
      }
    }

    // Exercises that beat their previous best weight → PR
    final prIds = <String>{
      for (final ex in log.exercises)
        if (ex.bestSet > (historicalBests[ex.exerciseId] ?? 0.0) && ex.bestSet > 0)
          ex.exerciseId,
    };

    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: Column(
          children: [
            _SummaryHeader(log: log, l: l),
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Stats row
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                      child: _StatsRow(log: log, l: l),
                    ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.1),
                  ),

                  // PR banner (only when records were broken)
                  if (prIds.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                        child: _PrBanner(log: log, prIds: prIds, l: l),
                      ).animate(delay: 160.ms).fadeIn().slideY(begin: 0.1),
                    ),

                  // Section header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                      child: Text(
                        l.exercises.toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: context.tertiaryText,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ).animate(delay: 220.ms).fadeIn(),
                  ),

                  // Per-exercise cards
                  SliverList.builder(
                    itemCount: log.exercises.length,
                    itemBuilder: (context, i) {
                      final ex = log.exercises[i];
                      return Padding(
                        padding: EdgeInsets.fromLTRB(
                          20, 0, 20, i < log.exercises.length - 1 ? 10 : 0,
                        ),
                        child: _ExerciseSummaryCard(
                          exercise: ex,
                          isPr: prIds.contains(ex.exerciseId),
                          l: l,
                        ).animate(
                          delay: Duration(milliseconds: 260 + i * 60),
                        ).fadeIn().slideY(begin: 0.08, curve: Curves.easeOut),
                      );
                    },
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _BottomActions(log: log, l: l),
    );
  }
}

// ── Header ────────────────────────────────────────────────────
class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({required this.log, required this.l});

  final WorkoutLog log;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => context.go(AppRoutes.today),
                child: Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: context.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radius),
                    border: Border.all(color: context.border),
                  ),
                  child: Icon(
                    Icons.chevron_left_rounded,
                    color: context.primaryText, size: 24,
                  ),
                ),
              ),
              const Spacer(),
              // Duration chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accentDim,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer_outlined,
                        color: AppColors.accent, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      log.formattedDuration,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Icon(Icons.emoji_events_rounded, size: 52, color: AppColors.accent)
              .animate()
              .scale(
                begin: const Offset(0.5, 0.5),
                duration: 500.ms,
                curve: Curves.elasticOut,
              ),
          const SizedBox(height: 10),
          Text(
            l.workoutComplete,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: context.primaryText,
              letterSpacing: -0.5,
            ),
          ).animate(delay: 80.ms).fadeIn().slideY(begin: 0.1),
          const SizedBox(height: 3),
          Text(
            log.workoutName,
            style: TextStyle(
              fontFamily: 'Inter', fontSize: 14,
              color: context.secondaryText,
            ),
          ).animate(delay: 120.ms).fadeIn(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ── Stats row ─────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.log, required this.l});

  final WorkoutLog log;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatChip(
          icon: Icons.check_circle_outline_rounded,
          label: l.sets,
          value: '${log.totalSets}',
        ),
        const SizedBox(width: 10),
        _StatChip(
          icon: Icons.bolt_rounded,
          label: l.volume,
          value: log.formattedVolume,
        ),
        const SizedBox(width: 10),
        _StatChip(
          icon: Icons.fitness_center_rounded,
          label: l.exercises,
          value: '${log.exercises.length}',
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusLG),
          border: Border.all(color: context.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.accent, size: 18),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: context.primaryText,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter', fontSize: 11,
                color: context.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── PR Banner ─────────────────────────────────────────────────
class _PrBanner extends StatelessWidget {
  const _PrBanner({required this.log, required this.prIds, required this.l});

  final WorkoutLog log;
  final Set<String> prIds;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final prExercises =
        log.exercises.where((e) => prIds.contains(e.exerciseId)).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent.withAlpha(20),
            AppColors.accent.withAlpha(8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        border: Border.all(color: AppColors.accent.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.military_tech_rounded,
                  color: AppColors.accent, size: 18),
              const SizedBox(width: 6),
              Text(
                l.personalRecords,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.accent,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: prExercises
                .map((ex) => _PrBadge(name: ex.exerciseName, l: l))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _PrBadge extends StatelessWidget {
  const _PrBadge({required this.name, required this.l});

  final String name;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l.newPr,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: Colors.black,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            name,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Exercise summary card ──────────────────────────────────────
class _ExerciseSummaryCard extends StatelessWidget {
  const _ExerciseSummaryCard({
    required this.exercise,
    required this.isPr,
    required this.l,
  });

  final LoggedExercise exercise;
  final bool isPr;
  final AppLocalizations l;

  String _fmt(double v) =>
      v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    return FpCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise name + optional PR badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  exercise.exerciseName,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: context.primaryText,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              if (isPr) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(AppTheme.radiusXS),
                  ),
                  child: Text(
                    l.newPr,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 3),
          Text(
            '${l.volume}: ${_fmt(exercise.totalVolume)} kg',
            style: TextStyle(
              fontFamily: 'Inter', fontSize: 12,
              color: context.secondaryText,
            ),
          ),
          const SizedBox(height: 12),

          // Column headers
          _SetTableHeader(l: l),
          const Divider(height: 12, thickness: 0.5),

          // Set rows
          ...List.generate(exercise.sets.length, (i) {
            return _SetRow(index: i + 1, set: exercise.sets[i], l: l);
          }),
        ],
      ),
    );
  }
}

class _SetTableHeader extends StatelessWidget {
  const _SetTableHeader({required this.l});

  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontFamily: 'Inter',
      fontSize: 10,
      fontWeight: FontWeight.w700,
      color: context.tertiaryText,
      letterSpacing: 0.8,
    );
    return Row(
      children: [
        SizedBox(width: 36, child: Text('SET', style: style)),
        Expanded(child: Text(l.weightLabel, style: style)),
        Expanded(child: Text(l.repsLabel, style: style)),
        SizedBox(
          width: 64,
          child: Text(l.volLabel, style: style, textAlign: TextAlign.right),
        ),
      ],
    );
  }
}

class _SetRow extends StatelessWidget {
  const _SetRow({required this.index, required this.set, required this.l});

  final int index;
  final LoggedSet set;
  final AppLocalizations l;

  String _fmt(double v) =>
      v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          // Set number bubble
          SizedBox(
            width: 36,
            child: Container(
              width: 22, height: 22,
              decoration: BoxDecoration(
                color: AppColors.accentDim,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  '$index',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ),
          ),
          // Weight
          Expanded(
            child: Text(
              '${_fmt(set.weight)} kg',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.primaryText,
              ),
            ),
          ),
          // Reps
          Expanded(
            child: Text(
              '${set.reps}',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.primaryText,
              ),
            ),
          ),
          // Volume
          SizedBox(
            width: 64,
            child: Text(
              '${_fmt(set.volume)} kg',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: context.secondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bottom actions ─────────────────────────────────────────────
class _BottomActions extends ConsumerWidget {
  const _BottomActions({required this.log, required this.l});

  final WorkoutLog log;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedbackStatus = ref.watch(feedbackRequestProvider);
    final isSent = feedbackStatus == FeedbackRequestStatus.sent;
    final isLoading = feedbackStatus == FeedbackRequestStatus.loading;

    return Container(
      padding: EdgeInsets.fromLTRB(
        20, 12, 20, MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: context.surface,
        border: Border(top: BorderSide(color: context.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FpButton(
            label: isSent ? l.feedbackRequested : l.requestCoachFeedback,
            variant: FpButtonVariant.secondary,
            isLoading: isLoading,
            icon: isSent
                ? const Icon(Icons.check_circle_outline_rounded)
                : const Icon(Icons.message_outlined),
            onPressed: (isSent || isLoading)
                ? null
                : () {
                    HapticFeedback.lightImpact();
                    ref.read(feedbackRequestProvider.notifier).request(log.id);
                  },
          ),
          const SizedBox(height: 8),
          FpButton(
            label: l.backToToday,
            icon: const Icon(Icons.home_rounded),
            onPressed: () {
              HapticFeedback.mediumImpact();
              context.go(AppRoutes.today);
            },
          ),
        ],
      ),
    );
  }
}
