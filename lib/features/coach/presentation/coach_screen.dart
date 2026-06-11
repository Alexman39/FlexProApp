import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/fp_button.dart';
import '../../../shared/widgets/fp_card.dart';
import '../domain/coach_models.dart';
import '../providers/coach_providers.dart';

// ── Screen ────────────────────────────────────────────────

class CoachScreen extends ConsumerStatefulWidget {
  const CoachScreen({super.key});

  @override
  ConsumerState<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends ConsumerState<CoachScreen> {
  int _checkInRating = 0;
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _submitCheckIn() {
    if (_checkInRating == 0) return;
    ref.read(checkInProvider.notifier).submit(
          rating: _checkInRating,
          note: _noteController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    ref.listen<CheckInStatus>(checkInProvider, (_, next) {
      if (next == CheckInStatus.sent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l.checkInSent,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm)),
            duration: const Duration(seconds: 2),
          ),
        );
        setState(() => _checkInRating = 0);
        _noteController.clear();
      }
    });

    final posts = ref.watch(coachPostsProvider).valueOrNull ?? [];
    final feedbacks = ref.watch(coachFeedbackProvider).valueOrNull ?? [];

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
                    AppSpacing.base, 14, AppSpacing.base, 0),
                child: Text(
                  l.navCoach,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: AppTypeScale.displayMd,
                    fontWeight: FontWeight.w900,
                    color: context.primaryText,
                    letterSpacing: -0.5,
                  ),
                ),
              ).animate().fadeIn(duration: AppDuration.slow),
            ),

            // ── Coach header card ──
            SliverPadding(
              padding: AppSpacing.sectionPadding,
              sliver: SliverToBoxAdapter(
                child: _CoachHeaderCard(
                  onViewProfile: () => context.push(AppRoutes.coachProfile),
                  l: l,
                ).animate(delay: 60.ms).fadeIn().slideY(
                    begin: 0.05, curve: AppCurve.enter),
              ),
            ),

            // ── Coach Updates ──
            SliverPadding(
              padding: AppSpacing.sectionPadding,
              sliver: SliverToBoxAdapter(
                child: FpSectionHeader(title: l.coachUpdates),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
              sliver: posts.isEmpty
                  ? SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                        child: Center(
                          child: Text(
                            l.noCoachPosts,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: AppTypeScale.bodyMd,
                              color: context.secondaryText,
                            ),
                          ),
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: _CoachPostCard(post: posts[i], l: l)
                              .animate(delay: (i * 60 + 100).ms)
                              .fadeIn()
                              .slideY(begin: 0.05, curve: AppCurve.enter),
                        ),
                        childCount: posts.length,
                      ),
                    ),
            ),

            // ── Weekly Check-In ──
            SliverPadding(
              padding: AppSpacing.sectionPadding,
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FpSectionHeader(title: l.weeklyCheckIn),
                    _CheckInCard(
                      rating: _checkInRating,
                      noteController: _noteController,
                      onRatingChanged: (v) => setState(() => _checkInRating = v),
                      onSubmit: _submitCheckIn,
                      isLoading: ref.watch(checkInProvider) ==
                          CheckInStatus.loading,
                      l: l,
                    ),
                  ],
                ).animate(delay: 300.ms).fadeIn().slideY(
                    begin: 0.05, curve: AppCurve.enter),
              ),
            ),

            // ── Coach Feedback ──
            SliverPadding(
              padding: AppSpacing.sectionPadding,
              sliver: SliverToBoxAdapter(
                child: FpSectionHeader(title: l.coachFeedbackSection),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.base, 0, AppSpacing.base, AppSpacing.xxl,
              ),
              sliver: feedbacks.isEmpty
                  ? SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                        child: Center(
                          child: Text(
                            l.noCoachFeedback,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: AppTypeScale.bodyMd,
                              color: context.secondaryText,
                            ),
                          ),
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: _FeedbackCard(feedback: feedbacks[i])
                              .animate(delay: (i * 80 + 400).ms)
                              .fadeIn()
                              .slideY(begin: 0.05, curve: AppCurve.enter),
                        ),
                        childCount: feedbacks.length,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Coach header card ─────────────────────────────────────

class _CoachHeaderCard extends StatelessWidget {
  const _CoachHeaderCard({
    required this.onViewProfile,
    required this.l,
  });

