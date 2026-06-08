import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flexpro_coaching/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/fp_button.dart';
import '../domain/onboarding_models.dart';
import '../providers/onboarding_provider.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final step = ref.watch(onboardingStepProvider);
    final data = ref.watch(onboardingProvider);

    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Progress dots ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: _ProgressDots(currentStep: step, totalSteps: 5),
            ),
            const SizedBox(height: 8),

            // ── Step content ──
            Expanded(
              child: AnimatedSwitcher(
                duration: 300.ms,
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.06, 0),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: _stepWidget(step, data, ref)
                    .animate(key: ValueKey(step))
                    .fadeIn(duration: 250.ms)
                    .slideX(begin: 0.04, curve: Curves.easeOut),
              ),
            ),

            // ── Footer buttons ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                children: [
                  FpButton(
                    label: step == 4 ? l.getMyProgram : l.continueBtn,
                    onPressed: _canContinue(step, data)
                        ? () => _onContinue(context, ref, step, data)
                        : null,
                  ),
                  const SizedBox(height: 10),
                  FpButton(
                    label: step == 4 ? l.skipStats : l.skip,
                    variant: FpButtonVariant.ghost,
                    size: FpButtonSize.medium,
                    onPressed: () => _onContinue(context, ref, step, data, skip: true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canContinue(int step, OnboardingData data) {
    return switch (step) {
      0 => data.goal != null,
      1 => data.experience != null,
      2 => data.daysPerWeek != null,
      3 => data.equipment != null,
      _ => true,
    };
  }

  void _onContinue(BuildContext context, WidgetRef ref, int step,
      OnboardingData data, {bool skip = false}) {
    HapticFeedback.lightImpact();
    if (step == 4) {
      ref.read(onboardingProvider.notifier).complete();
      context.go(AppRoutes.home);
    } else {
      ref.read(onboardingStepProvider.notifier).next();
    }
  }

  Widget _stepWidget(int step, OnboardingData data, WidgetRef ref) {
    return switch (step) {
      0 => _GoalStep(selected: data.goal, onSelect: (g) => ref.read(onboardingProvider.notifier).setGoal(g)),
      1 => _ExperienceStep(selected: data.experience, onSelect: (e) => ref.read(onboardingProvider.notifier).setExperience(e)),
      2 => _DaysStep(selected: data.daysPerWeek, onSelect: (d) => ref.read(onboardingProvider.notifier).setDays(d)),
      3 => _EquipmentStep(selected: data.equipment, onSelect: (e) => ref.read(onboardingProvider.notifier).setEquipment(e)),
      _ => _StatsStep(data: data, onUpdate: ref.read(onboardingProvider.notifier).setStats),
    };
  }
}

// ── Progress dots ────────────────────────────────────────
class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.currentStep, required this.totalSteps});

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (i) {
        final isDone   = i < currentStep;
        final isActive = i == currentStep;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < totalSteps - 1 ? 6 : 0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: isDone || isActive
                    ? (isDone ? AppColors.accent : AppColors.accent.withAlpha(153))
                    : context.surface3,
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ── Step heading ──────────────────────────────────────────
class _StepHeading extends StatelessWidget {
  const _StepHeading({required this.question, required this.accent, this.hint});

  final String question;
  final String accent;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                height: 1.2,
                color: context.primaryText,
              ),
              children: [
                TextSpan(text: question),
                TextSpan(
                  text: accent,
                  style: const TextStyle(color: AppColors.accent),
                ),
              ],
            ),
          ),
          if (hint != null) ...[
            const SizedBox(height: 8),
            Text(
              hint!,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: context.secondaryText,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Option tile ───────────────────────────────────────────
class _OptionTile<T> extends StatelessWidget {
  const _OptionTile({
    super.key,
    required this.emoji,
    required this.label,
    required this.description,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final String description;
  final T value;
  final T? selected;
  final void Function(T) onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap(value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentDim : context.surface,
          borderRadius: BorderRadius.circular(AppTheme.radius),
          border: Border.all(
            color: isSelected ? AppColors.accent : context.border,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: AppColors.accentGlow, blurRadius: 12)]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: context.surface2,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: context.primaryText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: context.secondaryText,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.accent, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Step 0: Goal ─────────────────────────────────────────
class _GoalStep extends StatelessWidget {
  const _GoalStep({required this.selected, required this.onSelect});

  final TrainingGoal? selected;
  final void Function(TrainingGoal) onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepHeading(
          question: "What's your ",
          accent: 'primary goal?',
          hint: "We'll build your personalized program around this.",
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            children: TrainingGoal.values.map((g) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _OptionTile(
                emoji: g.emoji,
                label: g.label,
                description: g.description,
                value: g,
                selected: selected,
                onTap: onSelect,
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }
}

// ── Step 1: Experience ────────────────────────────────────
class _ExperienceStep extends StatelessWidget {
  const _ExperienceStep({required this.selected, required this.onSelect});

  final ExperienceLevel? selected;
  final void Function(ExperienceLevel) onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepHeading(
          question: 'Your ',
          accent: 'training experience?',
          hint: "This determines your program's complexity and volume.",
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            children: ExperienceLevel.values.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _OptionTile(
                emoji: e.emoji,
                label: e.label,
                description: e.description,
                value: e,
                selected: selected,
                onTap: onSelect,
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }
}

// ── Step 2: Days per week ─────────────────────────────────
class _DaysStep extends StatelessWidget {
  const _DaysStep({required this.selected, required this.onSelect});

  final int? selected;
  final void Function(int) onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepHeading(
          question: 'How many ',
          accent: 'days per week?',
          hint: "Be realistic — consistency beats intensity.",
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [3, 4, 5, 6].map((d) {
              final isSelected = selected == d;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: d < 6 ? 10 : 0),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onSelect(d);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 90,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.accentDim : context.surface,
                        borderRadius: BorderRadius.circular(AppTheme.radius),
                        border: Border.all(
                          color: isSelected ? AppColors.accent : context.border,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$d',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: isSelected ? AppColors.accent : context.primaryText,
                            ),
                          ),
                          Text(
                            'days',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? AppColors.accent : context.tertiaryText,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ── Step 3: Equipment ─────────────────────────────────────
class _EquipmentStep extends StatelessWidget {
  const _EquipmentStep({required this.selected, required this.onSelect});

  final EquipmentAccess? selected;
  final void Function(EquipmentAccess) onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepHeading(
          question: 'What ',
          accent: 'equipment do you have?',
          hint: "We'll only recommend exercises you can actually do.",
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            children: EquipmentAccess.values.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _OptionTile(
                emoji: e.emoji,
                label: e.label,
                description: e.description,
                value: e,
                selected: selected,
                onTap: onSelect,
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }
}

// ── Step 4: Stats ─────────────────────────────────────────
class _StatsStep extends StatefulWidget {
  const _StatsStep({required this.data, required this.onUpdate});

  final OnboardingData data;
  final void Function({int? age, double? weightKg, double? heightCm}) onUpdate;

  @override
  State<_StatsStep> createState() => _StatsStepState();
}

class _StatsStepState extends State<_StatsStep> {
  late final TextEditingController _age    = TextEditingController(text: widget.data.age?.toString());
  late final TextEditingController _weight = TextEditingController(text: widget.data.weightKg?.toString());
  late final TextEditingController _height = TextEditingController(text: widget.data.heightCm?.toString());
  Gender _gender = Gender.male;

  void _commit() {
    widget.onUpdate(
      age:       int.tryParse(_age.text),
      weightKg:  double.tryParse(_weight.text),
      heightCm:  double.tryParse(_height.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepHeading(
            question: 'Your ',
            accent: 'body stats',
            hint: 'Used to calculate volume and track progress. Optional.',
          ),
          const SizedBox(height: 8),

          // Gender selector
          Row(
            children: [
              _GenderBtn(label: 'Male',   selected: _gender == Gender.male,
                onTap: () => setState(() { _gender = Gender.male; })),
              const SizedBox(width: 12),
              _GenderBtn(label: 'Female', selected: _gender == Gender.female,
                onTap: () => setState(() { _gender = Gender.female; })),
            ],
          ),
          const SizedBox(height: 16),

          _StatInput(label: 'AGE',          hint: 'e.g. 28',  ctrl: _age,    onChanged: (_) => _commit(), keyboard: TextInputType.number),
          const SizedBox(height: 12),
          _StatInput(label: 'WEIGHT (kg)',  hint: 'e.g. 80',  ctrl: _weight, onChanged: (_) => _commit(), keyboard: TextInputType.numberWithOptions(decimal: true)),
          const SizedBox(height: 12),
          _StatInput(label: 'HEIGHT (cm)',  hint: 'e.g. 178', ctrl: _height, onChanged: (_) => _commit(), keyboard: TextInputType.number),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.accentDim,
              borderRadius: BorderRadius.circular(AppTheme.radiusSM),
            ),
            child: Row(
              children: [
                const Text('ℹ️', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'FlexPro Coaching is not a substitute for professional medical advice. Consult your physician before starting any new training program.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: context.secondaryText,
                      height: 1.5,
                    ),
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

class _GenderBtn extends StatelessWidget {
  const _GenderBtn({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.accentDim : context.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusSM),
            border: Border.all(
              color: selected ? AppColors.accent : context.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: selected ? AppColors.accent : context.secondaryText,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatInput extends StatelessWidget {
  const _StatInput({
    required this.label,
    required this.hint,
    required this.ctrl,
    required this.onChanged,
    required this.keyboard,
  });

  final String label;
  final String hint;
  final TextEditingController ctrl;
  final void Function(String) onChanged;
  final TextInputType keyboard;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: context.secondaryText,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          onChanged: onChanged,
          keyboardType: keyboard,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: context.primaryText,
          ),
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}
