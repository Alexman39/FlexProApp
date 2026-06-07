import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/fp_card.dart';
import '../../onboarding/domain/onboarding_models.dart';
import '../../subscription/providers/subscription_provider.dart';
import '../data/programs_data.dart';
import '../domain/program_model.dart';
import '../providers/enrollment_provider.dart';

// ── Filter state ─────────────────────────────────────────
final _filterProvider = StateProvider<_ProgramFilter>((ref) => const _ProgramFilter());

class _ProgramFilter {
  const _ProgramFilter({this.level, this.goal, this.query = ''});

  final ExperienceLevel? level;
  final ProgramGoal?     goal;
  final String           query;

  _ProgramFilter copyWith({
    ExperienceLevel? level,
    ProgramGoal?     goal,
    String?          query,
    bool clearLevel  = false,
    bool clearGoal   = false,
  }) => _ProgramFilter(
    level: clearLevel ? null : (level ?? this.level),
    goal:  clearGoal  ? null : (goal  ?? this.goal),
    query: query ?? this.query,
  );
}

class ProgramsScreen extends ConsumerWidget {
  const ProgramsScreen({super.key});

  List<Program> _filtered(List<Program> all, _ProgramFilter f) {
    return all.where((p) {
      if (f.level != null && p.level != f.level) return false;
      if (f.goal  != null && p.goal  != f.goal)  return false;
      if (f.query.isNotEmpty &&
          !p.title.toLowerCase().contains(f.query.toLowerCase())) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter   = ref.watch(_filterProvider);
    final programs = _filtered(kAllPrograms, filter);

    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Fixed header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Column(
                children: [
                  // Title row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Programs',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: context.primaryText,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: context.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: context.border),
                        ),
                        child: const Icon(Icons.tune_rounded,
                            color: AppColors.accent, size: 20),
                      ),
                    ],
                  ).animate().fadeIn(duration: 300.ms),
                  const SizedBox(height: 14),

                  // Search
                  _SearchBar(
                    onChanged: (q) => ref
                        .read(_filterProvider.notifier)
                        .update((s) => s.copyWith(query: q)),
                  ).animate(delay: 60.ms).fadeIn(),
                  const SizedBox(height: 12),

                  // Filter chips
                  _FilterChips(
                    filter: filter,
                    onFilter: (f) => ref.read(_filterProvider.notifier).state = f,
                  ).animate(delay: 100.ms).fadeIn(),
                  const SizedBox(height: 4),
                ],
              ),
            ),

            // ── Scrollable list ──
            Expanded(
              child: programs.isEmpty
                  ? Center(
                      child: Text(
                        'No programs found.',
                        style: TextStyle(color: context.secondaryText),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                      physics: const BouncingScrollPhysics(),
                      itemCount: programs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, i) => _ProgramCard(
                        program: programs[i],
                      )
                          .animate(delay: Duration(milliseconds: i * 40))
                          .fadeIn(duration: 300.ms)
                          .slideY(begin: 0.06, curve: Curves.easeOut),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Search bar ────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onChanged});

  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
        border: Border.all(color: context.border),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: context.tertiaryText, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                color: context.primaryText,
              ),
              decoration: InputDecoration(
                hintText: 'Search programs...',
                hintStyle: TextStyle(color: context.tertiaryText),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Filter chips ──────────────────────────────────────────
class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.filter, required this.onFilter});

  final _ProgramFilter filter;
  final void Function(_ProgramFilter) onFilter;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _Chip(
            label: 'All',
            active: filter.level == null && filter.goal == null,
            onTap: () => onFilter(const _ProgramFilter()),
          ),
          const SizedBox(width: 8),
          _Chip(
            label: 'Beginner',
            active: filter.level == ExperienceLevel.beginner,
            onTap: () => onFilter(filter.copyWith(
              level: ExperienceLevel.beginner, clearGoal: false,
              clearLevel: filter.level == ExperienceLevel.beginner,
            )),
            activeColor: AppColors.beginnerColor,
          ),
          const SizedBox(width: 8),
          _Chip(
            label: 'Intermediate',
            active: filter.level == ExperienceLevel.intermediate,
            onTap: () => onFilter(filter.copyWith(
              level: ExperienceLevel.intermediate,
              clearLevel: filter.level == ExperienceLevel.intermediate,
            )),
            activeColor: AppColors.intermediateColor,
          ),
          const SizedBox(width: 8),
          _Chip(
            label: 'Advanced',
            active: filter.level == ExperienceLevel.advanced,
            onTap: () => onFilter(filter.copyWith(
              level: ExperienceLevel.advanced,
              clearLevel: filter.level == ExperienceLevel.advanced,
            )),
            activeColor: AppColors.advancedColor,
          ),
          const SizedBox(width: 8),
          _Chip(
            label: 'Hypertrophy',
            active: filter.goal == ProgramGoal.hypertrophy,
            onTap: () => onFilter(filter.copyWith(
              goal: ProgramGoal.hypertrophy,
              clearGoal: filter.goal == ProgramGoal.hypertrophy,
            )),
          ),
          const SizedBox(width: 8),
          _Chip(
            label: 'Strength',
            active: filter.goal == ProgramGoal.strength,
            onTap: () => onFilter(filter.copyWith(
              goal: ProgramGoal.strength,
              clearGoal: filter.goal == ProgramGoal.strength,
            )),
          ),
          const SizedBox(width: 8),
          _Chip(
            label: 'Fat Loss',
            active: filter.goal == ProgramGoal.fatLoss,
            onTap: () => onFilter(filter.copyWith(
              goal: ProgramGoal.fatLoss,
              clearGoal: filter.goal == ProgramGoal.fatLoss,
            )),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.active,
    required this.onTap,
    this.activeColor,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    final c = activeColor ?? AppColors.accent;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? c : context.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? c : context.border,
            width: active ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: active ? (active && activeColor == null ? Colors.black : Colors.black) : context.secondaryText,
          ),
        ),
      ),
    );
  }
}

