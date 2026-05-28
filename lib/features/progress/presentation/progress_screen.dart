import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/fp_card.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  int _rangeSel = 1; // 0=1M, 1=3M, 2=1Y

  // Dummy data
  static const _volumeData = [0.45, 0.52, 0.48, 0.60, 0.55, 0.70,
                                0.65, 0.78, 0.72, 0.85, 0.80, 0.95];
  static const _strengthData = [0.60, 0.65, 0.68, 0.72, 0.76, 0.80,
                                  0.83, 0.87, 0.85, 0.91, 0.95, 1.00];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Progress',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: context.primaryText,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    // Range selector
                    Row(
                      children: ['1M', '3M', '1Y'].asMap().entries.map((e) {
                        final isActive = _rangeSel == e.key;
                        return Padding(
                          padding: EdgeInsets.only(left: e.key > 0 ? 8 : 0),
                          child: GestureDetector(
                            onTap: () => setState(() => _rangeSel = e.key),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppColors.accentDim
                                    : context.surface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isActive
                                      ? AppColors.accent
                                      : context.border,
                                ),
                              ),
                              child: Text(
                                e.value,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isActive
                                      ? AppColors.accent
                                      : context.secondaryText,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms),
            ),

            // ── Volume chart ──
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              sliver: SliverToBoxAdapter(
                child: _ChartCard(
                  title: 'Volume Progression',
                  subtitle: 'Weekly training volume (kg total)',
                  data: _volumeData,
                  formatLabel: (v) => '${(v * 12).toStringAsFixed(0)}t',
                  showCurrentLabel: true,
                  currentValue: '8.4t',
                  delta: '+18%',
                  deltaPositive: true,
                ).animate(delay: 80.ms).fadeIn().slideY(begin: 0.06, curve: Curves.easeOut),
              ),
            ),

            // ── Strength chart ──
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              sliver: SliverToBoxAdapter(
                child: _ChartCard(
                  title: 'Bench Press 1RM',
                  subtitle: 'Estimated 1-rep max (kg)',
                  data: _strengthData,
                  formatLabel: (v) => '${(v * 107).toStringAsFixed(0)}',
                  showCurrentLabel: true,
                  currentValue: '107.5 kg',
                  delta: '+12.5 kg',
                  deltaPositive: true,
                ).animate(delay: 140.ms).fadeIn().slideY(begin: 0.06, curve: Curves.easeOut),
              ),
            ),

            // ── Body metrics ──
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Body Metrics',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: context.primaryText,
                            ),
                          ),
                        ),
                        Text(
                          'Edit',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.8,
                      children: const [
                        _MetricCard(value: '82',    unit: ' kg',  label: 'Body Weight',  delta: '+0.8 kg', positive: true),
                        _MetricCard(value: '16.2',  unit: '%',    label: 'Body Fat Est.', delta: '−1.4%',   positive: false),
                        _MetricCard(value: '44',    unit: ' cm',  label: 'Left Arm',      delta: '+1 cm',   positive: true),
                        _MetricCard(value: '99',    unit: ' cm',  label: 'Chest',         delta: '+2 cm',   positive: true),
                        _MetricCard(value: '73',    unit: ' cm',  label: 'Waist',         delta: '−2 cm',   positive: false),
                        _MetricCard(value: '58',    unit: ' cm',  label: 'Left Thigh',    delta: '+1 cm',   positive: true),
                      ],
                    ),
                  ],
                ).animate(delay: 200.ms).fadeIn(),
              ),
            ),

            // ── Progress photos ──
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Progress Photos',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: context.primaryText,
                            ),
                          ),
                        ),
                        Text(
                          '+ Add',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.7,
                      children: [
                        _PhotoCell(label: 'Week 1',  filled: true, gradient: [const Color(0xFF1A2A1A), const Color(0xFF0F1A0F)]),
                        _PhotoCell(label: 'Week 6',  filled: true, gradient: [const Color(0xFF1A2A2A), const Color(0xFF0F1A1A)]),
                        _PhotoCell(label: 'Week 12', filled: true, gradient: [const Color(0xFF2A2A1A), const Color(0xFF1A1A0F)]),
                        _PhotoCell(label: 'Add', filled: false),
                        _PhotoCell(label: 'Add', filled: false),
                        _PhotoCell(label: 'Add', filled: false),
                      ],
                    ),
                  ],
                ).animate(delay: 260.ms).fadeIn(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bar chart card ────────────────────────────────────────
class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.data,
    required this.formatLabel,
    this.showCurrentLabel = false,
    this.currentValue,
    this.delta,
    this.deltaPositive = true,
  });

  final String title;
  final String subtitle;
  final List<double> data;
  final String Function(double) formatLabel;
  final bool showCurrentLabel;
  final String? currentValue;
  final String? delta;
  final bool deltaPositive;

  @override
  Widget build(BuildContext context) {
    final labels = data.length == 12
        ? ['W1','W2','W3','W4','W5','W6','W7','W8','W9','W10','W11','W12']
        : List.generate(data.length, (i) => '${i + 1}');

    return FpCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: context.primaryText,
                        )),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: context.secondaryText,
                        )),
                  ],
                ),
              ),
              if (showCurrentLabel && currentValue != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      currentValue!,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.accent,
                      ),
                    ),
                    if (delta != null)
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: (deltaPositive ? AppColors.success : AppColors.danger)
                              .withAlpha(38),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          delta!,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: deltaPositive ? AppColors.success : AppColors.danger,
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Chart bars
          SizedBox(
            height: 90,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.asMap().entries.map((e) {
                final isLast = e.key == data.length - 1;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: e.key < data.length - 1 ? 3 : 0),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: e.value),
                      duration: Duration(milliseconds: 600 + e.key * 40),
                      curve: Curves.easeOutCubic,
                      builder: (_, v, __) => FractionallySizedBox(
                        alignment: Alignment.bottomCenter,
                        heightFactor: v.clamp(0.05, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isLast
                                ? AppColors.accent
                                : AppColors.accent.withAlpha(51),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 6),
          Row(
            children: labels.map((l) => Expanded(
              child: Text(
                l,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 9,
                  color: context.tertiaryText,
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

// ── Metric card ───────────────────────────────────────────
class _MetricCard extends StatelessWidget {
  const _MetricCard({
    super.key,
    required this.value,
    required this.unit,
    required this.label,
    required this.delta,
    required this.positive,
  });

  final String value;
  final String unit;
  final String label;
  final String delta;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    return FpCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.accent,
                    height: 1,
                  ),
                ),
                TextSpan(
                  text: unit,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: context.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: context.tertiaryText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            delta,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: positive ? AppColors.success : AppColors.danger,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Photo cell ────────────────────────────────────────────
class _PhotoCell extends StatelessWidget {
  const _PhotoCell({
    required this.label,
    required this.filled,
    this.gradient,
  });

  final String label;
  final bool filled;
  final List<Color>? gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        color: filled ? null : context.surface,
        gradient: filled && gradient != null
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradient!,
              )
            : null,
        border: Border.all(color: context.border),
      ),
      child: filled
          ? Stack(
              children: [
                Center(
                  child: Icon(Icons.person_outline_rounded,
                      color: context.border, size: 36),
                ),
                Positioned(
                  bottom: 8, left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(153),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_rounded, color: context.tertiaryText, size: 24),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: context.tertiaryText,
                  ),
                ),
              ],
            ),
    );
  }
}
