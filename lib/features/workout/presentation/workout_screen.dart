import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flexpro_coaching/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/set_card.dart';
import '../../../shared/widgets/fp_button.dart';
import '../../../shared/widgets/fp_card.dart';
import '../../programs/providers/enrollment_provider.dart';
import '../../programs/providers/todays_workout_provider.dart';
import '../domain/models.dart';
import '../providers/workout_provider.dart';

/// Entry point in the shell nav — shows today's scheduled workout.
class WorkoutScreen extends ConsumerWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final session    = ref.watch(todaysSessionProvider);
    final program    = ref.watch(activeProgramProvider);
    final enrollment = ref.watch(enrollmentProvider).valueOrNull;

    final title   = session?.name ?? l.freeWorkout;
    final sets     = session?.totalSets ?? 0;
    final estMin   = session?.estimatedMinutes ?? 0;
    final exCount  = session?.exercises.length ?? 0;
    final subtitle = program != null && enrollment != null
        ? '${program.title}  ·  ${enrollment.weekLabel}'
        : l.noActiveProgram;

    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.workoutTitle,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: AppTypeScale.displayMd,
                  fontWeight: FontWeight.w900,
                  color: context.primaryText,
                  letterSpacing: -0.5,
                ),
              ).animate().fadeIn(duration: 300.ms),
              const SizedBox(height: AppSpacing.base),
              FpCard(
                gradient: AppColors.heroCardGradient,
                borderColor: AppColors.accent.withAlpha(51),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.todaysWorkout,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      session != null
                          ? '$exCount exercises  ·  ~$estMin min  ·  $sets sets'
                          : subtitle,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: Colors.white.withAlpha(153),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FpButton(
                      label: l.startWorkout,
                      icon: const Icon(Icons.play_arrow_rounded),
                      onPressed: () => context.push(AppRoutes.workoutActive),
                    ),
                  ],
                ),
              ).animate(delay: 80.ms).fadeIn().slideY(begin: 0.1),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full-screen active workout execution screen.
class WorkoutActiveScreen extends ConsumerStatefulWidget {
  const WorkoutActiveScreen({super.key, this.workoutId});

  final String? workoutId;

  @override
  ConsumerState<WorkoutActiveScreen> createState() => _WorkoutActiveScreenState();
}

class _WorkoutActiveScreenState extends ConsumerState<WorkoutActiveScreen> {
  int _currentExerciseIdx = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final todaysWorkout = ref.read(todaysActiveWorkoutProvider);
      ref.read(workoutProvider.notifier).start(workout: todaysWorkout);
    });
  }

  @override
  Widget build(BuildContext context) {
    final workout = ref.watch(workoutProvider);
    final elapsed = ref.watch(workoutElapsedProvider);
    final rest = ref.watch(restTimerProvider);

    if (workout == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final exercise = workout.exercises[_currentExerciseIdx];

    return Scaffold(
      backgroundColor: context.bg,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // ── Top bar ──
                _TopBar(
                  elapsed: elapsed.value ?? Duration.zero,
                  onFinish: _finishWorkout,
                ),

                // ── Title ──
                _WorkoutTitle(
                  title: workout.title,
                  subtitle: '${workout.title}  ·  Exercise ${_currentExerciseIdx + 1} of ${workout.exercises.length}',
                ),

                // ── Scrollable content ──
                Expanded(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // Overall progress bar
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                          child: _OverallProgress(workout: workout),
                        ),
                      ),

                      // Current exercise card
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverToBoxAdapter(
                          child: _ExerciseCard(
                            key: ValueKey('ex_$_currentExerciseIdx'),
                            exerciseItem: exercise,
                            exerciseIdx: _currentExerciseIdx,
                            onSetComplete: (setIdx) => _onSetComplete(exercise, setIdx),
                          ).animate()
                              .fadeIn(duration: 300.ms)
                              .slideY(begin: 0.06, curve: Curves.easeOut),
                        ),
                      ),

                      const SliverToBoxAdapter(child: SizedBox(height: 120)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Rest overlay ──
          if (rest.isActive)
            _RestOverlay(
              state: rest,
              onSkip: () => ref.read(restTimerProvider.notifier).skip(),
            ),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        canGoPrev: _currentExerciseIdx > 0,
        canGoNext: _currentExerciseIdx < workout.exercises.length - 1,
        onPrev: () => setState(() => _currentExerciseIdx--),
        onNext: () => setState(() => _currentExerciseIdx++),
      ),
    );
  }

  void _onSetComplete(WorkoutExercise exercise, int setIdx) {
    HapticFeedback.mediumImpact();
    ref.read(restTimerProvider.notifier).start(exercise.restSeconds);
  }

  Future<void> _finishWorkout() async {
    HapticFeedback.heavyImpact();

    final enrollment = ref.read(enrollmentProvider).valueOrNull;
    final program    = ref.read(activeProgramProvider);

    final log = await ref.read(workoutProvider.notifier).finish(
      programId:   enrollment?.programId,
      programWeek: enrollment?.currentWeek,
      programDay:  enrollment?.currentDay,
    );

    if (enrollment != null && program != null && log != null) {
      try {
        await ref.read(enrollmentProvider.notifier).completeSession(
          log.id,
          daysPerWeek: program.daysPerWeek,
        );
      } catch (e) {
        debugPrint('completeSession failed: $e');
      }
    }

    if (!mounted) return;
    if (log != null) {
      context.go(AppRoutes.workoutSummary, extra: log);
    } else {
      context.go(AppRoutes.today);
    }
  }
}

