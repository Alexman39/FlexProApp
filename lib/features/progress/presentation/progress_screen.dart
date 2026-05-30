import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/fp_card.dart';
import '../../workout/data/firestore_workout_repository.dart';
import '../../workout/domain/workout_log_model.dart';
import '../data/body_weight_repository.dart';
import '../domain/body_weight_model.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  int _rangeSel = 1; // 0=1M 1=3M 2=1Y

  Duration get _rangeWindow => switch (_rangeSel) {
        0 => const Duration(days: 30),
        1 => const Duration(days: 90),
        _ => const Duration(days: 365),
      };

  @override
  Widget build(BuildContext context) {
    final allLogs = ref.watch(workoutHistoryStreamProvider).valueOrNull ?? [];
    final weights = ref.watch(bodyWeightProvider).valueOrNull ?? [];
    final cutoff  = DateTime.now().subtract(_rangeWindow);
    final logs    = allLogs.where((l) => l.startedAt.isAfter(cutoff)).toList();

    final weeklyVolume   = _weeklyVolume(logs);
    final weeklyWorkouts = _weeklyWorkouts(logs);
    final prs            = _topPRs(allLogs);

    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Progress',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: context.primaryText,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    Row(
                      children: ['1M', '3M', '1Y'].asMap().entries.map((e) {
                        final isActive = _rangeSel == e.key;
                        return Padding(
                          padding: EdgeInsets.only(left: e.key > 0 ? 8 : 0),
                          child: GestureDetector(
                            onTap: () => setState(() => _rangeSel = e.key),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppColors.accentDim
                                    : context.surface,
                                borderRadius: BorderRadius.circular(10),
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
                                  fontSize: 12,
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
            ),

            // ── Summary stats ──
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              sliver: SliverToBoxAdapter(
                child: _SummaryRow(logs: logs)
                    .animate(delay: 60.ms)
                    .fadeIn(duration: 300.ms),
              ),
            ),

            // ── Weekly volume chart ──
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              sliver: SliverToBoxAdapter(
                child: _BarChartCard(
                  title: 'Weekly Volume',
                  subtitle: 'Total weight lifted per week (kg)',
                  bars: weeklyVolume,
                  formatValue: (v) {
                    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}t';
                    return '${v.toStringAsFixed(0)}kg';
                  },
                  emptyMessage: 'Complete workouts to see volume data',
                ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.06, curve: Curves.easeOut),
              ),
            ),

            // ── Workout frequency chart ──
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              sliver: SliverToBoxAdapter(
                child: _BarChartCard(
                  title: 'Workout Frequency',
                  subtitle: 'Sessions completed per week',
                  bars: weeklyWorkouts,
                  formatValue: (v) => v.toStringAsFixed(0),
                  emptyMessage: 'Complete workouts to see frequency data',
                  accentBars: true,
                ).animate(delay: 140.ms).fadeIn().slideY(begin: 0.06, curve: Curves.easeOut),
              ),
            ),

            // ── Personal records ──
            if (prs.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                sliver: SliverToBoxAdapter(
                  child: _PRSection(prs: prs)
                      .animate(delay: 180.ms)
                      .fadeIn(duration: 300.ms),
                ),
              ),

            // ── Body weight ──
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverToBoxAdapter(
                child: _BodyWeightSection(entries: weights)
                    .animate(delay: 220.ms)
                    .fadeIn(duration: 300.ms),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Data helpers ─────────────────────────────────────────

  List<_Bar> _weeklyVolume(List<WorkoutLog> logs) {
    if (logs.isEmpty) return [];
    final map = <String, double>{};
    for (final log in logs) {
      final key = _weekKey(log.startedAt);
      map[key] = (map[key] ?? 0) + log.totalVolume;
    }
    return _sortedBars(map);
  }

  List<_Bar> _weeklyWorkouts(List<WorkoutLog> logs) {
    if (logs.isEmpty) return [];
    final map = <String, double>{};
    for (final log in logs) {
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

  List<_PR> _topPRs(List<WorkoutLog> allLogs) {
    final bests = <String, double>{};
    final names = <String, String>{};
    for (final log in allLogs) {
      for (final ex in log.exercises) {
        final best = ex.sets.fold(0.0, (m, s) => s.weight > m ? s.weight : m);
        if (best > (bests[ex.exerciseId] ?? 0)) {
          bests[ex.exerciseId] = best;
          names[ex.exerciseId] = ex.exerciseName;
        }
      }
    }
    final sorted = bests.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted
        .take(6)
        .map((e) => _PR(name: names[e.key]!, weightKg: e.value))
        .toList();
  }
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

    return Row(
      children: [
        _SumCard(value: '${logs.length}',  label: 'Sessions'),
        const SizedBox(width: 10),
        _SumCard(value: fmtVol(totalVolume), label: 'Volume'),
        const SizedBox(width: 10),
        _SumCard(value: '${avgDuration}min', label: 'Avg Duration'),
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
class _Bar {
  const _Bar({required this.label, required this.value});
  final String label;
  final double value;
}

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
    final maxVal = bars.isEmpty ? 1.0 : bars.map((b) => b.value).reduce((a, b) => a > b ? a : b);
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
                child: Text(
                  emptyMessage,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: context.tertiaryText,
                  ),
                ),
              ),
            )
          else ...[
            SizedBox(
              height: 90,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: bars.asMap().entries.map((e) {
                  final isLast = e.key == bars.length - 1;
                  final frac = maxVal == 0 ? 0.05 : (e.value.value / maxVal).clamp(0.05, 1.0);
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: e.key < bars.length - 1 ? 3 : 0),
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
                                top: Radius.circular(3),
                              ),
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
              children: bars.map((b) => Expanded(
                child: Text(
                  b.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 9,
                    color: context.tertiaryText,
                  ),
                ),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Personal records ──────────────────────────────────────
class _PR {
  const _PR({required this.name, required this.weightKg});
  final String name;
  final double weightKg;
}

class _PRSection extends StatelessWidget {
  const _PRSection({required this.prs});
  final List<_PR> prs;

  @override
  Widget build(BuildContext context) {
    return FpCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🏆', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                'Personal Records',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: context.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...prs.asMap().entries.map((e) {
            final isLast = e.key == prs.length - 1;
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        e.value.name,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: context.primaryText,
                        ),
                      ),
                    ),
                    Text(
                      '${e.value.weightKg.toStringAsFixed(e.value.weightKg % 1 == 0 ? 0 : 1)} kg',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
                if (!isLast)
                  Divider(
                    height: 16,
                    thickness: 1,
                    color: context.border,
                  ),
              ],
            );
          }),
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
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXXL)),
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
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: context.surface3,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Log Body Weight',
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
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                  borderSide: const BorderSide(color: AppColors.accent, width: 2),
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
                  await ref.read(bodyWeightProvider.notifier).logWeight(val);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text(
                      'Save',
                      style: TextStyle(
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
    final entries = widget.entries;
    final latest  = entries.isNotEmpty ? entries.last : null;
    final prev    = entries.length >= 2 ? entries[entries.length - 2] : null;
    final delta   = latest != null && prev != null
        ? latest.weightKg - prev.weightKg
        : null;

    // Normalize for chart
    final maxW = entries.isEmpty ? 1.0 : entries.map((e) => e.weightKg).reduce((a, b) => a > b ? a : b);
    final minW = entries.isEmpty ? 0.0 : entries.map((e) => e.weightKg).reduce((a, b) => a < b ? a : b);
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
                    Text(
                      'Body Weight',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: context.primaryText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Track your weight over time',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: context.secondaryText,
                      ),
                    ),
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
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: (delta <= 0 ? AppColors.success : AppColors.danger).withAlpha(38),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(1)} kg',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: delta <= 0 ? AppColors.success : AppColors.danger,
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
                child: Text(
                  'Tap + Log Weight to start tracking',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: context.tertiaryText,
                  ),
                ),
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
                      padding: EdgeInsets.only(right: e.key < bars.length - 1 ? 3 : 0),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: e.value.value.clamp(0.05, 1.0)),
                        duration: Duration(milliseconds: 400 + e.key * 30),
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
              children: bars.map((b) => Expanded(
                child: Text(
                  b.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 9,
                    color: context.tertiaryText,
                  ),
                ),
              )).toList(),
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
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_rounded, color: AppColors.accent, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Log Weight',
                    style: TextStyle(
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