// ── Program card ──────────────────────────────────────────
class _ProgramCard extends ConsumerWidget {
  const _ProgramCard({required this.program});

  final Program program;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enrollment = ref.watch(enrollmentProvider).valueOrNull;
    final isEnrolled = enrollment?.programId == program.id;
    final isPremium  = ref.watch(isPremiumProvider);
    final isLocked   = program.isPremium && !isPremium;

    final levelColor = switch (program.level) {
      ExperienceLevel.beginner     => AppColors.beginnerColor,
      ExperienceLevel.intermediate => AppColors.intermediateColor,
      ExperienceLevel.advanced     => AppColors.advancedColor,
    };

    final banner = program.bannerGradient ??
        [const Color(0xFF1A2A2E), const Color(0xFF0D1F24)];
    final accent = program.accentColor ?? AppColors.accent;

    return FpCard(
      padding: EdgeInsets.zero,
      borderRadius: AppTheme.radiusLG,
      child: Column(
        children: [
          // ── Banner ──
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLG)),
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: banner,
                ),
              ),
              child: Stack(
                children: [
                  // Accent glow
                  Positioned(
                    left: -20, top: -20,
                    child: Container(
                      width: 140, height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [accent.withAlpha(51), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                  // Level badge
                  Positioned(
                    top: 12, right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: levelColor.withAlpha(38),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: levelColor.withAlpha(77)),
                      ),
                      child: Text(
                        program.levelLabel.toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: levelColor,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                  // Featured badge
                  if (program.isTasosFeatured)
                    Positioned(
                      top: 12, left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '⭐ TASOS PICK',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  // Emoji + title
                  Positioned(
                    bottom: 12, left: 14,
                    child: Row(
                      children: [
                        Text(program.emoji,
                            style: const TextStyle(fontSize: 28)),
                        const SizedBox(width: 10),
                        Text(
                          program.title,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Body ──
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Meta row
                Row(
                  children: [
                    _Meta(icon: Icons.calendar_month_rounded,
                        label: '${program.durationWeeks} Weeks'),
                    const SizedBox(width: 16),
                    _Meta(icon: Icons.fitness_center_rounded,
                        label: '${program.daysPerWeek} Days/Week'),
                    const SizedBox(width: 16),
                    _Meta(icon: Icons.people_rounded,
                        label: program.formattedUsers),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: AppColors.warning, size: 14),
                        const SizedBox(width: 3),
                        Text(
                          program.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  program.description,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: context.secondaryText,
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (program.isPremium) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.accentDim,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: AppColors.accent.withAlpha(77)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lock_rounded,
                                color: AppColors.accent, size: 11),
                            SizedBox(width: 4),
                            Text(
                              'PREMIUM',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.accent,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                // ── Enroll / Unlock / Leave button ──
                GestureDetector(
                  onTap: () async {
                    HapticFeedback.mediumImpact();
                    if (isLocked) {
                      context.push(AppRoutes.paywall);
                      return;
                    }
                    if (isEnrolled) {
                      await ref.read(enrollmentProvider.notifier).unenroll();
                    } else {
                      await ref
                          .read(enrollmentProvider.notifier)
                          .enroll(program.id);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      color: isLocked
                          ? AppColors.accentDim
                          : isEnrolled
                              ? Colors.transparent
                              : AppColors.accent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isLocked
                            ? AppColors.accent.withAlpha(77)
                            : isEnrolled
                                ? context.border
                                : AppColors.accent,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isLocked
                              ? Icons.lock_open_rounded
                              : isEnrolled
                                  ? Icons.check_circle_rounded
                                  : Icons.play_arrow_rounded,
                          color: isLocked
                              ? AppColors.accent
                              : isEnrolled
                                  ? context.secondaryText
                                  : Colors.black,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isLocked
                              ? 'Unlock Program'
                              : isEnrolled
                                  ? 'Active Program'
                                  : 'Start Program',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: isLocked
                                ? AppColors.accent
                                : isEnrolled
                                    ? context.secondaryText
                                    : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.accent, size: 13),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: context.secondaryText,
          ),
        ),
      ],
    );
  }
}
