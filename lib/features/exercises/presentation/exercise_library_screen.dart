import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/exercise_model.dart';
import '../providers/exercise_providers.dart';

class ExerciseLibraryScreen extends ConsumerStatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  ConsumerState<ExerciseLibraryScreen> createState() =>
      _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState
    extends ConsumerState<ExerciseLibraryScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exercises = ref.watch(filteredExercisesProvider);
    final filter = ref.watch(exerciseFilterProvider);

    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 36,
                      height: 36,
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
                    'Exercise Library',
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
                    '${exercises.length}',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: context.tertiaryText,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Search bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: context.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: context.border),
                ),
                child: TextField(
                  controller: _search,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    color: context.primaryText,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search exercises...',
                    hintStyle: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      color: context.tertiaryText,
                    ),
                    prefixIcon: Icon(Icons.search_rounded,
                        color: context.tertiaryText, size: 20),
                    suffixIcon: filter.query.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _search.clear();
                              ref
                                  .read(exerciseFilterProvider.notifier)
                                  .setQuery('');
                            },
                            child: Icon(Icons.close_rounded,
                                color: context.tertiaryText, size: 18),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                  onChanged: (v) =>
                      ref.read(exerciseFilterProvider.notifier).setQuery(v),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Muscle category filter chips ──
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _FilterChip(
                    label: 'All',
                    isSelected: filter.category == null,
                    onTap: () => ref
                        .read(exerciseFilterProvider.notifier)
                        .setCategory(null),
                  ),
                  const SizedBox(width: 8),
                  ...MuscleCategory.values.map((cat) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _FilterChip(
                          label: '${cat.emoji} ${cat.label}',
                          isSelected: filter.category == cat,
                          onTap: () => ref
                              .read(exerciseFilterProvider.notifier)
                              .setCategory(
                                  filter.category == cat ? null : cat),
                        ),
                      )),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // ── Equipment filter chips ──
            SizedBox(
              height: 34,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: Equipment.values.map((eq) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _FilterChip(
                        label: eq.label,
                        isSelected: filter.equipment == eq,
                        small: true,
                        onTap: () => ref
                            .read(exerciseFilterProvider.notifier)
                            .setEquipment(
                                filter.equipment == eq ? null : eq),
                      ),
                    )).toList(),
              ),
            ),

            const SizedBox(height: 10),

            // ── Exercise list ──
            Expanded(
              child: exercises.isEmpty
                  ? _EmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      itemCount: exercises.length,
                      itemBuilder: (context, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _ExerciseTile(exercise: exercises[i])
                            .animate(delay: (i * 15).ms)
                            .fadeIn(duration: 200.ms),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Filter chip ───────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.small = false,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool small;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
            horizontal: small ? 10 : 14, vertical: small ? 6 : 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withAlpha(26)
              : context.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.accent : context.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: small ? 11 : 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.accent : context.secondaryText,
          ),
        ),
      ),
    );
  }
}

// ── Exercise tile ─────────────────────────────────────────
class _ExerciseTile extends ConsumerWidget {
  const _ExerciseTile({required this.exercise});

  final ExerciseModel exercise;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav = ref.watch(
        favoritesProvider.select((s) => s.contains(exercise.id)));

    return GestureDetector(
      onTap: () =>
          context.push(AppRoutes.exerciseDetail.replaceFirst(':id', exercise.id)),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.border),
        ),
        child: Row(
          children: [
            // Muscle category icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.accentDim,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  exercise.muscleCategory.emoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Name + muscle + tags
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: context.primaryText,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    exercise.muscleDisplay,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: context.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _Tag(exercise.equipment.label),
                      const SizedBox(width: 6),
                      _Tag(
                        exercise.category.label,
                        color: exercise.category == ExerciseCategory.compound
                            ? AppColors.accent
                            : AppColors.warning,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Favorite button
            GestureDetector(
              onTap: () => ref
                  .read(favoritesProvider.notifier)
                  .toggle(exercise.id),
              child: Icon(
                isFav ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                color: isFav ? AppColors.accent : context.tertiaryText,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.label, {this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? context.tertiaryText;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: c,
          letterSpacing: 0.2,
        ),
      ),
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
          const Text('🔍', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            'No exercises found',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: context.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search or filter',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: context.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}
