import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/fp_button.dart';
import '../../../shared/widgets/fp_card.dart';
import '../domain/models.dart';
import '../providers/workout_provider.dart';

/// Entry point in the shell nav — shows today's scheduled workout.
class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Workout',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: context.primaryText,
                  letterSpacing: -0.5,
                ),
              ).animate().fadeIn(duration: 300.ms),
              const SizedBox(height: 20),
              FpCard(
                gradient: AppColors.heroCardGradient,
                borderColor: AppColors.accent.withAlpha(51),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '7 exercises  ·  ~52 min  ·  21 sets',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: Colors.white.withAlpha(153),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FpButton(
                      label: 'Start Workout',
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
      ref.read(workoutProvider.notifier).start();
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

  void _finishWorkout() {
    HapticFeedback.heavyImpact();
    ref.read(workoutProvider.notifier).finish();
    showModalBottomSheet(
      context: context,
      backgroundColor: context.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXXL)),
      ),
      builder: (_) => _WorkoutSummarySheet(
        onClose: () {
          Navigator.pop(context);
          context.go(AppRoutes.home);
        },
      ),
    );
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
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: context.surface,
                borderRadius: BorderRadius.circular(12),
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
              'Finish',
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
                      'EXERCISE ${widget.exerciseIdx + 1}',
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
              // Video thumb
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

          // ── Sets table ──
          _SetsTable(
            sets: ex.sets,
            onComplete: (i) {
              setState(() {
                ex.sets[i].status = SetStatus.completed;
              });
              widget.onSetComplete(i);
            },
          ),
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

// ── Sets table ────────────────────────────────────────────
class _SetsTable extends StatefulWidget {
  const _SetsTable({required this.sets, required this.onComplete});

  final List<WorkoutSet> sets;
  final void Function(int) onComplete;

  @override
  State<_SetsTable> createState() => _SetsTableState();
}

class _SetsTableState extends State<_SetsTable> {
  late final List<TextEditingController> _weightCtrl;
  late final List<TextEditingController> _repsCtrl;
  late final List<TextEditingController> _rpeCtrl;

  @override
  void initState() {
    super.initState();
    _weightCtrl = widget.sets.map((s) =>
      TextEditingController(text: s.loggedWeight?.toStringAsFixed(0) ??
          s.targetWeight?.toStringAsFixed(0) ?? '')).toList();
    _repsCtrl = widget.sets.map((s) =>
      TextEditingController(text: s.loggedReps?.toString() ??
          s.targetReps?.toString() ?? '')).toList();
    _rpeCtrl = widget.sets.map((s) =>
      TextEditingController(text: s.loggedRpe?.toString() ??
          s.rpe?.toString() ?? '')).toList();
  }

  @override
  void dispose() {
    for (final c in [..._weightCtrl, ..._repsCtrl, ..._rpeCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              _TH('SET', flex: 1),
              _TH('KG',  flex: 3),
              _TH('REPS',flex: 3),
              _TH('RPE', flex: 2),
              const SizedBox(width: 36),
            ],
          ),
        ),
        // Rows
        ...List.generate(widget.sets.length, (i) {
          final set = widget.sets[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: _SetNumBadge(
                    number: i + 1,
                    isDone: set.isDone,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: _MetricInput(
                    controller: _weightCtrl[i],
                    enabled: !set.isDone,
                    isDone: set.isDone,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  flex: 3,
                  child: _MetricInput(
                    controller: _repsCtrl[i],
                    enabled: !set.isDone,
                    isDone: set.isDone,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  flex: 2,
                  child: _RpeInput(
                    controller: _rpeCtrl[i],
                    isDone: set.isDone,
                  ),
                ),
                const SizedBox(width: 8),
                // Complete button
                GestureDetector(
                  onTap: set.isDone ? null : () {
                    HapticFeedback.mediumImpact();
                    setState(() => set.status = SetStatus.completed);
                    widget.onComplete(i);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 30, height: 30,
                    decoration: BoxDecoration(
                      color: set.isDone ? AppColors.success : context.surface2,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: set.isDone ? AppColors.success : context.border,
                      ),
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: set.isDone ? Colors.white : context.tertiaryText,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
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
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: context.tertiaryText,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _SetNumBadge extends StatelessWidget {
  const _SetNumBadge({required this.number, required this.isDone});
  final int number;
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 28, height: 28,
        decoration: BoxDecoration(
          color: isDone ? AppColors.accent : context.surface2,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            '$number',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: isDone ? Colors.black : context.secondaryText,
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricInput extends StatelessWidget {
  const _MetricInput({
    required this.controller,
    required this.enabled,
    required this.isDone,
  });
  final TextEditingController controller;
  final bool enabled;
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: isDone ? AppColors.accent : context.primaryText,
      ),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDone ? AppColors.accent.withAlpha(77) : context.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDone ? AppColors.accent.withAlpha(77) : context.border,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDone ? AppColors.accent.withAlpha(77) : context.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        filled: true,
        fillColor: isDone ? AppColors.accentDim : context.surface2,
      ),
    );
  }
}

class _RpeInput extends StatelessWidget {
  const _RpeInput({required this.controller, required this.isDone});
  final TextEditingController controller;
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isDone ? AppColors.accentDim : context.surface2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDone ? AppColors.accent.withAlpha(77) : context.border,
        ),
      ),
      child: Text(
        controller.text.isEmpty ? '—' : controller.text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: isDone ? AppColors.accent : context.secondaryText,
        ),
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
            'REST  $label',
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
            isThisTimer ? 'Running…' : 'Tap ✓ to start',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TECHNIQUE CUES',
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
    return AnimatedOpacity(
      opacity: state.isActive ? 1 : 0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        color: context.bg.withAlpha(242),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'REST',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFA0A0A0),
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.formattedTime,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 80,
                  fontWeight: FontWeight.w900,
                  color: AppColors.accent,
                  letterSpacing: -3,
                  height: 1,
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true))
                  .shimmer(duration: 2000.ms, color: AppColors.accent.withAlpha(200)),
              const SizedBox(height: 4),
              const Text(
                'seconds remaining',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: Color(0xFF606060),
                ),
              ),
              const SizedBox(height: 20),
              // Progress bar
              SizedBox(
                width: 160,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: state.progress,
                    minHeight: 6,
                    backgroundColor: const Color(0xFF2A2A2A),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              TextButton(
                onPressed: onSkip,
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1A1A),
                  side: const BorderSide(color: Color(0xFF2A2A2A)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text(
                  'Skip Rest',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFA0A0A0),
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
              label: '← Previous',
              variant: FpButtonVariant.secondary,
              size: FpButtonSize.medium,
              onPressed: canGoPrev ? onPrev : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FpButton(
              label: 'Next →',
              size: FpButtonSize.medium,
              onPressed: canGoNext ? onNext : null,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Workout summary sheet ─────────────────────────────────
class _WorkoutSummarySheet extends StatelessWidget {
  const _WorkoutSummarySheet({required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: context.surface3,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          const Text('🏆', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 12),
          Text(
            'Workout Complete!',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: context.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Great work! Rest well and fuel your body with clean nutrition.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: context.secondaryText,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          FpButton(label: 'Done', onPressed: onClose),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
