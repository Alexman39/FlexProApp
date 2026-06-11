import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flexpro_coaching/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/fp_card.dart';
import '../../onboarding/domain/onboarding_models.dart';
import '../data/programs_data.dart';
import '../domain/enrollment_model.dart';
import '../domain/program_model.dart';
import '../providers/enrollment_provider.dart';

// ── Filter state ──────────────────────────────────────────
final _filterProvider = StateProvider<_ProgramFilter>(
    (_) => const _ProgramFilter());

class _ProgramFilter {
  const _ProgramFilter({this.level, this.goal, this.query = ''});

  final ExperienceLevel? level;
  final ProgramGoal? goal;
  final String query;

  _ProgramFilter copyWith({
    ExperienceLevel? level,
    ProgramGoal? goal,
    String? query,
    bool clearLevel = false,
    bool clearGoal = false,
  }) =>
      _ProgramFilter(
        level: clearLevel ? null : (level ?? this.level),
        goal: clearGoal ? null : (goal ?? this.goal),
        query: query ?? this.query,
      );
}

// ── Programs screen ───────────────────────────────────────
class ProgramsScreen extends ConsumerWidget {
  const ProgramsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final filter = ref.watch(_filterProvider);
    final enrollment = ref.watch(enrollmentProvider).valueOrNull;

    // Find the enrolled program (if any)
    Program? activeProgram;
    if (enrollment != null) {
      try {
        activeProgram =
            kAllPrograms.firstWhere((p) => p.id == enrollment.programId);
      } catch (_) {}
    }

    // Library = all programs excluding the active one, then filtered
    final library = kAllPrograms.where((p) {
      if (activeProgram != null && p.id == activeProgram.id) return false;
      if (filter.level != null && p.level != filter.level) return false;
      if (filter.goal != null && p.goal != filter.goal) return false;
      if (filter.query.isNotEmpty &&
          !p.title.toLowerCase().contains(filter.query.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Page title ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.base, AppSpacing.base, AppSpacing.base, 0),
                child: Text(
                  l.programsTitle,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: AppTypeScale.displayMd,
                    fontWeight: FontWeight.w900,
                    color: context.primaryText,
                    letterSpacing: -0.5,
                  ),
                ).animate().fadeIn(duration: 300.ms),
              ),
            ),

