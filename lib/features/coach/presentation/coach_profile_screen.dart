import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/fp_card.dart';

class CoachProfileScreen extends StatelessWidget {
  const CoachProfileScreen({super.key});

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Hero ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Stack(
              children: [
                // Gradient banner
                Container(
                  height: 260,
                  decoration: const BoxDecoration(
                    gradient: AppColors.accentCardGradient,
                  ),
                  child: Stack(
                    children: [
                      // Glow
                      Positioned(
                        right: -40, top: -40,
                        child: Container(
                          width: 240, height: 240,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppColors.accent.withAlpha(38),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Back button
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 8,
                        left: 16,
                        child: GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(77),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              border: Border.all(
                                  color: Colors.white.withAlpha(38)),
                            ),
                            child: const Icon(Icons.arrow_back_ios_rounded,
                                size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Avatar + name card
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Avatar
                        Container(
                          width: 96, height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [AppColors.accent, AppColors.accentLight],
                            ),
                            border: Border.all(
                                color: context.bg, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accent.withAlpha(51),
                                blurRadius: 24,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'T',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Name + title ──────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                children: [
                  Text(
                    'Tasos Misailidis',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: context.primaryText,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(duration: 300.ms),
                  const SizedBox(height: 4),
                  Text(
                    'Fitness Specialist · Personal Trainer · Nutrition Coach',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ).animate(delay: 60.ms).fadeIn(),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on_rounded,
                          size: 13, color: AppColors.accent),
                      const SizedBox(width: 3),
                      Text(
                        'Flexapil Studio, Elliniko, Athens',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: context.secondaryText,
                        ),
                      ),
                    ],
                  ).animate(delay: 80.ms).fadeIn(),
                ],
              ),
            ),
          ),

          // ── Stats row ─────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  _StatBubble(value: '25+', label: 'Years Exp.'),
                  const SizedBox(width: 10),
                  _StatBubble(value: '500+', label: 'Athletes'),
                  const SizedBox(width: 10),
                  _StatBubble(value: '12', label: 'Programs'),
                ],
              ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.06),
            ),
          ),

          // ── Bio ───────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            sliver: SliverToBoxAdapter(
              child: FpCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(title: 'About'),
                    const SizedBox(height: 12),
                    Text(
                      'Tasos Misailidis is a fitness specialist, personal trainer, and nutrition coach with more than 25 years of experience in the health and fitness industry. Having worked with professional athletes, celebrities, and everyday people looking to transform their lifestyle, his philosophy focuses on sustainable results through intelligent training, proper nutrition, discipline, and consistency.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: context.secondaryText,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'As the founder of Flexapil, he has created a modern training environment centered around functional performance, fat loss, strength development, and long-term health.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: context.secondaryText,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 140.ms).fadeIn().slideY(begin: 0.06),
            ),
          ),

          // ── Credentials ───────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            sliver: SliverToBoxAdapter(
              child: FpCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(title: 'Experience & Credentials'),
                    const SizedBox(height: 12),
                    ...[
                      (Icons.military_tech_rounded, '25+ years in fitness, personal training & nutrition'),
                      (Icons.place_rounded, 'Founder of Flexapil training studio, Elliniko Athens'),
                      (Icons.people_rounded, 'Coached professional athletes and public figures'),
                      (Icons.trending_up_rounded, 'Specialized in fat loss, body transformation & strength'),
                      (Icons.eco_rounded, 'Lifestyle coaching & nutrition programming'),
                    ].map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(e.$1, size: 18, color: AppColors.accent),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              e.$2,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                color: context.secondaryText,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ).animate(delay: 180.ms).fadeIn().slideY(begin: 0.06),
            ),
          ),

          // ── Connect ───────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            sliver: SliverToBoxAdapter(
              child: FpCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(title: 'Connect with Tasos'),
                    const SizedBox(height: 14),
                    _LinkButton(
                      icon: Icons.camera_alt_rounded,
                      label: 'Instagram',
                      subtitle: '@tasosmisailidis',
                      color: AppColors.instagramPink,
                      onTap: () => _launch('https://www.instagram.com/tasosmisailidis'),
                    ),
                    const SizedBox(height: 10),
                    _LinkButton(
                      icon: Icons.language_rounded,
                      label: 'Flexapil Website',
                      subtitle: 'flexapilgym.gr',
                      color: AppColors.accent,
                      onTap: () => _launch('https://flexapilgym.gr'),
                    ),
                    const SizedBox(height: 10),
                    _LinkButton(
                      icon: Icons.mail_rounded,
                      label: 'Contact for Coaching',
                      subtitle: 'Book a consultation via the website',
                      color: AppColors.success,
                      onTap: () => _launch('https://flexapilgym.gr'),
                    ),
                  ],
                ),
              ).animate(delay: 220.ms).fadeIn().slideY(begin: 0.06),
            ),
          ),

          // ── Footer ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Text(
                '"Sustainable results through intelligent training,\nproper nutrition, discipline, and consistency."',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: context.tertiaryText,
                  fontStyle: FontStyle.italic,
                  height: 1.6,
                ),
              ).animate(delay: 260.ms).fadeIn(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: context.primaryText,
      ),
    );
  }
}

class _StatBubble extends StatelessWidget {
  const _StatBubble({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FpCard(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.accent,
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
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LinkButton extends StatelessWidget {
  const _LinkButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          border: Border.all(color: color.withAlpha(51)),
        ),
        child: Row(
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: color.withAlpha(26),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: context.primaryText,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: context.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: color),
          ],
        ),
      ),
    );
  }
}
