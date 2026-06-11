import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:flexpro_coaching/l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/fp_card.dart';
import '../../workout/data/firestore_workout_repository.dart';
import '../../workout/domain/workout_log_model.dart';
import '../data/body_weight_repository.dart';
import '../domain/body_weight_model.dart';

// ── Main screen ───────────────────────────────────────────

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  int _rangeSel = 1; // 0=1M 1=3M 2=1Y

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Duration get _rangeWindow => switch (_rangeSel) {
        0 => const Duration(days: 30),
        1 => const Duration(days: 90),
        _ => const Duration(days: 365),
      };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final allLogs = ref.watch(workoutHistoryStreamProvider).valueOrNull ?? [];
    final weights = ref.watch(bodyWeightProvider).valueOrNull ?? [];
    final cutoff = DateTime.now().subtract(_rangeWindow);
    final logs =
        allLogs.where((lg) => lg.startedAt.isAfter(cutoff)).toList();

    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.base, 14, AppSpacing.base, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l.progressTitle,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: AppTypeScale.displayMd,
                        fontWeight: FontWeight.w900,
                        color: context.primaryText,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  // Range selector only visible on Training + Exercise tabs
                  if (_tab.index < 2)
                    Row(
                      children: ['1M', '3M', '1Y'].asMap().entries.map((e) {
                        final isActive = _rangeSel == e.key;
                        return Padding(
                          padding: EdgeInsets.only(left: e.key > 0 ? 6 : 0),
                          child: GestureDetector(
                            onTap: () => setState(() => _rangeSel = e.key),
                            child: AnimatedContainer(
                              duration: AppDuration.fast,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppColors.accentDim
                                    : Colors.transparent,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.sm),
                                border: Border.all(
                                  color: isActive
                                      ? AppColors.accent
                                      : context.border,
                                ),
                              ),
                              child: Text(
                                e.value,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: AppTypeScale.labelMd,
                                  fontWeight: FontWeight.w700,
                                  color: isActive
                                      ? AppColors.accent
                                      : context.secondaryText,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms),

            // ── Segmented tab bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.base, 14, AppSpacing.base, 0),
              child: _SegmentedTabBar(
                controller: _tab,
                labels: [
                  l.progressTabTraining,
                  l.progressTabExercise,
                  l.progressTabBody,
                ],
              ),
            ).animate(delay: 40.ms).fadeIn(duration: 300.ms),

            // ── Tab content ──
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [
                  _TrainingTab(logs: logs),
                  _ExerciseTab(allLogs: allLogs, logs: logs),
                  _BodyTab(weights: weights),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Segmented tab bar ─────────────────────────────────────

class _SegmentedTabBar extends StatelessWidget {
  const _SegmentedTabBar({required this.controller, required this.labels});
  final TabController controller;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(AppRadius.sm + 3),
          border: Border.all(color: context.border),
        ),
        child: Row(
          children: labels.asMap().entries.map((e) {
            final isActive = controller.index == e.key;
            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => controller.animateTo(e.key),
                child: AnimatedContainer(
                  duration: AppDuration.fast,
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.accent : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    e.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: AppTypeScale.labelLg,
                      fontWeight: FontWeight.w700,
                      color: isActive ? Colors.black : context.secondaryText,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ── Tab 1: Training ───────────────────────────────────────

class _TrainingTab extends StatelessWidget {
  const _TrainingTab({required this.logs});
  final List<WorkoutLog> logs;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.base, AppSpacing.base,
              AppSpacing.base, AppSpacing.sm),
          sliver: SliverToBoxAdapter(
            child: _SummaryRow(logs: logs)
                .animate(delay: 60.ms)
                .fadeIn(duration: 300.ms),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.base, 0, AppSpacing.base, AppSpacing.sm),
          sliver: SliverToBoxAdapter(
            child: _BarChartCard(
              title: l.weeklyVolume,
              subtitle: l.weeklyVolumeSubtitle,
              bars: _weeklyVolume(logs),
              formatValue: (v) {
                if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}t';
                return '${v.toStringAsFixed(0)}kg';
              },
              emptyMessage: l.noVolumeData,
            )
                .animate(delay: 100.ms)
                .fadeIn()
                .slideY(begin: 0.06, curve: Curves.easeOut),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.base, 0, AppSpacing.base, AppSpacing.sm),
          sliver: SliverToBoxAdapter(
            child: _BarChartCard(
              title: l.workoutFrequency,
              subtitle: l.workoutFrequencySubtitle,
              bars: _weeklyWorkouts(logs),
              formatValue: (v) => v.toStringAsFixed(0),
              emptyMessage: l.noFrequencyData,
              accentBars: true,
            )
                .animate(delay: 140.ms)
                .fadeIn()
                .slideY(begin: 0.06, curve: Curves.easeOut),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.base, 0, AppSpacing.base, 100),
          sliver: SliverToBoxAdapter(
            child: _SessionTimeline(logs: logs)
                .animate(delay: 180.ms)
                .fadeIn(duration: 300.ms),
          ),
        ),
      ],
    );
  }

  List<_Bar> _weeklyVolume(List<WorkoutLog> ls) {
    if (ls.isEmpty) return [];
    final map = <String, double>{};
    for (final log in ls) {
      final key = _weekKey(log.startedAt);
      map[key] = (map[key] ?? 0) + log.totalVolume;
    }
    return _sortedBars(map);
  }

  List<_Bar> _weeklyWorkouts(List<WorkoutLog> ls) {
    if (ls.isEmpty) return [];
    final map = <String, double>{};
    for (final log in ls) {
      final key = _weekKey(log.startedAt);
      map[key] = (map[key] ?? 0) + 1;
    }
    return _sortedBars(map);
  }

  String _weekKey(DateTime d) {
    final monday = d.subtract(Duration(days: d.weekday - 1));
    return DateFormat('MM/dd').format(monday);
  }

  List<_Bar> _sortedBars(Map<String, double> map) {
    final entries = map.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return entries.map((e) => _Bar(label: e.key, value: e.value)).toList();
  }
}

// ── Tab 2: Exercise History ───────────────────────────────

class _ExerciseTab extends StatefulWidget {
  const _ExerciseTab({required this.allLogs, required this.logs});
  final List<WorkoutLog> allLogs;
  final List<WorkoutLog> logs;

  @override
  State<_ExerciseTab> createState() => _ExerciseTabState();
}

class _ExerciseTabState extends State<_ExerciseTab> {
  String? _selectedId;

  Map<String, String> get _allExercises {
    final map = <String, String>{};
    for (final log in widget.allLogs) {
      for (final ex in log.exercises) {
        map[ex.exerciseId] = ex.exerciseName;
      }
    }
    return map;
  }

  List<_ExPoint> _progression(String id) {
    final points = <_ExPoint>[];
    final sorted = [...widget.logs]
      ..sort((a, b) => a.startedAt.compareTo(b.startedAt));
    for (final log in sorted) {
      for (final ex in log.exercises) {
        if (ex.exerciseId == id && ex.sets.isNotEmpty) {
          final best =
              ex.sets.fold(0.0, (m, s) => s.weight > m ? s.weight : m);
          points.add(_ExPoint(date: log.startedAt, weightKg: best));
        }
      }
    }
    return points;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final exercises = _allExercises;
    final noSelection = exercises.isEmpty || _selectedId == null;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.base, AppSpacing.base,
              AppSpacing.base, AppSpacing.sm),
          sliver: SliverToBoxAdapter(
            child: _ExercisePicker(
              exercises: exercises,
              selectedId: _selectedId,
              onSelect: (id) =>
                  setState(() => _selectedId = _selectedId == id ? null : id),
            ).animate(delay: 60.ms).fadeIn(duration: 300.ms),
          ),
        ),
        if (noSelection)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.base, 0, AppSpacing.base, 100),
            sliver: SliverToBoxAdapter(
              child: _ExerciseEmptyState(
                message: exercises.isEmpty ? l.noExerciseData : l.selectExercise,
              ).animate(delay: 80.ms).fadeIn(),
            ),
          )
        else ...[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.base, 0, AppSpacing.base, AppSpacing.sm),
            sliver: SliverToBoxAdapter(
              child: _ExerciseProgressCard(
                name: exercises[_selectedId!]!,
                points: _progression(_selectedId!),
              )
                  .animate(delay: 80.ms)
                  .fadeIn()
                  .slideY(begin: 0.06, curve: Curves.easeOut),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.base, 0, AppSpacing.base, 100),
            sliver: SliverToBoxAdapter(
              child: _ExercisePRCard(
                allLogs: widget.allLogs,
                selectedId: _selectedId!,
              ).animate(delay: 120.ms).fadeIn(duration: 300.ms),
            ),
          ),
        ],
      ],
    );
  }
}