            // ── Active program hero / no-program banner ──
            if (activeProgram != null && enrollment != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.base, AppSpacing.md, AppSpacing.base, 0),
                  child: _ActiveProgramHero(
                    program: activeProgram!,
                    enrollment: enrollment,
                  )
                      .animate()
                      .fadeIn(duration: 350.ms)
                      .slideY(begin: 0.04, curve: Curves.easeOut),
                ),
              )
            else
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.base, AppSpacing.md, AppSpacing.base, 0),
                  child: _NoProgramBanner()
                      .animate()
                      .fadeIn(duration: 350.ms)
                      .slideY(begin: 0.04, curve: Curves.easeOut),
                ),
              ),

            // ── Search + filter chips ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.base, AppSpacing.md, AppSpacing.base, 0),
                child: Column(
                  children: [
                    _SearchBar(
                      onChanged: (q) => ref
                          .read(_filterProvider.notifier)
                          .update((s) => s.copyWith(query: q)),
                    ).animate(delay: 60.ms).fadeIn(),
                    const SizedBox(height: AppSpacing.sm),
                    _FilterChips(
                      filter: filter,
                      onFilter: (f) =>
                          ref.read(_filterProvider.notifier).state = f,
                    ).animate(delay: 100.ms).fadeIn(),
                  ],
                ),
              ),
            ),

            // ── Library section header ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.base, AppSpacing.lg, AppSpacing.base, 0),
                child: FpSectionHeader(
                  title: l.programLibrary,
                ).animate(delay: 120.ms).fadeIn(),
              ),
            ),

            // ── Library list ──
            if (library.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xl, horizontal: AppSpacing.base),
                  child: Center(
                    child: Text(
                      l.noProgramsFound,
                      style: TextStyle(color: context.secondaryText),
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.base, 0, AppSpacing.base, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final isLast = i == library.length - 1;
                      return Padding(
                        padding: EdgeInsets.only(
                            bottom: isLast ? 0 : AppSpacing.md),
                        child: _ProgramLibraryCard(program: library[i])
                            .animate(
                              delay: Duration(milliseconds: 140 + i * 40))
                            .fadeIn(duration: 300.ms)
                            .slideY(begin: 0.06, curve: Curves.easeOut),
                      );
                    },
                    childCount: library.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── No program banner ─────────────────────────────────────
class _NoProgramBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return FpCard(
      padding: const EdgeInsets.all(AppSpacing.base),
      borderColor: AppColors.accent.withAlpha(30),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.accentDim,
              borderRadius: BorderRadius.circular(AppTheme.radiusSM),
              border: Border.all(color: AppColors.accent.withAlpha(60)),
            ),
            child: const Center(
              child: Icon(
                Icons.add_circle_outline_rounded,
                color: AppColors.accent,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.noActiveProgram,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: AppTypeScale.labelLg,
                    fontWeight: FontWeight.w700,
                    color: context.primaryText,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l.noActiveProgramHint,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: AppTypeScale.bodySm,
                    color: context.secondaryText,
                    height: 1.4,
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

// ── Active program hero card ──────────────────────────────
class _ActiveProgramHero extends StatelessWidget {
  const _ActiveProgramHero({
    required this.program,
    required this.enrollment,
  });

  final Program program;
  final ProgramEnrollment enrollment;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    const accent = AppColors.accent;

    return FpCard(
      padding: EdgeInsets.zero,
      borderRadius: AppTheme.radiusLG,
      borderColor: accent.withAlpha(77),
      onTap: () => context.push('/programs/${program.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label row
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.base, AppSpacing.md, AppSpacing.base, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: 3),
              decoration: BoxDecoration(
                color: accent.withAlpha(25),
                borderRadius: BorderRadius.circular(AppTheme.radiusXS),
                border: Border.all(color: accent.withAlpha(77)),
              ),
              child: Text(
                l.activeProgramLabel,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: accent,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Gradient banner strip
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusSM),
              child: Container(
                height: 88,
                decoration: const BoxDecoration(
                  gradient: AppColors.heroCardGradient,
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: -20,
                      top: -20,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              accent.withAlpha(51),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md, vertical: AppSpacing.md),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(Icons.fitness_center_rounded,
                              color: AppColors.accent, size: 26),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  program.title,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  program.subtitle,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    color: Colors.white.withAlpha(179),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Progress pills
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
            child: Row(
              children: [
                _ProgressPill(
                  label: '${l.weekLabel} ${enrollment.currentWeek + 1}',
                  icon: Icons.calendar_month_rounded,
                  color: accent,
                ),
                const SizedBox(width: AppSpacing.sm),
                _ProgressPill(
                  label: '${l.dayLabel} ${enrollment.currentDay + 1}',
                  icon: Icons.today_rounded,
                  color: accent,
                ),
                const SizedBox(width: AppSpacing.sm),
                _ProgressPill(
                  label: '${enrollment.totalSessions} ${l.sessions}',
                  icon: Icons.check_circle_outline_rounded,
                  color: AppColors.success,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // View program CTA
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.base, 0, AppSpacing.base, AppSpacing.base),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: accent.withAlpha(25),
                borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                border: Border.all(color: accent.withAlpha(64)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l.viewProgram,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: accent,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.arrow_forward_rounded, color: accent, size: 14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Progress pill ─────────────────────────────────────────
class _ProgressPill extends StatelessWidget {
  const _ProgressPill({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: 5),
      decoration: BoxDecoration(
        color: context.surface2,
        borderRadius: BorderRadius.circular(AppTheme.radiusXS),
        border: Border.all(color: context.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: context.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Program library card ──────────────────────────────────
class _ProgramLibraryCard extends ConsumerWidget {
  const _ProgramLibraryCard({required this.program});

  final Program program;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enrollment = ref.watch(enrollmentProvider).valueOrNull;
    final isEnrolled = enrollment?.programId == program.id;

    final levelColor = switch (program.level) {
      ExperienceLevel.beginner => AppColors.beginnerColor,
      ExperienceLevel.intermediate => AppColors.intermediateColor,
      ExperienceLevel.advanced => AppColors.advancedColor,
    };

    return FpCard(
      padding: EdgeInsets.zero,
      borderRadius: AppTheme.radiusLG,
      onTap: () => context.push('/programs/${program.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppTheme.radiusLG)),
            child: Container(
              height: 100,
              decoration: const BoxDecoration(
                gradient: AppColors.heroCardGradient,
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: -20,
                    top: -20,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.accentDim,
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: FpChip(
                      label: program.levelLabel,
                      color: levelColor,
                      small: true,
                    ),
                  ),
                  if (program.isTasosFeatured)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusXS),
                        ),
                        child: const Text(
                          'TASOS PICK',
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
                  Positioned(
                    bottom: 12,
                    left: 14,
                    child: Row(
                      children: [
                        const Icon(Icons.fitness_center_rounded,
                            color: AppColors.accent, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          program.title,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
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

          // Card body
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _Meta(
                        icon: Icons.calendar_month_rounded,
                        label: '${program.durationWeeks} Weeks'),
                    const SizedBox(width: AppSpacing.md),
                    _Meta(
                        icon: Icons.fitness_center_rounded,
                        label: '${program.daysPerWeek} Days/Wk'),
                    const SizedBox(width: AppSpacing.md),
                    _Meta(
                        icon: Icons.people_rounded,
                        label: program.formattedUsers),
                    const Spacer(),
                    const Icon(Icons.star_rounded,
                        color: AppColors.warning, size: 13),
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
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    FpChip(label: program.goalLabel, small: true),
                    if (program.isPremium)
                      FpChip(
                          label: 'PREMIUM',
                          color: AppColors.accent,
                          small: true),
                    if (isEnrolled)
                      FpChip(
                          label: 'ACTIVE',
                          color: AppColors.success,
                          small: true),
                  ],
                ),
              ],
            ),
          ),
        ],
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
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base, vertical: AppSpacing.md),
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
                hintText: AppLocalizations.of(context)!.searchPrograms,
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
    final l = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _Chip(
            label: l.filterAll,
            active: filter.level == null && filter.goal == null,
            onTap: () => onFilter(const _ProgramFilter()),
          ),
          const SizedBox(width: AppSpacing.sm),
          _Chip(
            label: l.filterBeginner,
            active: filter.level == ExperienceLevel.beginner,
            activeColor: AppColors.beginnerColor,
            onTap: () => onFilter(filter.copyWith(
              level: ExperienceLevel.beginner,
              clearLevel: filter.level == ExperienceLevel.beginner,
            )),
          ),
          const SizedBox(width: AppSpacing.sm),
          _Chip(
            label: l.filterIntermediate,
            active: filter.level == ExperienceLevel.intermediate,
            activeColor: AppColors.intermediateColor,
            onTap: () => onFilter(filter.copyWith(
              level: ExperienceLevel.intermediate,
              clearLevel: filter.level == ExperienceLevel.intermediate,
            )),
          ),
          const SizedBox(width: AppSpacing.sm),
          _Chip(
            label: l.filterAdvanced,
            active: filter.level == ExperienceLevel.advanced,
            activeColor: AppColors.advancedColor,
            onTap: () => onFilter(filter.copyWith(
              level: ExperienceLevel.advanced,
              clearLevel: filter.level == ExperienceLevel.advanced,
            )),
          ),
          const SizedBox(width: AppSpacing.sm),
          _Chip(
            label: l.filterHypertrophy,
            active: filter.goal == ProgramGoal.hypertrophy,
            onTap: () => onFilter(filter.copyWith(
              goal: ProgramGoal.hypertrophy,
              clearGoal: filter.goal == ProgramGoal.hypertrophy,
            )),
          ),
          const SizedBox(width: AppSpacing.sm),
          _Chip(
            label: l.filterStrength,
            active: filter.goal == ProgramGoal.strength,
            onTap: () => onFilter(filter.copyWith(
              goal: ProgramGoal.strength,
              clearGoal: filter.goal == ProgramGoal.strength,
            )),
          ),
          const SizedBox(width: AppSpacing.sm),
          _Chip(
            label: l.filterFatLoss,
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
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base - 2, vertical: 7),
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
            color: active ? Colors.black : context.secondaryText,
          ),
        ),
      ),
    );
  }
}

// ── Meta row item ─────────────────────────────────────────
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