  final VoidCallback onViewProfile;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return FpCard(
      padding: const EdgeInsets.all(AppSpacing.base),
      gradient: AppColors.heroCardGradient,
      borderColor: AppColors.accent.withAlpha(38),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.accent, AppColors.accentLight],
              ),
              boxShadow: AppShadow.accentGlow,
            ),
            child: const Center(
              child: Text(
                'T',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: AppTypeScale.displaySm,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Name + title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tasos Misailidis',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: AppTypeScale.bodyLg,
                    fontWeight: FontWeight.w800,
                    color: context.primaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l.yourCoach,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: AppTypeScale.labelMd,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
          // View profile button
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onViewProfile();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.accentDim,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: AppColors.accent.withAlpha(77)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l.viewProfile,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: AppTypeScale.labelMd,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      size: 11, color: AppColors.accent),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Coach post card ───────────────────────────────────────

class _CoachPostCard extends StatelessWidget {
  const _CoachPostCard({required this.post, required this.l});

  final CoachPost post;
  final AppLocalizations l;

  static const _dateFmt = 'MMM d, y';

  Color _typeColor(CoachPostType t) => switch (t) {
        CoachPostType.tip            => AppColors.info,
        CoachPostType.motivation     => AppColors.accent,
        CoachPostType.programUpdate  => AppColors.success,
        CoachPostType.nutrition      => AppColors.warning,
      };

  String _typeLabel(CoachPostType t) => switch (t) {
        CoachPostType.tip            => l.postTypeTip,
        CoachPostType.motivation     => l.postTypeMotivation,
        CoachPostType.programUpdate  => l.postTypeProgramUpdate,
        CoachPostType.nutrition      => l.postTypeNutrition,
      };

  @override
  Widget build(BuildContext context) {
    final color = _typeColor(post.type);

    return FpCard(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Type chip
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withAlpha(26),
                  borderRadius: BorderRadius.circular(AppRadius.xxl),
                  border: Border.all(color: color.withAlpha(77)),
                ),
                child: Text(
                  _typeLabel(post.type).toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: AppTypeScale.labelSm,
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const Spacer(),
              // Date
              Text(
                DateFormat(_dateFmt).format(post.date),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: AppTypeScale.labelSm,
                  fontWeight: FontWeight.w500,
                  color: context.tertiaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Message
          Text(
            post.message,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: AppTypeScale.bodyMd,
              color: context.secondaryText,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Weekly check-in card ──────────────────────────────────

class _CheckInCard extends StatelessWidget {
  const _CheckInCard({
    required this.rating,
    required this.noteController,
    required this.onRatingChanged,
    required this.onSubmit,
    required this.isLoading,
    required this.l,
  });

  final int rating;
  final TextEditingController noteController;
  final ValueChanged<int> onRatingChanged;
  final VoidCallback onSubmit;
  final bool isLoading;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return FpCard(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.howWasYourWeek,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: AppTypeScale.bodySm,
              fontWeight: FontWeight.w600,
              color: context.secondaryText,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Rating row 1-5
          Row(
            children: List.generate(5, (i) {
              final val = i + 1;
              final isSelected = rating >= val;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onRatingChanged(val);
                  },
                  child: AnimatedContainer(
                    duration: AppDuration.fast,
                    margin: EdgeInsets.only(right: i < 4 ? AppSpacing.xs : 0),
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.accentDim
                          : context.surface2,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.accent.withAlpha(100)
                            : context.border,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$val',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: AppTypeScale.headSm,
                          fontWeight: FontWeight.w800,
                          color: isSelected
                              ? AppColors.accent
                              : context.tertiaryText,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: AppSpacing.md),
          // Note field
          TextField(
            controller: noteController,
            maxLines: 3,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: AppTypeScale.bodyMd,
              color: context.primaryText,
            ),
            decoration: InputDecoration(
              hintText: l.checkInPlaceholder,
              hintStyle: TextStyle(
                fontFamily: 'Inter',
                fontSize: AppTypeScale.bodyMd,
                color: context.tertiaryText,
              ),
              contentPadding: const EdgeInsets.all(AppSpacing.md),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Submit button
          AnimatedOpacity(
            opacity: rating > 0 ? 1.0 : 0.4,
            duration: AppDuration.fast,
            child: FpButton(
              label: l.submitCheckIn,
              isLoading: isLoading,
              onPressed: (rating > 0 && !isLoading) ? onSubmit : null,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Coach feedback card ───────────────────────────────────

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({required this.feedback});

  final CoachFeedback feedback;

  static const _dateFmt = 'MMM d, y';

  @override
  Widget build(BuildContext context) {
    return FpCard(
      padding: const EdgeInsets.all(AppSpacing.base),
      borderColor: AppColors.accent.withAlpha(26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // "COACH FEEDBACK" label
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accentDim,
                  borderRadius: BorderRadius.circular(AppRadius.xxl),
                  border:
                      Border.all(color: AppColors.accent.withAlpha(77)),
                ),
                child: const Text(
                  'COACH',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: AppTypeScale.labelSm,
                    fontWeight: FontWeight.w800,
                    color: AppColors.accent,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              // Session reference chip
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: 3),
                decoration: BoxDecoration(
                  color: context.surface2,
                  borderRadius: BorderRadius.circular(AppRadius.xxl),
                ),
                child: Text(
                  feedback.sessionRef,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: AppTypeScale.labelSm,
                    fontWeight: FontWeight.w600,
                    color: context.secondaryText,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                DateFormat(_dateFmt).format(feedback.date),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: AppTypeScale.labelSm,
                  fontWeight: FontWeight.w500,
                  color: context.tertiaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            feedback.message,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: AppTypeScale.bodyMd,
              color: context.secondaryText,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}