// ── Tab 3: Body Metrics ───────────────────────────────────

class _BodyTab extends StatelessWidget {
  const _BodyTab({required this.weights});
  final List<BodyWeightEntry> weights;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.base, AppSpacing.base, AppSpacing.base, 100),
          sliver: SliverToBoxAdapter(
            child: _BodyWeightSection(entries: weights)
                .animate(delay: 60.ms)
                .fadeIn(duration: 300.ms),
          ),
        ),
      ],
    );
  }
}

// ── Shared data models ────────────────────────────────────

class _Bar {
  const _Bar({required this.label, required this.value});
  final String label;
  final double value;
}

class _ExPoint {
  const _ExPoint({required this.date, required this.weightKg});
  final DateTime date;
  final double weightKg;
}

// ── Summary row ───────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.logs});
  final List<WorkoutLog> logs;

  @override
  Widget build(BuildContext context) {
    final totalVolume = logs.fold(0.0, (s, l) => s + l.totalVolume);
    final avgDuration = logs.isEmpty
        ? 0
        : logs.fold(0, (s, l) => s + l.duration.inMinutes) ~/ logs.length;

    String fmtVol(double v) {
      if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}Mt';
      if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}t';
      return '${v.toStringAsFixed(0)}kg';
    }

    final l = AppLocalizations.of(context)!;
    return Row(
      children: [
        _SumCard(value: '${logs.length}', label: l.sessions),
        const SizedBox(width: 10),
        _SumCard(value: fmtVol(totalVolume), label: l.volume),
        const SizedBox(width: 10),
        _SumCard(value: '${avgDuration}min', label: l.avgDuration),
      ],
    );
  }
}

