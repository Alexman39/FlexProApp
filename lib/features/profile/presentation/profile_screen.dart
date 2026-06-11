import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:flexpro_coaching/l10n/app_localizations.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/providers/notification_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/fp_card.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/providers/auth_providers.dart';
import '../../onboarding/domain/onboarding_models.dart';
import '../../onboarding/providers/onboarding_provider.dart';
import '../../progress/data/body_weight_repository.dart';

void _showLanguagePicker(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    backgroundColor: context.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXXL)),
    ),
    builder: (_) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.surface3,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          for (final entry in const [('English', 'en'), ('Ελληνικά', 'el')])
            ListTile(
              title: Text(
                entry.$1,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  color: context.primaryText,
                ),
              ),
              trailing: ref.watch(localeProvider).languageCode == entry.$2
                  ? const Icon(Icons.check_rounded, color: AppColors.accent)
                  : null,
              onTap: () {
                final locale = Locale(entry.$2);
                ref.read(localeProvider.notifier).state = locale;
                persistLocale(locale);
                Navigator.pop(context);
              },
            ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

void _showNotificationSheet(BuildContext context, WidgetRef ref) {
  final l = AppLocalizations.of(context)!;
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: context.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXXL)),
    ),
    builder: (sheetCtx) => _NotificationSheet(
      onPermissionDenied: () {
        Navigator.pop(sheetCtx);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.notificationPermissionDenied)),
        );
      },
    ),
  );
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appUser = ref.watch(appUserProvider).valueOrNull;
    final onboarding = ref.watch(onboardingProvider);
    final bodyWeights = ref.watch(bodyWeightProvider).valueOrNull ?? [];
    final latestWeight = bodyWeights.isNotEmpty ? bodyWeights.last : null;

    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Hero card ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.base, AppSpacing.md, AppSpacing.base, 0,
                ),
                child: _ProfileHeroCard(
                  name: appUser?.displayName ?? 'Athlete',
                  email: appUser?.email ?? '',
                  initials: (appUser?.firstName ?? 'A')[0].toUpperCase(),
                ).animate().fadeIn(duration: 300.ms),
              ),
            ),

            // ── Premium banner ─────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.base, AppSpacing.md, AppSpacing.base, 0,
                ),
                child: _PremiumBanner()
                    .animate(delay: 80.ms)
                    .fadeIn(duration: 300.ms),
              ),
            ),

            // ── Athlete stats grid ─────────────────────────────────
            SliverToBoxAdapter(
              child: _AthleteStatsSection(
                onboarding: onboarding,
                latestWeightKg: latestWeight?.weightKg,
              ).animate(delay: 140.ms).fadeIn(),
            ),

            // ── Preferences + Account sections ────────────────────
            SliverToBoxAdapter(
              child: Builder(builder: (ctx) {
                final l = AppLocalizations.of(ctx)!;
                final locale = ref.watch(localeProvider);
                final langLabel =
                    locale.languageCode == 'el' ? 'Ελληνικά' : 'English';
                final notifEnabled =
                    ref.watch(notificationSettingsProvider).enabled;
                return Column(
                  children: [
                    _SettingsSection(
                      label: l.preferences,
                      items: [
                        _SettingItem(
                          icon: Icons.dark_mode_rounded,
                          iconColor: AppColors.accent,
                          label: l.appearance,
                          trailing: _DarkModeToggle(),
                        ),
                        _SettingItem(
                          icon: Icons.language_rounded,
                          iconColor: AppColors.warning,
                          label: l.language,
                          value: langLabel,
                          onTap: () => _showLanguagePicker(ctx, ref),
                        ),
                        _SettingItem(
                          icon: Icons.notifications_rounded,
                          iconColor: AppColors.accent,
                          label: l.notifications,
                          value: notifEnabled
                              ? l.notificationOn
                              : l.notificationOff,
                          onTap: () => _showNotificationSheet(ctx, ref),
                        ),
                      ],
                    ).animate(delay: 180.ms).fadeIn(),

                    _SettingsSection(
                      label: l.account,
                      items: [
                        _SettingItem(
                          icon: Icons.logout_rounded,
                          iconColor: AppColors.danger,
                          label: l.signOut,
                          labelColor: AppColors.danger,
                          onTap: () async {
                            await ref.read(authRepositoryProvider)?.signOut();
                            if (ctx.mounted) ctx.go(AppRoutes.login);
                          },
                        ),
                      ],
                    ).animate(delay: 220.ms).fadeIn(),
                  ],
                );
              }),
            ),

            // ── Footer ────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.base, AppSpacing.lg, AppSpacing.base, 100,
                ),
                child: Builder(builder: (ctx) {
                  final l = AppLocalizations.of(ctx)!;
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => ctx.push(AppRoutes.privacyPolicy),
                            child: Text(
                              l.privacyPolicy,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.accent,
                              ),
                            ),
                          ),
                          Text(
                            ' · ',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: context.tertiaryText,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => ctx.push(AppRoutes.termsOfService),
                            child: Text(
                              l.termsOfService,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.accent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'FlexPro Coaching v1.0.0',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: context.tertiaryText,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'by Tasos Misailidis',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: context.tertiaryText,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'FlexPro Coaching is not a substitute for professional medical advice.',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: context.tertiaryText,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Profile hero card ──────────────────────────────────────────────────────────

class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard({
    required this.name,
    required this.email,
    required this.initials,
  });

  final String name;
  final String email;
  final String initials;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return FpCard(
      gradient: AppColors.heroCardGradient,
      borderColor: AppColors.accent.withAlpha(38),
      padding: const EdgeInsets.all(AppSpacing.base + AppSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusLG),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.accent, AppColors.accentLight],
              ),
              border: Border.all(color: AppColors.accent, width: 2),
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.base),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  email,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  l.memberSince,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: Colors.white.withAlpha(102),
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

