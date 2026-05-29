import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/exercise_model.dart';
import '../providers/exercise_providers.dart';

class ExerciseDetailScreen extends ConsumerWidget {
  const ExerciseDetailScreen({super.key, required this.exerciseId});

  final String exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercise = ref.watch(exerciseByIdProvider(exerciseId));

    if (exercise == null) {
      return Scaffold(
        backgroundColor: context.bg,
        body: const Center(child: Text('Exercise not found')),
      );
    }

    final isFav = ref.watch(
        favoritesProvider.select((s) => s.contains(exercise.id)));

    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── App bar ──
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
                        ),
                        child: Icon(Icons.arrow_back_ios_rounded,
                            size: 16, color: context.primaryText),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => ref
                          .read(favoritesProvider.notifier)
                          .toggle(exercise.id),
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: context.surface,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isFav
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_outline_rounded,
                          size: 18,
                          color:
                              isFav ? AppColors.accent : context.tertiaryText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Hero section ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category icon
                    Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.accent.withAlpha(40),
                            AppColors.accent.withAlpha(15),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                            color: AppColors.accent.withAlpha(60), width: 1),
                      ),
                      child: Center(
                        child: Text(
                          exercise.muscleCategory.emoji,
                          style: const TextStyle(fontSize: 30),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      exercise.name,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: context.primaryText,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Tags row
                    Wrap(
                      spacing: 8,
                      children: [
                        _Badge(
                          exercise.equipment.label,
                          color: AppColors.accent,
                        ),
                        _Badge(
                          exercise.category.label,
                          color: exercise.category == ExerciseCategory.compound
                              ? AppColors.success
                              : AppColors.warning,
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── Muscles ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _Section(
                  title: 'Muscles Worked',
                  child: Column(
                    children: [
                      _MuscleRow(
                        label: 'Primary',
                        muscles: [exercise.primaryMuscle.label],
                        color: AppColors.accent,
                      ),
                      if (exercise.secondaryMuscles.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _MuscleRow(
                          label: 'Secondary',
                          muscles: exercise.secondaryMuscles
                              .map((m) => m.label)
                              .toList(),
                          color: context.secondaryText,
                        ),
                      ],
                    ],
                  ),
                ),
              ).animate(delay: 60.ms).fadeIn(duration: 300.ms),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // ── Instructions ──
            if (exercise.instructions != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _Section(
                    title: 'How to Perform',
                    child: Text(
                      exercise.instructions!,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        height: 1.6,
                        color: context.secondaryText,
                      ),
                    ),
                  ),
                ).animate(delay: 100.ms).fadeIn(duration: 300.ms),
              ),

            if (exercise.instructions != null)
              const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // ── Coaching tips ──
            if (exercise.tips != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _Section(
                    title: "Tasos's Tip",
                    titleIcon: '💡',
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withAlpha(12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.accent.withAlpha(40)),
                      ),
                      child: Text(
                        exercise.tips!,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          height: 1.6,
                          color: context.primaryText,
                        ),
                      ),
                    ),
                  ),
                ).animate(delay: 140.ms).fadeIn(duration: 300.ms),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }
}

// ── Reusable widgets ──────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.child,
    this.titleIcon,
  });

  final String title;
  final Widget child;
  final String? titleIcon;

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              if (titleIcon != null) ...[
                Text(titleIcon!, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
              ],
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: context.tertiaryText,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _MuscleRow extends StatelessWidget {
  const _MuscleRow({
    required this.label,
    required this.muscles,
    required this.color,
  });

  final String label;
  final List<String> muscles;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: context.tertiaryText,
            ),
          ),
        ),
        Expanded(
          child: Wrap(
            spacing: 6,
            runSpacing: 4,
            children: muscles
                .map((m) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withAlpha(20),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        m,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.label, {required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
