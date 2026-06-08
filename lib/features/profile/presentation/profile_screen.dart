import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:flexpro_coaching/l10n/app_localizations.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/fp_card.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/providers/auth_providers.dart';

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
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: context.surface3,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          for (final entry in const [('English', 'en'), ('Ελληνικά', 'el')])
            ListTile(
              title: Text(entry.$1,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    color: context.primaryText,
                  )),
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

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appUser = ref.watch(appUserProvider).valueOrNull;
    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header card ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: _ProfileHeroCard(
                  name: appUser?.displayName ?? 'Athlete',
                  email: appUser?.email ?? '',
                  initials: (appUser?.firstName ?? 'A')[0].toUpperCase(),
                ).animate().fadeIn(duration: 300.ms),
              ),
            ),

            // ── Premium banner ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: _PremiumBanner()
                    .animate(delay: 80.ms)
                    .fadeIn(duration: 300.ms),
              ),
            ),

            // ── Settings sections ──
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Builder(builder: (context) {
                    final l = AppLocalizations.of(context)!;
                    final locale = ref.watch(localeProvider);
                    final langLabel = locale.languageCode == 'el' ? 'Ελληνικά' : 'English';
                    return Column(
                      children: [
                        _SettingsSection(
                          label: l.account,
                          items: [
                            _SettingItem(icon: '👤', iconBg: AppColors.accentDim,
                                label: l.editProfile, onTap: () {}),
                            _SettingItem(icon: '🎯', iconBg: AppColors.accentDim,
                                label: l.myGoals, value: 'Hypertrophy', onTap: () {}),
                            _SettingItem(icon: '📊', iconBg: const Color(0x262ECC71),
                                label: l.bodyStats, value: '82 kg · 178 cm', onTap: () {}),
                          ],
                        ).animate(delay: 140.ms).fadeIn(),

                        _SettingsSection(
                          label: l.preferences,
                          items: [
                            _SettingItem(
                              icon: '🌙',
                              iconBg: AppColors.accentDim,
                              label: l.appearance,
                              trailing: _DarkModeToggle(),
                            ),
                            _SettingItem(
                              icon: '🌍',
                              iconBg: const Color(0x26F39C12),
                              label: l.language,
                              value: langLabel,
                              onTap: () => _showLanguagePicker(context, ref),
                            ),
                            _SettingItem(icon: '🔔', iconBg: AppColors.accentDim,
                                label: l.notifications, value: 'On', onTap: () {}),
                            _SettingItem(icon: '⚖️', iconBg: AppColors.accentDim,
                                label: l.units, value: 'Metric (kg)', onTap: () {}),
                          ],
                        ).animate(delay: 180.ms).fadeIn(),

                        _SettingsSection(
                          label: l.support,
                          items: [
                            _SettingItem(icon: '❓', iconBg: const Color(0x262ECC71),
                                label: l.helpFaq, onTap: () {}),
                            _SettingItem(icon: '📧', iconBg: const Color(0x26F39C12),
                                label: l.contactTasos,
                                onTap: () => context.push(AppRoutes.coachProfile)),
                            _SettingItem(icon: '📋', iconBg: AppColors.accentDim,
                                label: l.privacyPolicy, onTap: () {}),
                            _SettingItem(
                              icon: '🚪',
                              iconBg: const Color(0x26FF4757),
                              label: l.signOut,
                              labelColor: AppColors.danger,
                              onTap: () async {
                                await ref.read(authRepositoryProvider)?.signOut();
                                if (context.mounted) context.go(AppRoutes.login);
                              },
                            ),
                          ],
                        ).animate(delay: 220.ms).fadeIn(),
                      ],
                    );
                  }),
                ],
              ),
            ),

            // ── Footer ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                child: Column(
                  children: [
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
                    const SizedBox(height: 6),
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Profile hero card ─────────────────────────────────────
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
    return FpCard(
      gradient: AppColors.heroCardGradient,
      borderColor: AppColors.accent.withAlpha(38),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 68, height: 68,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.accent, Color(0xFF66F0FF)],
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
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
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
                  'Member since Jan 2025',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: Colors.white.withAlpha(102),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.edit_rounded,
              color: AppColors.accent, size: 18),
        ],
      ),
    );
  }
}

// ── Premium banner ────────────────────────────────────────
class _PremiumBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.paywall),
      child: Container(
        padding: const EdgeInsets.all(18),
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
            const Text('⚡', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 14),
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
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.accent, size: 22),
          ],
        ),
      ),
    );
  }
}

// ── Settings section ──────────────────────────────────────
class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.label, required this.items});

  final String label;
  final List<_SettingItem> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
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
                    if (!isLast) Divider(
                      height: 1, thickness: 1,
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
    required this.iconBg,
    required this.label,
    this.value,
    this.labelColor,
    this.onTap,
    this.trailing,
  });

  final String icon;
  final Color iconBg;
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(width: 14),
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
            if (trailing != null) trailing!
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
                const SizedBox(width: 4),
                Icon(Icons.chevron_right_rounded,
                    color: context.tertiaryText, size: 18),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

// ── Dark mode toggle ──────────────────────────────────────
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
        duration: const Duration(milliseconds: 250),
        width: 48, height: 26,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          color: isDark ? AppColors.accent : context.surface3,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 250),
          alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(3),
            width: 20, height: 20,
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