// ── Top bar ───────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  const _TopBar({required this.elapsed, required this.onFinish});

  final Duration elapsed;
  final VoidCallback onFinish;

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.base, AppSpacing.md, AppSpacing.base, AppSpacing.sm),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: context.surface,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: context.border),
              ),
              child: Icon(Icons.chevron_left_rounded,
                  color: context.primaryText, size: 24),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                _fmt(elapsed),
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.accent,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: onFinish,
            style: TextButton.styleFrom(
              backgroundColor: context.surface,
              side: BorderSide(color: context.border),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(
              AppLocalizations.of(context)!.finish,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: context.secondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Title ─────────────────────────────────────────────────
class _WorkoutTitle extends StatelessWidget {
  const _WorkoutTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: context.primaryText,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: context.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Overall progress ──────────────────────────────────────
class _OverallProgress extends StatelessWidget {
  const _OverallProgress({required this.workout});

  final ActiveWorkout workout;

  @override
  Widget build(BuildContext context) {
    final pct = workout.totalSets == 0
        ? 0.0
        : workout.completedSets / workout.totalSets;

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 3,
              backgroundColor: context.surface3,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '${workout.completedSets}/${workout.totalSets} sets',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: context.secondaryText,
          ),
        ),
      ],
    );
  }
}

// ── Exercise card ─────────────────────────────────────────
class _ExerciseCard extends ConsumerStatefulWidget {
  const _ExerciseCard({
    super.key,
    required this.exerciseItem,
    required this.exerciseIdx,
    required this.onSetComplete,
  });

  final WorkoutExercise exerciseItem;
  final int exerciseIdx;
  final void Function(int setIdx) onSetComplete;

  @override
  ConsumerState<_ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends ConsumerState<_ExerciseCard> {
  late List<double?> _weights;
  late List<int?> _reps;
  late List<double?> _rpes;

  @override
  void initState() {
    super.initState();
    final sets = widget.exerciseItem.sets;
    _weights = sets.map((s) => s.loggedWeight ?? s.targetWeight).toList();
    _reps    = sets.map((s) => s.loggedReps   ?? s.targetReps).toList();
    _rpes    = sets.map((s) => s.loggedRpe    ?? s.rpe).toList();
  }

  @override
  Widget build(BuildContext context) {
    final ex = widget.exerciseItem;

    return FpCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Exercise header ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AppLocalizations.of(context)!.exercise} ${widget.exerciseIdx + 1}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ex.exercise.name,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: context.primaryText,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ex.exercise.muscleDisplay,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: context.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  color: context.surface2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.border),
                ),
                child: const Icon(Icons.play_circle_outline_rounded,
                    color: AppColors.accent, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // ── Set cards ──
          ...List.generate(ex.sets.length, (i) {
            final set = ex.sets[i];
            return Padding(
              padding: EdgeInsets.only(bottom: i < ex.sets.length - 1 ? 10 : 0),
              child: SetCard(
                key: ValueKey('set_${widget.exerciseIdx}_$i'),
                set: set,
                onWeightChanged: (v) => _weights[i] = v,
                onRepsChanged:   (v) => _reps[i]    = v,
                onRpeChanged:    (v) => _rpes[i]     = v,
                onComplete: () {
                  ref.read(workoutProvider.notifier).logSet(
                    exerciseIdx: widget.exerciseIdx,
                    setIdx:      i,
                    reps:   _reps[i]    ?? set.targetReps   ?? 0,
                    weight: _weights[i] ?? set.targetWeight ?? 0.0,
                    rpe:    _rpes[i],
                  );
                  widget.onSetComplete(i);
                },
              ),
            );
          }),

          const SizedBox(height: 14),

          // ── Rest timer bar ──
          _RestBar(restSeconds: ex.restSeconds),

          // ── Cues ──
          if (ex.exercise.cues.isNotEmpty) ...[
            const SizedBox(height: 14),
            _CuesList(cues: ex.exercise.cues),
          ],
        ],
      ),
    );
  }
}

