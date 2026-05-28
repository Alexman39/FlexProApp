import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/fp_button.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  int _selectedPlan = 1; // 0=monthly, 1=annual

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Close button ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: context.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: context.border),
                      ),
                      child: Text(
                        '✕ Close',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: context.secondaryText,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Scrollable content ──
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  children: [
                    // Hero
                    const Text('⚡', style: TextStyle(fontSize: 56))
                        .animate()
                        .scale(begin: const Offset(0.6, 0.6), curve: Curves.easeOutBack)
                        .fadeIn(),
                    const SizedBox(height: 16),

                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'Unlock ',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFF0F0F0),
                              letterSpacing: -0.5,
                            ),
                          ),
                          TextSpan(
                            text: 'FlexPro',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: AppColors.accent,
                              letterSpacing: -0.5,
                            ),
                          ),
                          TextSpan(
                            text: '\nPremium',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFF0F0F0),
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.1),

                    const SizedBox(height: 10),
                    Text(
                      'Access all 12 programs, unlimited custom builder,\nadvanced analytics, and auto-progression.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: context.secondaryText,
                        height: 1.5,
                      ),
                    ).animate(delay: 150.ms).fadeIn(),

                    const SizedBox(height: 28),

                    // ── Plan selector ──
                    Row(
                      children: [
                        Expanded(
                          child: _PlanCard(
                            name: 'Monthly',
                            price: '14.99',
                            period: '/month',
                            isSelected: _selectedPlan == 0,
                            onTap: () => setState(() => _selectedPlan = 0),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _PlanCard(
                            name: 'Annual',
                            price: '89.99',
                            period: '/year',
                            savings: 'Save 50%  ·  €7.50/mo',
                            isBestValue: true,
                            isSelected: _selectedPlan == 1,
                            onTap: () => setState(() => _selectedPlan = 1),
                          ),
                        ),
                      ],
                    ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.1),

                    const SizedBox(height: 24),

                    // ── Feature list ──
                    ...[
                      'All 12 expert-designed programs',
                      'Unlimited Custom Program Builder',
                      'Auto-progression & smart weights',
                      'Advanced analytics & insights',
                      'Full exercise video library (300+)',
                      'Priority support from Tasos',
                      'Offline mode & cloud sync',
                    ].asMap().entries.map((e) => _FeatureRow(
                      label: e.value,
                    ).animate(delay: Duration(milliseconds: 250 + e.key * 35))
                        .fadeIn()
                        .slideX(begin: -0.03, curve: Curves.easeOut)),

                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),

            // ── CTA ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Column(
                children: [
                  FpButton(
                    label: 'Start 7-Day Free Trial',
                    onPressed: () {
                      context.pop();
                      // TODO: trigger RevenueCat purchase
                    },
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '7-day free trial, then €${_selectedPlan == 1 ? '89.99/year' : '14.99/month'}.\nCancel anytime. Terms & Privacy apply.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: context.tertiaryText,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Plan card ─────────────────────────────────────────────
class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.name,
    required this.price,
    required this.period,
    required this.isSelected,
    required this.onTap,
    this.savings,
    this.isBestValue = false,
  });

  final String name;
  final String price;
  final String period;
  final String? savings;
  final bool isBestValue;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentDim : context.surface,
          borderRadius: BorderRadius.circular(AppTheme.radius),
          border: Border.all(
            color: isSelected ? AppColors.accent : context.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (isBestValue)
              Positioned(
                top: -24, right: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'BEST VALUE',
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: context.secondaryText,
                  ),
                ),
                const SizedBox(height: 6),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '€',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: context.secondaryText,
                        ),
                      ),
                      TextSpan(
                        text: price,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: context.primaryText,
                          letterSpacing: -0.5,
                        ),
                      ),
                      TextSpan(
                        text: period,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: context.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                if (savings != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    savings!,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Feature row ───────────────────────────────────────────
class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded,
              color: AppColors.accent, size: 18),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: context.secondaryText,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