// ── Premium banner ─────────────────────────────────────────────────────────────

class _PremiumBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.paywall),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.base + AppSpacing.xs),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusLG),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.accentDim,
              AppColors.accent.withAlpha(10),
            ],
          ),
          border: Border.all(
            color: AppColors.accent.withAlpha(77),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.accentDim,
                borderRadius: BorderRadius.circular(AppTheme.radiusSM),
              ),
              child: const Icon(
                Icons.bolt_rounded,
                color: AppColors.accent,
                size: 22,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'FlexPro Premium Active',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Annual plan · Renews Jan 2026',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: context.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.accent,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Athlete stats section ──────────────────────────────────────────────────────

class _AthleteStatsSection extends StatelessWidget {
  const _AthleteStatsSection({
    required this.onboarding,
    this.latestWeightKg,
  });

  final OnboardingData onboarding;
  final double? latestWeightKg;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final weightKg = latestWeightKg ?? onboarding.weightKg;
    final weightStr =
        weightKg != null ? '${weightKg.toStringAsFixed(1)} kg' : '—';
    final heightStr = onboarding.heightCm != null
        ? '${onboarding.heightCm!.toInt()} cm'
        : '—';
    final daysStr =
        onboarding.daysPerWeek != null ? '${onboarding.daysPerWeek}' : '—';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base, AppSpacing.xl, AppSpacing.base, 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              l.athleteStats.toUpperCase(),
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: context.tertiaryText,
                letterSpacing: 1,
              ),
            ),
          ),
          Row(
            children: [
              _StatCell(
                icon: Icons.flag_rounded,
                iconColor: AppColors.accent,
                label: l.goal,
                value: onboarding.goal?.label ?? '—',
              ),
              const SizedBox(width: AppSpacing.sm),
              _StatCell(
                icon: Icons.trending_up_rounded,
                iconColor: AppColors.success,
                label: l.experienceLevel,
                value: onboarding.experience?.label ?? '—',
              ),
              const SizedBox(width: AppSpacing.sm),
              _StatCell(
                icon: Icons.calendar_today_rounded,
                iconColor: AppColors.warning,
                label: l.trainingDays,
                value: daysStr,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _StatCell(
                icon: Icons.monitor_weight_outlined,
                iconColor: AppColors.info,
                label: l.bodyWeight,
                value: weightStr,
              ),
              const SizedBox(width: AppSpacing.sm),
              _StatCell(
                icon: Icons.height_rounded,
                iconColor: AppColors.accent,
                label: l.heightLabel,
                value: heightStr,
              ),
              const SizedBox(width: AppSpacing.sm),
              _StatCell(
                icon: Icons.fitness_center_rounded,
                iconColor: AppColors.success,
                label: l.equipmentLabel,
                value: onboarding.equipment?.label ?? '—',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(AppTheme.radius),
          border: Border.all(color: context.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 18),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: context.primaryText,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: context.tertiaryText,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Settings section ───────────────────────────────────────────────────────────

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.label, required this.items});

  final String label;
  final List<_SettingItem> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base, AppSpacing.base + AppSpacing.xs,
        AppSpacing.base, 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              label.toUpperCase(),
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: context.tertiaryText,
                letterSpacing: 1,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: context.surface,
              borderRadius: BorderRadius.circular(AppTheme.radius),
              border: Border.all(color: context.border),
            ),
            child: Column(
              children: items.asMap().entries.map((e) {
                final isLast = e.key == items.length - 1;
                return Column(
                  children: [
                    e.value,
                    if (!isLast)
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: context.border,
                        indent: 54,
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  const _SettingItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.value,
    this.labelColor,
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String? value;
  final Color? labelColor;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radius),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md + AppSpacing.xs,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withAlpha(38),
                borderRadius: BorderRadius.circular(AppTheme.radiusSM),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: labelColor ?? context.primaryText,
                ),
              ),
            ),
            if (trailing != null)
              trailing!
            else ...[
              if (value != null)
                Text(
                  value!,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: context.secondaryText,
                  ),
                ),
              if (onTap != null) ...[
                const SizedBox(width: AppSpacing.xs),
                Icon(
                  Icons.chevron_right_rounded,
                  color: context.tertiaryText,
                  size: 18,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

// ── Notification settings sheet ────────────────────────────────────────────────

class _NotificationSheet extends ConsumerWidget {
  const _NotificationSheet({required this.onPermissionDenied});

  final VoidCallback onPermissionDenied;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final settings = ref.watch(notificationSettingsProvider);
    final notifier = ref.read(notificationSettingsProvider.notifier);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.base, 0, AppSpacing.base, AppSpacing.base,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.surface3,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.base + AppSpacing.xs),
            Row(
              children: [
                Text(
                  l.notifications,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: context.primaryText,
                  ),
                ),
                const Spacer(),
                Switch(
                  value: settings.enabled,
                  activeColor: AppColors.accent,
                  onChanged: (val) async {
                    final ok = await notifier.setEnabled(
                      val,
                      title: l.notificationTitle,
                      body: l.notificationBody,
                    );
                    if (!ok) onPermissionDenied();
                  },
                ),
              ],
            ),
            if (settings.enabled) ...[
              Divider(height: 1, color: context.border),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  l.notificationReminderTime,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: context.primaryText,
                  ),
                ),
                trailing: Text(
                  settings.time.format(context),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: settings.time,
                  );
                  if (picked != null) {
                    await notifier.setTime(
                      picked,
                      title: l.notificationTitle,
                      body: l.notificationBody,
                    );
                  }
                },
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}

// ── Dark mode toggle ───────────────────────────────────────────────────────────

class _DarkModeToggle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    return GestureDetector(
      onTap: () {
        final newMode = isDark ? ThemeMode.light : ThemeMode.dark;
        ref.read(themeModeProvider.notifier).state = newMode;
        persistThemeMode(newMode);
      },
      child: AnimatedContainer(
        duration: AppDuration.medium,
        width: 48,
        height: 26,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          color: isDark ? AppColors.accent : context.surface3,
        ),
        child: AnimatedAlign(
          duration: AppDuration.medium,
          alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(3),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? Colors.black : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
