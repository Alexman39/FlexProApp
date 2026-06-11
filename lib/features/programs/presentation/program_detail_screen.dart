import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flexpro_coaching/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/fp_card.dart';
import '../../onboarding/domain/onboarding_models.dart';
import '../../subscription/providers/subscription_provider.dart';
import '../data/programs_data.dart';
import '../domain/enrollment_model.dart';
import '../domain/program_model.dart';
import '../domain/program_session.dart';
import '../providers/enrollment_provider.dart';

class ProgramDetailScreen extends ConsumerWidget {
  const ProgramDetailScreen({super.key, required this.programId});

  final String programId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    const accent = AppColors.accent;
    final enrollment = ref.watch(enrollmentProvider).valueOrNull;
    final isPremium = ref.watch(isPremiumProvider);

    Program? program;
    try {
      program = kAllPrograms.firstWhere((p) => p.id == programId);
    } catch (_) {}

    if (program == null) {
      return Scaffold(
        backgroundColor: context.bg,
        appBar: AppBar(
          title: Text(l.programsTitle),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded,
                color: context.primaryText, size: 20),
            onPressed: () => context.pop(),
            tooltip: 'Back',
          ),
        ),
        body: Center(
          child: Text(
            l.noProgramsFound,
            style: TextStyle(color: context.secondaryText),
          ),
        ),
      );
    }

    final p = program;
    final isEnrolled = enrollment?.programId == p.id;
    final isLocked = p.isPremium && !isPremium;

    final levelColor = switch (p.level) {
      ExperienceLevel.beginner => AppColors.beginnerColor,
      ExperienceLevel.intermediate => AppColors.intermediateColor,
      ExperienceLevel.advanced => AppColors.advancedColor,
    };

    return Scaffold(
      backgroundColor: context.bg,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Hero sliver app bar ──
              SliverAppBar(
                expandedHeight: 216,
                pinned: true,
                backgroundColor: context.bg,
                surfaceTintColor: Colors.transparent,
                leading: Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.sm),
                  child: IconButton(
                    icon: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(102),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    onPressed: () => context.pop(),
                    tooltip: 'Back',
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.heroCardGradient,
                    ),
                    child: Stack(
                      children: [
                        // Accent glow
                        Positioned(
                          left: -30,
                          top: -30,
                          child: Container(
                            width: 220,
                            height: 220,
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
                        // Program info
                        Positioned(
                          bottom: AppSpacing.lg,
                          left: AppSpacing.base,
                          right: AppSpacing.base,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Badges row
                              Wrap(
                                spacing: AppSpacing.sm,
                                children: [
                                  if (p.isTasosFeatured)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.accent,
                                        borderRadius: BorderRadius.circular(
                                            AppTheme.radiusXS),
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
                                  FpChip(
                                    label: p.levelLabel,
                                    color: levelColor,
                                    small: true,
                                  ),
                                  if (p.isPremium)
                                    FpChip(
                                      label: 'PREMIUM',
                                      color: AppColors.accent,
                                      small: true,
                                    ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              // Title
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(Icons.fitness_center_rounded,
                                      color: AppColors.accent, size: 28),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Text(
                                      p.title,
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                p.subtitle,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  color: Colors.white.withAlpha(179),
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

              // ── Stats row ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.base, AppSpacing.lg,
                      AppSpacing.base, 0),
                  child: Row(
                    children: [
                      _StatBox(
                          label: l.weeksLabel,
                          value: '${p.durationWeeks}',
                          accent: accent),
                      const SizedBox(width: AppSpacing.sm),
                      _StatBox(
                          label: l.daysPerWeekShort,
                          value: '${p.daysPerWeek}',
                          accent: accent),
                      const SizedBox(width: AppSpacing.sm),
                      _StatBox(
                          label: l.ratingLabel,
                          value: p.rating.toStringAsFixed(1),
                          accent: AppColors.warning),
                      const SizedBox(width: AppSpacing.sm),
                      _StatBox(
                          label: l.usersLabel,
                          value: p.formattedUsers,
                          accent: accent),
                    ],
                  ),
                ),
              ),

              // ── Goal + split chips ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.base, AppSpacing.md, AppSpacing.base, 0),
                  child: Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      FpChip(label: p.goalLabel),
                      FpChip(label: p.splitLabel),
                    ],
                  ),
                ),
              ),

              // ── Description ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.base, AppSpacing.lg, AppSpacing.base, 0),
                  child: Text(
                    p.description,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      color: context.secondaryText,
                      height: 1.65,
                    ),
                  ),
                ),
              ),

              // ── Sessions header ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.base, AppSpacing.xl, AppSpacing.base,
                      AppSpacing.md),
                  child: FpSectionHeader(title: l.allSessions),
                ),
              ),

              // ── Sessions list ──
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.base, 0, AppSpacing.base, 120),
                sliver: p.sessions.isEmpty
                    ? SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.xl),
                            child: Text(
                              '—',
                              style:
                                  TextStyle(color: context.tertiaryText),
                            ),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) {
                            final isLast = i == p.sessions.length - 1;
                            return Padding(
                              padding: EdgeInsets.only(
                                  bottom: isLast ? 0 : AppSpacing.sm),
                              child: _SessionTile(
                                session: p.sessions[i],
                                index: i,
                                accent: accent,
                              ),
                            );
                          },
                          childCount: p.sessions.length,
                        ),
                      ),
              ),
            ],
          ),

          // ── Sticky bottom CTA ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _BottomCta(
              program: p,
              enrollment: enrollment,
              isEnrolled: isEnrolled,
              isLocked: isLocked,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat box ──────────────────────────────────────────────