class _SumCard extends StatelessWidget {
  const _SumCard({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FpCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.accent,
                )),
            const SizedBox(height: 2),
            Text(label.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: context.tertiaryText,
                  letterSpacing: 0.5,
                )),
          ],
        ),
      ),
    );
  }
}

// ── Bar chart card ────────────────────────────────────────

class _BarChartCard extends StatelessWidget {
  const _BarChartCard({
    required this.title,
    required this.subtitle,
    required this.bars,
    required this.formatValue,
    required this.emptyMessage,
    this.accentBars = false,
  });

  final String title;
  final String subtitle;
  final List<_Bar> bars;
  final String Function(double) formatValue;
  final String emptyMessage;
  final bool accentBars;

  @override
  Widget build(BuildContext context) {
    final maxVal = bars.isEmpty
        ? 1.0
        : bars.map((b) => b.value).reduce((a, b) => a > b ? a : b);
    final latest = bars.isEmpty ? null : bars.last;

    return FpCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: context.primaryText,
                        )),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: context.secondaryText,
                        )),
                  ],
                ),
              ),
              if (latest != null)
                Text(
                  formatValue(latest.value),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.accent,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          if (bars.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(emptyMessage,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: context.tertiaryText,
                    )),
              ),
            )
          else ...[
            SizedBox(
              height: 90,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: bars.asMap().entries.map((e) {
                  final isLast = e.key == bars.length - 1;
                  final frac = maxVal == 0
                      ? 0.05
                      : (e.value.value / maxVal).clamp(0.05, 1.0);
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                          right: e.key < bars.length - 1 ? 3 : 0),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: frac),
                        duration: Duration(milliseconds: 500 + e.key * 30),
                        curve: Curves.easeOutCubic,
                        builder: (_, v, __) => FractionallySizedBox(
                          alignment: Alignment.bottomCenter,
                          heightFactor: v,
                          child: Container(
                            decoration: BoxDecoration(
                              color: isLast
                                  ? AppColors.accent
                                  : accentBars
                                      ? AppColors.accent.withAlpha(77)
                                      : AppColors.accent.withAlpha(51),
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(3)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: bars
                  .map((b) => Expanded(
                        child: Text(b.label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 9,
                              color: context.tertiaryText,
                            )),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Session timeline ──────────────────────────────────────

class _SessionTimeline extends StatelessWidget {
  const _SessionTimeline({required this.logs});
  final List<WorkoutLog> logs;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final sorted = [...logs]
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Text(
            l.historyTitle,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: AppTypeScale.headSm,
              fontWeight: FontWeight.w800,
              color: context.primaryText,
            ),
          ),
        ),
        if (sorted.isEmpty)
          FpCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Column(
                children: [
                  Icon(Icons.fitness_center_outlined,
                      color: context.tertiaryText, size: 32),
                  const SizedBox(height: AppSpacing.sm),
                  Text(l.noWorkouts,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: AppTypeScale.bodySm,
                        color: context.tertiaryText,
                      )),
                ],
              ),
            ),
          )
        else
          ...sorted.map((log) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _SessionCard(log: log),
              )),
      ],
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.log});
  final WorkoutLog log;

  @override
  Widget build(BuildContext context) {
    return FpCard(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base, vertical: AppSpacing.md),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('d').format(log.startedAt),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.accent,
                  ),
                ),
                Text(
                  DateFormat('MMM').format(log.startedAt).toUpperCase(),
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
          Container(
            width: 1,
            height: 36,
            color: context.border,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.workoutName,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: AppTypeScale.bodySm,
                    fontWeight: FontWeight.w700,
                    color: context.primaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(Icons.timer_outlined,
                        size: 11, color: context.tertiaryText),
                    const SizedBox(width: 3),
                    Text(log.formattedDuration,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: AppTypeScale.labelSm,
                          color: context.tertiaryText,
                        )),
                    const SizedBox(width: 10),
                    Icon(Icons.fitness_center_rounded,
                        size: 11, color: context.tertiaryText),
                    const SizedBox(width: 3),
                    Text(log.formattedVolume,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: AppTypeScale.labelSm,
                          color: context.tertiaryText,
                        )),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '${log.exercises.length}ex',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: AppTypeScale.labelMd,
              fontWeight: FontWeight.w600,
              color: context.tertiaryText,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Exercise picker ───────────────────────────────────────

