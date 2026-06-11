import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flexpro_coaching/l10n/app_localizations.dart';

import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/fp_button.dart';
import '../../shared/widgets/fp_card.dart';
import '../auth/providers/auth_providers.dart';
import '../coach/providers/coach_providers.dart';
import '../programs/domain/enrollment_model.dart';
import '../programs/domain/program_model.dart';
import '../programs/domain/program_session.dart';
import '../programs/providers/enrollment_provider.dart';
import '../programs/providers/todays_workout_provider.dart';
import '../workout/domain/workout_log_model.dart';
import 'providers/readiness_provider.dart';
import 'providers/today_log_provider.dart';

// ── Screen ────────────────────────────────────────────────
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firstName    = ref.watch(appUserProvider).valueOrNull?.firstName ?? 'Athlete';
    final session      = ref.watch(todaysSessionProvider);
    final program      = ref.watch(activeProgramProvider);
    final enrollment   = ref.watch(enrollmentProvider).valueOrNull;
    final completedLog = ref.watch(todaysCompletedLogProvider);

    const hPad = EdgeInsets.fromLTRB(
        AppSpacing.base, AppSpacing.md, AppSpacing.base, 0);

    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _TodayHeader(firstName: firstName)
                  .animate()
                  .fadeIn(duration: AppDuration.slow),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.base, AppSpacing.lg, AppSpacing.base, 0),
              sliver: SliverToBoxAdapter(
                child: const _CoachNoteCard()
                    .animate(delay: 80.ms)
                    .fadeIn(duration: AppDuration.slow)
                    .slideY(begin: 0.06, curve: AppCurve.enter),
              ),
            ),
            SliverPadding(
              padding: hPad,
              sliver: SliverToBoxAdapter(
                child: (completedLog != null && session != null
                    ? _PostWorkoutCard(
                        log: completedLog,
                        session: session,
                        program: program,
                      )
                    : session != null
                        ? _HeroSessionCard(
                            session: session,
                            program: program,
                            enrollment: enrollment,
                          )
                        : _RestDayCard(enrollment: enrollment))
                    .animate(delay: 160.ms)
                    .fadeIn(duration: AppDuration.slow)
                    .slideY(begin: 0.06, curve: AppCurve.enter),
              ),
            ),
            SliverPadding(
              padding: hPad,
              sliver: SliverToBoxAdapter(
                child: const _ReadinessCard()
                    .animate(delay: 240.ms)
                    .fadeIn(duration: AppDuration.slow),
              ),
            ),
            SliverPadding(
              padding: hPad,
              sliver: SliverToBoxAdapter(
                child: _ActivityFeed(enrollment: enrollment)
                    .animate(delay: 320.ms)
                    .fadeIn(duration: AppDuration.slow),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────
class _TodayHeader extends StatelessWidget {
  const _TodayHeader({required this.firstName});
  final String firstName;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? l.greetingMorning
        : hour < 17
            ? l.greetingAfternoon
            : l.greetingEvening;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.base, AppSpacing.md, AppSpacing.base, AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: AppTypeScale.bodyMd,
                    color: context.secondaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  firstName,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: AppTypeScale.displaySm,
                    fontWeight: FontWeight.w900,
                    color: context.primaryText,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => context.go(AppRoutes.profile),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.accent, AppColors.accentLight],
                ),
                border: Border.all(color: AppColors.accent, width: 2),
              ),
              child: Center(
                child: Text(
                  firstName.isNotEmpty ? firstName[0].toUpperCase() : 'A',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: AppTypeScale.headSm,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Coach note card ───────────────────────────────────────
class _CoachNoteCard extends ConsumerWidget {
  const _CoachNoteCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l        = AppLocalizations.of(context)!;
    final noteAsync = ref.watch(coachNoteProvider);

    return FpCard(
      gradient: AppColors.accentCardGradient,
      borderColor: AppColors.accent.withAlpha(40),
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.coachNoteLabel,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: AppTypeScale.labelSm,
              fontWeight: FontWeight.w700,
              color: AppColors.accent,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppColors.accent, AppColors.accentLight],
                  ),
                ),
                child: const Center(
                  child: Text(
                    'T',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: AppTypeScale.headSm,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tasos Misailidis',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: AppTypeScale.labelLg,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    noteAsync.when(
                      loading: () => SizedBox(
                        height: 14,
                        width: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: AppColors.accent.withAlpha(180),
                        ),
                      ),
                      error: (_, __) => Text(
                        l.coachNoNote,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: AppTypeScale.bodySm,
                          color: Colors.white.withAlpha(179),
                          height: 1.5,
                        ),
                      ),
                      data: (note) => Text(
                        note ?? l.coachNoNote,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: AppTypeScale.bodySm,
                          color: Colors.white.withAlpha(179),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Hero session card (card-hero) ─────────────────────────
class _HeroSessionCard extends StatelessWidget {
  const _HeroSessionCard({
    required this.session,
    required this.program,
    required this.enrollment,
  });

  final ProgramSession session;
  final Program? program;
  final ProgramEnrollment? enrollment;

  @override
  Widget build(BuildContext context) {
    final l        = AppLocalizations.of(context)!;
    final e        = enrollment;
    final subtitle = (program != null && e != null)
        ? '${program!.title}  ·  ${e.weekLabel}  ·  ${e.dayLabel}'
        : '';
    final exercises = session.exercises.length;
    final sets      = session.totalSets;
    final estMin    = session.estimatedMinutes;

    return FpCard(
      gradient: AppColors.heroCardGradient,
      borderColor: AppColors.accent.withAlpha(51),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppColors.accentGlow, Colors.transparent],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.todaysWorkout,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: AppTypeScale.labelSm,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                session.name,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: AppTypeScale.displaySm,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: AppTypeScale.bodySm,
                    color: Colors.white.withAlpha(153),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  _HeroStat(value: '$exercises', label: l.exercises),
                  const SizedBox(width: AppSpacing.xl),
                  _HeroStat(
                    value: estMin > 0 ? '~$estMin' : '—',
                    label: l.estMin,
                  ),
                  const SizedBox(width: AppSpacing.xl),
                  _HeroStat(value: '$sets', label: l.sets),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              FpButton(
                label: l.startWorkout,
                icon: const Icon(Icons.play_arrow_rounded),
                onPressed: () => context.push(AppRoutes.workoutActive),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: AppTypeScale.metricSm,
            fontWeight: FontWeight.w900,
            color: AppColors.accent,
          ),
        ),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: AppTypeScale.labelSm,
            fontWeight: FontWeight.w600,
            color: context.tertiaryText,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }
}

// ── Post-workout summary card ─────────────────────────────
class _PostWorkoutCard extends StatelessWidget {
  const _PostWorkoutCard({
    required this.log,
    required this.session,
    required this.program,
  });

  final WorkoutLog log;
  final ProgramSession session;
  final Program? program;

  @override
  Widget build(BuildContext context) {
    final l        = AppLocalizations.of(context)!;
    final subtitle = (program != null &&
            log.programWeek != null &&
            log.programDay != null)
        ? '${program!.title}  ·  Week ${log.programWeek! + 1}  ·  Day ${log.programDay! + 1}'
        : session.name;

    return FpCard(
      gradient: AppColors.heroCardGradient,
      borderColor: AppColors.accent.withAlpha(51),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppColors.accentGlow, Colors.transparent],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    l.workoutDoneLabel,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: AppTypeScale.labelSm,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 14,
                    color: AppColors.accent,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                log.workoutName,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: AppTypeScale.displaySm,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: AppTypeScale.bodySm,
                  color: Colors.white.withAlpha(153),
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  _HeroStat(
                    value: log.formattedDuration,
                    label: l.duration.toUpperCase(),
                  ),
                  const SizedBox(width: AppSpacing.xl),
                  _HeroStat(
                    value: '${log.totalSets}',
                    label: l.sets.toUpperCase(),
                  ),
                  const SizedBox(width: AppSpacing.xl),
                  _HeroStat(
                    value: log.formattedVolume,
                    label: l.volume.toUpperCase(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              GestureDetector(
                onTap: () => context.push(
                  AppRoutes.workoutLogDetail,
                  extra: log,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l.viewDetails,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: AppTypeScale.bodyMd,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: AppColors.accent,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Rest day card ─────────────────────────────────────────
class _RestDayCard extends StatelessWidget {
  const _RestDayCard({required this.enrollment});
  final ProgramEnrollment? enrollment;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return FpCard(
      gradient: AppColors.restDayCardGradient,
      borderColor: AppColors.accent.withAlpha(20),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppColors.restDayGlow, Colors.transparent],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.restDayLabel,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: AppTypeScale.labelSm,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l.restDayTitle,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: AppTypeScale.displaySm,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l.restDayBody,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: AppTypeScale.bodySm,
                  color: Colors.white.withAlpha(153),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  _RecoveryPillar(
                    icon: Icons.nightlight_round,
                    label: l.restDayTipSleep,
                  ),
                  const SizedBox(width: AppSpacing.xl),
                  _RecoveryPillar(
                    icon: Icons.water_drop_outlined,
                    label: l.restDayTipHydration,
                  ),
                  const SizedBox(width: AppSpacing.xl),
                  _RecoveryPillar(
                    icon: Icons.self_improvement_rounded,
                    label: l.restDayTipMobility,
                  ),
                ],
              ),
              if (enrollment == null) ...[
                const SizedBox(height: AppSpacing.xl),
                FpButton(
                  label: l.browsePrograms,
                  variant: FpButtonVariant.secondary,
                  onPressed: () => context.go(AppRoutes.programs),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _RecoveryPillar extends StatelessWidget {
  const _RecoveryPillar({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.accent.withAlpha(200)),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: AppTypeScale.labelSm,
            fontWeight: FontWeight.w600,
            color: context.tertiaryText,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}

// ── Readiness card ────────────────────────────────────────
class _ReadinessCard extends ConsumerStatefulWidget {
  const _ReadinessCard();

  @override
  ConsumerState<_ReadinessCard> createState() => _ReadinessCardState();
}

class _ReadinessCardState extends ConsumerState<_ReadinessCard> {
  int  _sleep     = 0;
  int  _energy    = 0;
  int  _soreness  = 0;
  bool _initialized = false;

  void _onChange(int sleep, int energy, int soreness) {
    setState(() {
      _sleep    = sleep;
      _energy   = energy;
      _soreness = soreness;
    });
    ref.read(readinessProvider.notifier).save(
          RecoveryEntry(sleep: sleep, energy: energy, soreness: soreness),
        );
  }

  @override
  Widget build(BuildContext context) {
    // Populate local state once Firestore data arrives.
    ref.listen<AsyncValue<RecoveryEntry?>>(readinessProvider, (_, next) {
      if (!_initialized) {
        final entry = next.valueOrNull;
        if (entry != null) {
          setState(() {
            _sleep       = entry.sleep;
            _energy      = entry.energy;
            _soreness    = entry.soreness;
            _initialized = true;
          });
        } else if (next is AsyncData) {
          _initialized = true; // no saved entry today — zeros are correct
        }
      }
    });

    final l = AppLocalizations.of(context)!;
    return FpCard(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.readinessTitle,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: AppTypeScale.headSm,
              fontWeight: FontWeight.w800,
              color: context.primaryText,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _ReadinessRow(
            icon: Icons.nightlight_round,
            label: l.readinessSleep,
            value: _sleep,
            onChanged: (v) => _onChange(v, _energy, _soreness),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ReadinessRow(
            icon: Icons.flash_on_rounded,
            label: l.readinessEnergy,
            value: _energy,
            onChanged: (v) => _onChange(_sleep, v, _soreness),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ReadinessRow(
            icon: Icons.fitness_center_rounded,
            label: l.readinessSoreness,
            value: _soreness,
            onChanged: (v) => _onChange(_sleep, _energy, v),
          ),
        ],
      ),
    );
  }
}

class _ReadinessRow extends StatelessWidget {
  const _ReadinessRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: context.tertiaryText),
        const SizedBox(width: AppSpacing.sm),
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: AppTypeScale.bodyMd,
              color: context.secondaryText,
            ),
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: List.generate(5, (i) {
              final filled = i < value;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onChanged(i + 1 == value ? 0 : i + 1);
                },
                child: Container(
                  width: 44,
                  height: 44,
                  margin: const EdgeInsets.only(left: AppSpacing.xs),
                  alignment: Alignment.center,
                  child: AnimatedContainer(
                    duration: AppDuration.fast,
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled
                          ? AppColors.accent.withAlpha(26)
                          : context.surface2,
                      border: Border.all(
                        color: filled ? AppColors.accent : context.border,
                      ),
                    ),
                    child: filled
                        ? const Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: AppColors.accent,
                          )
                        : null,
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

// ── Activity feed ─────────────────────────────────────────
class _ActivityFeed extends StatelessWidget {
  const _ActivityFeed({required this.enrollment});
  final ProgramEnrollment? enrollment;

  @override
  Widget build(BuildContext context) {
    final l          = AppLocalizations.of(context)!;
    final count      = enrollment?.totalSessions ?? 0;
    final weekLabel  = enrollment?.weekLabel;
    final hasActivity = count > 0;

    return FpCard(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FpSectionHeader(
            title: l.recentActivity,
            action: l.seeAll,
            onAction: () => context.push(AppRoutes.workoutHistory),
            margin: EdgeInsets.zero,
          ),
          const SizedBox(height: AppSpacing.md),
          if (!hasActivity)
            Text(
              l.noWorkouts,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: AppTypeScale.bodyMd,
                color: context.tertiaryText,
              ),
            )
          else
            Row(
              children: [
                _ActivityStat(
                  value: '$count',
                  label: l.sessions.toUpperCase(),
                ),
                if (weekLabel != null) ...[
                  const SizedBox(width: AppSpacing.xl),
                  _ActivityStat(
                    value: weekLabel,
                    label: l.activeProgramLabel,
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _ActivityStat extends StatelessWidget {
  const _ActivityStat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: AppTypeScale.metricMd,
            fontWeight: FontWeight.w900,
            color: AppColors.accent,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: AppTypeScale.labelSm,
            fontWeight: FontWeight.w700,
            color: context.tertiaryText,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }
}
