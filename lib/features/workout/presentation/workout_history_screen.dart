import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../data/workout_repository.dart';
import '../domain/workout_log_model.dart';

class WorkoutHistoryScreen extends ConsumerWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(workoutHistoryProvider);

    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: context.surface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.arrow_back_ios_rounded,
                          size: 16, color: context.primaryText),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Workout History',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: context.primaryText,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${logs.length} sessions',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: context.tertiaryText,
                    ),
                  ),
                ],
              ),
            ),

            // ── Summary stats ──
            if (logs.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Row(
                  children: [
                    _SummaryStat(
                        value: '${logs.length}', label: 'Total'),
                    const SizedBox(width: 10),
                    _SummaryStat(
                        value: _totalVolumeLabel(logs), label: 'Volume'),
                    const SizedBox(width: 10),
                    _SummaryStat(
                        value: _avgDurationLabel(logs), label: 'Avg Duration'),
                  ],
                ),
              ),

            // ── List ──
            Expanded(
              child: logs.isEmpty
                  ? _EmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      itemCount: logs.length,
                      itemBuilder: (context, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _LogCard(log: logs[i])
                            .animate(delay: (i * 30).ms)
                            .fadeIn(duration: 250.ms)
                            .slideY(begin: 0.05, curve: Curves.easeOut),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _totalVolumeLabel(List<WorkoutLog> logs) {
    final total = logs.fold(0.0, (sum, l) => sum + l.totalVolume);
    if (total >= 1000) return '${(total / 1000).toStringAsFixed(1)}t';
    return '${total.toStringAsFixed(0)}kg';
  }

  String _avgDurationLabel(List<WorkoutLog> logs) {
    final avg =
        logs.fold(0, (sum, l) => sum + l.duration.inMinutes) ~/ logs.length;
    return '${avg}min';
  }
}

// ── Summary stat card ─────────────────────────────────────
class _SummaryStat extends StatelessWidget {
  const _SummaryStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.border),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.accent,
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

// ── Log card ──────────────────────────────────────────────
class _LogCard extends ConsumerWidget {
  const _LogCard({required this.log});

  final WorkoutLog log;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateStr = DateFormat('EEE, MMM d').format(log.startedAt);
    final timeStr = DateFormat('h:mm a').format(log.startedAt);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date + duration
          Row(
            children: [
              Text(
                dateStr,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: context.tertiaryText,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 3, height: 3,
                decoration: BoxDecoration(
                  color: context.tertiaryText,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                timeStr,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: context.tertiaryText,
                ),
              ),
              const Spacer(),
              _Pill(log.formattedDuration, icon: Icons.timer_outlined),
            ],
          ),

          const SizedBox(height: 8),

          // Workout name
          Text(
            log.workoutName,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: context.primaryText,
              letterSpacing: -0.2,
            ),
          ),

          const SizedBox(height: 10),

          // Stats row
          Row(
            children: [
              _StatChip(
                icon: Icons.fitness_center_rounded,
                label: '${log.exercises.length} exercises',
              ),
              const SizedBox(width: 8),
              _StatChip(
                icon: Icons.check_circle_outline_rounded,
                label: '${log.totalSets} sets',
              ),
              const SizedBox(width: 8),
              _StatChip(
                icon: Icons.trending_up_rounded,
                label: log.formattedVolume,
                accent: true,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Exercise list preview
          ...log.exercises.take(3).map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Container(
                      width: 4, height: 4,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: context.tertiaryText,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(
                      e.exerciseName,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: context.secondaryText,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${e.sets.length} × ${e.bestSet.toStringAsFixed(0)}kg',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: context.tertiaryText,
                      ),
                    ),
                  ],
                ),
              )),

          if (log.exercises.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '+${log.exercises.length - 3} more exercises',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: context.tertiaryText,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.label, {required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: context.tertiaryText),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: context.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    this.accent = false,
  });

  final IconData icon;
  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final color = accent ? AppColors.accent : context.tertiaryText;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('📋', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            'No workouts yet',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: context.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete your first workout to see it here',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: context.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