class _ExercisePicker extends StatelessWidget {
  const _ExercisePicker({
    required this.exercises,
    required this.selectedId,
    required this.onSelect,
  });
  final Map<String, String> exercises;
  final String? selectedId;
  final void Function(String) onSelect;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.exerciseHistory,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: AppTypeScale.headSm,
            fontWeight: FontWeight.w800,
            color: context.primaryText,
          ),
        ),
        if (exercises.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: exercises.entries.map((e) {
                final isSelected = selectedId == e.key;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: GestureDetector(
                    onTap: () => onSelect(e.key),
                    child: AnimatedContainer(
                      duration: AppDuration.fast,
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.accentDim
                            : context.surface,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(
                          color: isSelected ? AppColors.accent : context.border,
                        ),
                      ),
                      child: Text(
                        e.value,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: AppTypeScale.bodySm,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppColors.accent
                              : context.secondaryText,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}

// ── Exercise empty state ──────────────────────────────────

class _ExerciseEmptyState extends StatelessWidget {
  const _ExerciseEmptyState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return FpCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Column(
          children: [
            Icon(Icons.show_chart_rounded,
                size: 36, color: context.tertiaryText),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: AppTypeScale.bodySm,
                color: context.tertiaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Exercise progression chart ────────────────────────────

class _ExerciseProgressCard extends StatelessWidget {
  const _ExerciseProgressCard({required this.name, required this.points});
  final String name;
  final List<_ExPoint> points;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    if (points.isEmpty) {
      return FpCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: AppTypeScale.headSm,
                  fontWeight: FontWeight.w800,
                  color: context.primaryText,
                )),
            const SizedBox(height: AppSpacing.base),
            Center(
              child: Text(l.noExerciseData,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: AppTypeScale.bodySm,
                    color: context.tertiaryText,
                  )),
            ),
          ],
        ),
      );
    }

    final capped =
        points.length > 10 ? points.sublist(points.length - 10) : points;
    final maxW =
        capped.map((p) => p.weightKg).reduce((a, b) => a > b ? a : b);
    final minW =
        capped.map((p) => p.weightKg).reduce((a, b) => a < b ? a : b);
    final range = (maxW - minW).clamp(1.0, double.infinity);
    final latest = capped.last;

    return FpCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(name,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: AppTypeScale.headSm,
                      fontWeight: FontWeight.w800,
                      color: context.primaryText,
                    )),
              ),
              Text(
                '${latest.weightKg.toStringAsFixed(latest.weightKg % 1 == 0 ? 0 : 1)} kg',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 90,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: capped.asMap().entries.map((e) {
                final isLast = e.key == capped.length - 1;
                final frac =
                    ((e.value.weightKg - minW + range * 0.1) / (range * 1.1))
                        .clamp(0.05, 1.0);
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                        right: e.key < capped.length - 1 ? 3 : 0),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: frac),
                      duration: Duration(milliseconds: 400 + e.key * 40),
                      curve: Curves.easeOutCubic,
                      builder: (_, v, __) => FractionallySizedBox(
                        alignment: Alignment.bottomCenter,
                        heightFactor: v,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isLast
                                ? AppColors.accent
                                : AppColors.accent.withAlpha(51),
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(3)),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: capped
                .map((p) => Expanded(
                      child: Text(
                        DateFormat('M/d').format(p.date),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 9,
                          color: context.tertiaryText,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ── Exercise PR card ──────────────────────────────────────

class _ExercisePRCard extends StatelessWidget {
  const _ExercisePRCard({required this.allLogs, required this.selectedId});
  final List<WorkoutLog> allLogs;
  final String selectedId;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    double prWeight = 0;
    int prReps = 0;
    DateTime? prDate;

    for (final log in allLogs) {
      for (final ex in log.exercises) {
        if (ex.exerciseId == selectedId) {
          for (final set in ex.sets) {
            if (set.weight > prWeight) {
              prWeight = set.weight;
              prReps = set.reps;
              prDate = log.startedAt;
            }
          }
        }
      }
    }

    if (prWeight == 0) return const SizedBox.shrink();

    return FpCard(
      child: Row(
        children: [
          Icon(Icons.emoji_events_outlined,
              color: AppColors.warning, size: 24),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.personalRecords,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: AppTypeScale.labelMd,
                    fontWeight: FontWeight.w600,
                    color: context.tertiaryText,
                  ),
                ),
                Text(
                  '${prWeight.toStringAsFixed(prWeight % 1 == 0 ? 0 : 1)} kg  ×  $prReps',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: AppTypeScale.headSm,
                    fontWeight: FontWeight.w900,
                    color: context.primaryText,
                  ),
                ),
              ],
            ),
          ),
          if (prDate != null)
            Text(
              DateFormat('MMM d, yyyy').format(prDate!),
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: AppTypeScale.labelMd,
                color: context.tertiaryText,
              ),
            ),
        ],
      ),
    );
  }
}