// ── Rest bar ──────────────────────────────────────────────
class _RestBar extends ConsumerWidget {
  const _RestBar({required this.restSeconds});
  final int restSeconds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rest = ref.watch(restTimerProvider);
    final isThisTimer = rest.isActive && rest.totalSeconds == restSeconds;

    final m = restSeconds ~/ 60;
    final s = restSeconds % 60;
    final label = '${m}:${s.toString().padLeft(2, '0')}';

    final l = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.accentDim,
        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
        border: Border.all(color: AppColors.accent.withAlpha(51)),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined, color: AppColors.accent, size: 16),
          const SizedBox(width: 8),
          Text(
            '${l.rest}  $label',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.accent,
              letterSpacing: 0.8,
            ),
          ),
          const Spacer(),
          Text(
            isThisTimer ? l.running : l.tapToStart,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: context.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Cues list ─────────────────────────────────────────────
class _CuesList extends StatelessWidget {
  const _CuesList({required this.cues});
  final List<String> cues;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.techniqueCues,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: context.tertiaryText,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        ...cues.map((cue) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w900)),
              Expanded(
                child: Text(
                  cue,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: context.secondaryText,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}

// ── Rest overlay ──────────────────────────────────────────
class _RestOverlay extends StatelessWidget {
  const _RestOverlay({required this.state, required this.onSkip});

  final RestTimerState state;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return AnimatedOpacity(
      opacity: state.isActive ? 1 : 0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        color: context.bg.withAlpha(242),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l.rest,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: AppTypeScale.labelLg,
                  fontWeight: FontWeight.w700,
                  color: context.secondaryText,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                state.formattedTime,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: AppTypeScale.timer,
                  fontWeight: FontWeight.w900,
                  color: AppColors.accent,
                  letterSpacing: -3,
                  height: 1,
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true))
                  .shimmer(duration: 2000.ms, color: AppColors.accent.withAlpha(200)),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l.secondsRemaining,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: AppTypeScale.labelLg,
                  color: context.tertiaryText,
                ),
              ),
              const SizedBox(height: AppSpacing.base),
              SizedBox(
                width: 160,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                  child: LinearProgressIndicator(
                    value: state.progress,
                    minHeight: 6,
                    backgroundColor: context.surface3,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              TextButton(
                onPressed: onSkip,
                style: TextButton.styleFrom(
                  backgroundColor: context.surface,
                  side: BorderSide(color: context.surface3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: AppSpacing.md),
                ),
                child: Text(
                  l.skipRest,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: AppTypeScale.labelLg,
                    fontWeight: FontWeight.w700,
                    color: context.secondaryText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Bottom nav ────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.canGoPrev,
    required this.canGoNext,
    required this.onPrev,
    required this.onNext,
  });

  final bool canGoPrev;
  final bool canGoNext;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: context.surface,
        border: Border(top: BorderSide(color: context.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: FpButton(
              label: AppLocalizations.of(context)!.previous,
              variant: FpButtonVariant.secondary,
              size: FpButtonSize.medium,
              onPressed: canGoPrev ? onPrev : null,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: FpButton(
              label: AppLocalizations.of(context)!.next,
              size: FpButtonSize.medium,
              onPressed: canGoNext ? onNext : null,
            ),
          ),
        ],
      ),
    );
  }
}