class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md, horizontal: AppSpacing.sm),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          border: Border.all(color: context.border),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: accent,
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
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Session tile ──────────────────────────────────────────
class _SessionTile extends StatelessWidget {
  const _SessionTile({
    required this.session,
    required this.index,
    required this.accent,
  });

  final ProgramSession session;
  final int index;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: context.border),
      ),
      child: Row(
        children: [
          // Index badge
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: accent.withAlpha(25),
              shape: BoxShape.circle,
              border: Border.all(color: accent.withAlpha(64)),
            ),
            alignment: Alignment.center,
            child: Text(
              '${index + 1}',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: accent,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Session info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.name,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: context.primaryText,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${session.exercises.length} exercises · '
                  '${session.totalSets} sets · '
                  '~${session.estimatedMinutes} min',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: context.tertiaryText,
                  ),
                ),
              ],
            ),
          ),

          // Arrow
          Icon(
            Icons.chevron_right_rounded,
            color: context.tertiaryText,
            size: 20,
          ),
        ],
      ),
    );
  }
}

// ── Bottom CTA ────────────────────────────────────────────
class _BottomCta extends ConsumerWidget {
  const _BottomCta({
    required this.program,
    required this.enrollment,
    required this.isEnrolled,
    required this.isLocked,
  });

  final Program program;
  final ProgramEnrollment? enrollment;
  final bool isEnrolled;
  final bool isLocked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    final btnLabel = isLocked
        ? l.unlockProgram
        : isEnrolled
            ? l.leaveProgram
            : l.startProgram;

    final btnIcon = isLocked
        ? Icons.lock_open_rounded
        : isEnrolled
            ? Icons.exit_to_app_rounded
            : Icons.play_arrow_rounded;

    final btnBg = isLocked
        ? AppColors.accentDim
        : isEnrolled
            ? Colors.transparent
            : AppColors.accent;

    final btnBorder = isLocked
        ? AppColors.accent.withAlpha(77)
        : isEnrolled
            ? context.border
            : AppColors.accent;

    final btnFg = isLocked
        ? AppColors.accent
        : isEnrolled
            ? context.secondaryText
            : Colors.black;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.md,
        AppSpacing.base,
        AppSpacing.base + bottomPad,
      ),
      decoration: BoxDecoration(
        color: context.bg,
        border: Border(top: BorderSide(color: context.border)),
      ),
      child: GestureDetector(
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
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: btnBg,
            borderRadius: BorderRadius.circular(AppTheme.radius),
            border: Border.all(color: btnBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(btnIcon, color: btnFg, size: 18),
              const SizedBox(width: AppSpacing.sm),
              Text(
                btnLabel,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: btnFg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