// ── Body weight section ───────────────────────────────────

class _BodyWeightSection extends ConsumerStatefulWidget {
  const _BodyWeightSection({required this.entries});
  final List<BodyWeightEntry> entries;

  @override
  ConsumerState<_BodyWeightSection> createState() => _BodyWeightSectionState();
}

class _BodyWeightSectionState extends ConsumerState<_BodyWeightSection> {
  void _showLogModal() {
    final l = AppLocalizations.of(context)!;
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTheme.radiusXXL)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          24, 20, 24,
          MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.surface3,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l.logBodyWeight,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: context.primaryText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('EEEE, MMMM d').format(DateTime.now()),
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: context.secondaryText,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: ctrl,
              autofocus: true,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: context.primaryText,
              ),
              decoration: InputDecoration(
                hintText: '80.0',
                hintStyle: TextStyle(color: context.tertiaryText),
                suffixText: 'kg',
                suffixStyle: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: context.secondaryText,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.accent, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.border),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () async {
                  final val = double.tryParse(ctrl.text);
                  if (val == null || val <= 0) return;
                  HapticFeedback.mediumImpact();
                  await ref
                      .read(bodyWeightProvider.notifier)
                      .logWeight(val);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      l.save,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final entries = widget.entries;
    final latest = entries.isNotEmpty ? entries.last : null;
    final prev = entries.length >= 2 ? entries[entries.length - 2] : null;
    final delta =
        latest != null && prev != null ? latest.weightKg - prev.weightKg : null;

    final maxW = entries.isEmpty
        ? 1.0
        : entries.map((e) => e.weightKg).reduce((a, b) => a > b ? a : b);
    final minW = entries.isEmpty
        ? 0.0
        : entries.map((e) => e.weightKg).reduce((a, b) => a < b ? a : b);
    final range = (maxW - minW).clamp(1.0, double.infinity);
    final bars = entries.take(12).map((e) => _Bar(
          label: DateFormat('M/d').format(e.date),
          value: (e.weightKg - minW + range * 0.1) / (range * 1.1),
        )).toList();

    return FpCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.bodyWeight,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: context.primaryText,
                        )),
                    const SizedBox(height: 2),
                    Text(l.bodyWeightSubtitle,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: context.secondaryText,
                        )),
                  ],
                ),
              ),
              if (latest != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${latest.weightKg.toStringAsFixed(1)} kg',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.accent,
                      ),
                    ),
                    if (delta != null)
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: (delta <= 0
                                  ? AppColors.success
                                  : AppColors.danger)
                              .withAlpha(38),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(1)} kg',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: delta <= 0
                                ? AppColors.success
                                : AppColors.danger,
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 20),
          if (bars.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(l.logWeightPrompt,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: context.tertiaryText,
                    )),
              ),
            )
          else ...[
            SizedBox(
              height: 80,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: bars.asMap().entries.map((e) {
                  final isLast = e.key == bars.length - 1;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                          right: e.key < bars.length - 1 ? 3 : 0),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(
                            begin: 0, end: e.value.value.clamp(0.05, 1.0)),
                        duration:
                            Duration(milliseconds: 400 + e.key * 30),
                        curve: Curves.easeOutCubic,
                        builder: (_, v, __) => FractionallySizedBox(
                          alignment: Alignment.bottomCenter,
                          heightFactor: v,
                          child: Container(
                            decoration: BoxDecoration(
                              color: isLast
                                  ? AppColors.success
                                  : AppColors.success.withAlpha(51),
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(3)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: bars
                  .map((b) => Expanded(
                        child: Text(b.label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 9,
                              color: context.tertiaryText,
                            )),
                      ))
                  .toList(),
            ),
          ],
          const SizedBox(height: 14),
          GestureDetector(
            onTap: _showLogModal,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.accentDim,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.accent.withAlpha(77)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_rounded,
                      color: AppColors.accent, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    l.logWeight,
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
          ),
        ],
      ),
    );
  }
}
