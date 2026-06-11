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
import '../../../shared/widgets/fp_button.dart';
import '../../../shared/widgets/fp_card.dart';
import '../../onboarding/domain/onboarding_models.dart';
import '../../onboarding/providers/onboarding_provider.dart';
import '../data/programs_data.dart';
import '../domain/program_model.dart';
import '../providers/enrollment_provider.dart';

ProgramGoal? _toProgramGoal(TrainingGoal? g) => switch (g) {
  TrainingGoal.hypertrophy => ProgramGoal.hypertrophy,
  TrainingGoal.strength    => ProgramGoal.strength,
  TrainingGoal.fatLoss     => ProgramGoal.fatLoss,
  TrainingGoal.recomp      => ProgramGoal.recomp,
  TrainingGoal.general     => ProgramGoal.general,
  null                     => null,
};

List<Program> _sortedByRelevance(OnboardingData data) {
  final wantGoal  = _toProgramGoal(data.goal);
  final wantLevel = data.experience;
  final wantDays  = data.daysPerWeek;

  int score(Program p) {
    int s = 0;
    if (wantGoal  != null && p.goal       == wantGoal)  s += 3;
    if (wantLevel != null && p.level      == wantLevel) s += 2;
    if (wantDays  != null && p.daysPerWeek == wantDays)  s += 1;
    if (p.isTasosFeatured) s += 1;
    return s;
  }

  return [...kAllPrograms]..sort((a, b) => score(b).compareTo(score(a)));
}

// ── Screen ────────────────────────────────────────────────
class ProgramAssignScreen extends ConsumerWidget {
  const ProgramAssignScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l        = AppLocalizations.of(context)!;
    final data     = ref.watch(onboardingProvider);
    final programs = _sortedByRelevance(data);
    final isLoading = ref.watch(enrollmentProvider).isLoading;

    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.base, AppSpacing.lg, AppSpacing.base, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.assignTitle,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: AppTypeScale.displaySm,
                      fontWeight: FontWeight.w900,
                      color: context.primaryText,
                      letterSpacing: -0.5,
                      height: 1.1,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: AppDuration.slow)
                      .slideY(begin: 0.08, curve: AppCurve.enter),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l.assignSubtitle,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: AppTypeScale.bodyMd,
                      color: context.secondaryText,
                      height: 1.5,
                    ),
                  )
                      .animate(delay: 60.ms)
                      .fadeIn(duration: AppDuration.slow),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Program list ──
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.base, 0, AppSpacing.base, AppSpacing.base),
                physics: const BouncingScrollPhysics(),
                itemCount: programs.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (ctx, i) => _ProgramRow(
                  program: programs[i],
                  isLoading: isLoading,
                  onSelect: () async {
                    HapticFeedback.mediumImpact();
                    await ref
                        .read(enrollmentProvider.notifier)
                        .enroll(programs[i].id);
                    if (ctx.mounted) ctx.go(AppRoutes.today);
                  },
                )
                    .animate(
                      delay: Duration(milliseconds: 120 + i * 45),
                    )
                    .fadeIn(duration: AppDuration.slow)
                    .slideY(begin: 0.06, curve: AppCurve.enter),
              ),
            ),

            // ── Skip footer ──
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.base, 0, AppSpacing.base, AppSpacing.lg),
              child: FpButton(
                label: l.skip,
                variant: FpButtonVariant.ghost,
                size: FpButtonSize.medium,
                onPressed: () => context.go(AppRoutes.today),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Single program row card ───────────────────────────────
class _ProgramRow extends StatelessWidget {
  const _ProgramRow({
    required this.program,
    required this.onSelect,
    required this.isLoading,
  });

  final Program program;
  final VoidCallback onSelect;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final levelColor = switch (program.level) {
      ExperienceLevel.beginner     => AppColors.beginnerColor,
      ExperienceLevel.intermediate => AppColors.intermediateColor,
      ExperienceLevel.advanced     => AppColors.advancedColor,
    };

    return FpCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: isLoading ? null : onSelect,
      child: Row(
        children: [
          // Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: AppColors.heroCardGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusSM),
            ),
            child: const Center(
              child: Icon(
                Icons.fitness_center_rounded,
                color: AppColors.accent,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        program.title,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: AppTypeScale.labelLg,
                          fontWeight: FontWeight.w800,
                          color: context.primaryText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm - 1, vertical: 2),
                      decoration: BoxDecoration(
                        color: levelColor.withAlpha(30),
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusXS),
                        border: Border.all(color: levelColor.withAlpha(80)),
                      ),
                      child: Text(
                        program.levelLabel,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: levelColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  program.subtitle,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: AppTypeScale.bodySm,
                    color: context.secondaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    _MetaChip(
                      icon: Icons.calendar_month_rounded,
                      label: '${program.durationWeeks}w',
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _MetaChip(
                      icon: Icons.today_rounded,
                      label: '${program.daysPerWeek}d/wk',
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Icon(
                      Icons.star_rounded,
                      color: AppColors.warning,
                      size: 11,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      program.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Chevron
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: isLoading
                ? context.tertiaryText
                : AppColors.accent,
            size: 16,
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: context.tertiaryText, size: 11),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            color: context.secondaryText,
          ),
        ),
      ],
    );
  }
}
