import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/fp_button.dart';
import '../../subscription/providers/subscription_provider.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  int _selectedPlan = 1; // 0=monthly 1=annual
  bool _loading = false;
  String? _error;

  Package? get _selectedPackage {
    final offerings = ref.read(offeringsProvider).valueOrNull;
    final current = offerings?.current;
    if (current == null) return null;
    final packages = current.availablePackages;
    if (packages.isEmpty) return null;
    if (_selectedPlan == 1) {
      return packages.firstWhere(
        (p) => p.packageType == PackageType.annual,
        orElse: () => packages.last,
      );
    }
    return packages.firstWhere(
      (p) => p.packageType == PackageType.monthly,
      orElse: () => packages.first,
    );
  }

  Future<void> _purchase() async {
    final package = _selectedPackage;
    if (package == null) {
      setState(() => _error = 'No products available yet. Check back soon.');
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() { _loading = true; _error = null; });
    try {
      final isPremium =
          await ref.read(subscriptionProvider.notifier).purchase(package);
      if (!mounted) return;
      if (isPremium) {
        HapticFeedback.heavyImpact();
        context.pop();
      }
    } catch (e) {
      setState(() => _error = 'Purchase failed. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _restore() async {
    setState(() { _loading = true; _error = null; });
    try {
      final restored =
          await ref.read(subscriptionProvider.notifier).restorePurchases();
      if (!mounted) return;
      if (restored) {
        HapticFeedback.heavyImpact();
        context.pop();
      } else {
        setState(() => _error = 'No previous purchases found.');
      }
    } catch (_) {
      setState(() => _error = 'Restore failed. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final offerings = ref.watch(offeringsProvider);
    final packages = offerings.valueOrNull?.current?.availablePackages ?? [];
    final hasProducts = packages.isNotEmpty;

    String monthlyPrice = '€14.99';
    String annualPrice  = '€89.99';
    String annualMonthly = '€7.50/mo';

    if (hasProducts) {
      final monthly = packages.firstWhere(
        (p) => p.packageType == PackageType.monthly,
        orElse: () => packages.first,
      );
      final annual = packages.firstWhere(
        (p) => p.packageType == PackageType.annual,
        orElse: () => packages.last,
      );
      monthlyPrice = monthly.storeProduct.priceString;
      annualPrice  = annual.storeProduct.priceString;
    }

    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Close ──
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
                  const Spacer(),
                  GestureDetector(
                    onTap: _loading ? null : _restore,
                    child: Text(
                      'Restore',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: context.tertiaryText,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Content ──
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  children: [
                    const Text('⚡', style: TextStyle(fontSize: 56))
                        .animate()
                        .scale(begin: const Offset(0.6, 0.6),
                            curve: Curves.easeOutBack)
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
                            price: monthlyPrice,
                            period: '/month',
                            isSelected: _selectedPlan == 0,
                            onTap: () => setState(() => _selectedPlan = 0),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _PlanCard(
                            name: 'Annual',
                            price: annualPrice,
                            period: '/year',
                            savings: 'Save 50%  ·  $annualMonthly',
                            isBestValue: true,
                            isSelected: _selectedPlan == 1,
                            onTap: () => setState(() => _selectedPlan = 1),
                          ),
                        ),
                      ],
                    ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.1),

                    const SizedBox(height: 24),

                    // ── Features ──
                    ...[
                      'All 12 expert-designed programs',
                      'Unlimited Custom Program Builder',
                      'Auto-progression & smart weights',
                      'Advanced analytics & insights',
                      'Full exercise video library (300+)',
                      'Priority support from Tasos',
                      'Offline mode & cloud sync',
                    ].asMap().entries.map((e) => _FeatureRow(label: e.value)
                        .animate(
                            delay:
                                Duration(milliseconds: 250 + e.key * 35))
                        .fadeIn()
                        .slideX(begin: -0.03, curve: Curves.easeOut)),

                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withAlpha(20),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppColors.danger.withAlpha(60)),
                        ),
                        child: Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: AppColors.danger,
                          ),
                        ),
                      ),
                    ],

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
                    label: _loading
                        ? 'Processing...'
                        : 'Start 7-Day Free Trial',
                    onPressed: _loading ? null : _purchase,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '7-day free trial, then ${_selectedPlan == 1 ? annualPrice + '/year' : monthlyPrice + '/month'}.\nCancel anytime. Terms & Privacy apply.',
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
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
                Text(
                  price,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: context.primaryText,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  period,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: context.secondaryText,
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
