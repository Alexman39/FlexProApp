import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../l10n/app_localizations.dart';
import '../constants/app_colors.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../../features/workout/domain/models.dart';

/// One card per set during an active workout session.
/// Visual states: pending (default border) → active (accent glow) → completed (success tint, locked).
class SetCard extends StatefulWidget {
  const SetCard({
    super.key,
    required this.set,
    this.onWeightChanged,
    this.onRepsChanged,
    this.onRpeChanged,
    this.onComplete,
  });

  final WorkoutSet set;
  final ValueChanged<double>? onWeightChanged;
  final ValueChanged<int>? onRepsChanged;
  final ValueChanged<double>? onRpeChanged;
  final VoidCallback? onComplete;

  @override
  State<SetCard> createState() => _SetCardState();
}

class _SetCardState extends State<SetCard> {
  late final TextEditingController _weightCtrl;
  late final TextEditingController _repsCtrl;

  static const List<double> _rpeValues = [6, 6.5, 7, 7.5, 8, 8.5, 9, 9.5, 10];

  @override
  void initState() {
    super.initState();
    _weightCtrl = TextEditingController(
      text: _fmtWeight(widget.set.loggedWeight ?? widget.set.targetWeight),
    );
    _repsCtrl = TextEditingController(
      text: (widget.set.loggedReps ?? widget.set.targetReps)?.toString() ?? '',
    );
  }

  static String _fmtWeight(double? w) {
    if (w == null) return '';
    return w % 1 == 0 ? w.toInt().toString() : w.toString();
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    _repsCtrl.dispose();
    super.dispose();
  }

  bool get _isCompleted => widget.set.status == SetStatus.completed;
  bool get _isActive => widget.set.status == SetStatus.active;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    final Color borderColor;
    final Color cardColor;
    final double borderWidth;
    final List<BoxShadow>? shadows;

    if (_isCompleted) {
      borderColor = AppColors.success.withValues(alpha: 0.35);
      cardColor = AppColors.success.withValues(alpha: isDark ? 0.07 : 0.04);
      borderWidth = 1.5;
      shadows = null;
    } else if (_isActive) {
      borderColor = AppColors.accent.withValues(alpha: 0.65);
      cardColor = context.surface;
      borderWidth = 1.5;
      shadows = AppShadow.accentGlow;
    } else {
      borderColor = context.border;
      cardColor = context.surface;
      borderWidth = 1.0;
      shadows = null;
    }

    return AnimatedContainer(
      duration: AppDuration.medium,
      curve: AppCurve.standard,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: AppRadius.card,
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: shadows,
      ),
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SetHeader(set: widget.set, isCompleted: _isCompleted),
          const SizedBox(height: AppSpacing.md),
          _InputRow(
            weightCtrl: _weightCtrl,
            repsCtrl: _repsCtrl,
            set: widget.set,
            enabled: !_isCompleted,
            onWeightChanged: widget.onWeightChanged,
            onRepsChanged: widget.onRepsChanged,
          ),
          const SizedBox(height: AppSpacing.md),
          _RpeSelector(
            selected: widget.set.loggedRpe ?? widget.set.rpe,
            values: _rpeValues,
            enabled: !_isCompleted,
            onSelected: widget.onRpeChanged,
          ),
          if (!_isCompleted) ...[
            const SizedBox(height: AppSpacing.md),
            _CompleteButton(isActive: _isActive, onTap: widget.onComplete),
          ],
        ],
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _SetHeader extends StatelessWidget {
  const _SetHeader({required this.set, required this.isCompleted});

  final WorkoutSet set;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final setNum = set.index + 1;

    return Row(
      children: [
        _SetBadge(number: setNum, isCompleted: isCompleted),
        const SizedBox(width: AppSpacing.sm),
        Text(
          l10n.setNumber(setNum),
          style: GoogleFonts.inter(
            fontSize: AppTypeScale.bodyMd,
            fontWeight: FontWeight.w700,
            color: context.primaryText,
          ),
        ),
        const Spacer(),
        if (isCompleted)
          _DoneChip(label: l10n.done)
        else
          _TargetLabel(set: set),
      ],
    );
  }
}

class _SetBadge extends StatelessWidget {
  const _SetBadge({required this.number, required this.isCompleted});

  final int number;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppDuration.medium,
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isCompleted
            ? AppColors.success.withValues(alpha: 0.15)
            : AppColors.accentDim,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check_rounded, size: 18, color: AppColors.success)
            : Text(
                '$number',
                style: GoogleFonts.inter(
                  fontSize: AppTypeScale.labelLg,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                ),
              ),
      ),
    );
  }
}

class _DoneChip extends StatelessWidget {
  const _DoneChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.12),
        borderRadius: AppRadius.chip,
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: AppTypeScale.labelMd,
          fontWeight: FontWeight.w700,
          color: AppColors.success,
        ),
      ),
    );
  }
}

class _TargetLabel extends StatelessWidget {
  const _TargetLabel({required this.set});

  final WorkoutSet set;

  @override
  Widget build(BuildContext context) {
    final parts = <String>[];
    if (set.targetWeight != null) {
      final w = set.targetWeight!;
      parts.add('${w % 1 == 0 ? w.toInt() : w} kg');
    }
    if (set.targetReps != null) parts.add('× ${set.targetReps}');
    if (parts.isEmpty) return const SizedBox.shrink();

    return Text(
      parts.join(' '),
      style: GoogleFonts.inter(
        fontSize: AppTypeScale.labelMd,
        fontWeight: FontWeight.w500,
        color: context.secondaryText,
      ),
    );
  }
}

// ─── Input row ────────────────────────────────────────────────────────────────

class _InputRow extends StatelessWidget {
  const _InputRow({
    required this.weightCtrl,
    required this.repsCtrl,
    required this.set,
    required this.enabled,
    this.onWeightChanged,
    this.onRepsChanged,
  });

  final TextEditingController weightCtrl;
  final TextEditingController repsCtrl;
  final WorkoutSet set;
  final bool enabled;
  final ValueChanged<double>? onWeightChanged;
  final ValueChanged<int>? onRepsChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _NumericField(
            controller: weightCtrl,
            label: l10n.weightLabel,
            suffix: 'kg',
            hint: set.targetWeight?.toInt().toString() ?? '—',
            enabled: enabled,
            decimal: true,
            onChanged: (v) {
              final n = double.tryParse(v);
              if (n != null) onWeightChanged?.call(n);
            },
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _NumericField(
            controller: repsCtrl,
            label: l10n.repsLabel,
            suffix: '',
            hint: set.targetReps?.toString() ?? '—',
            enabled: enabled,
            decimal: false,
            onChanged: (v) {
              final n = int.tryParse(v);
              if (n != null) onRepsChanged?.call(n);
            },
          ),
        ),
      ],
    );
  }
}

class _NumericField extends StatelessWidget {
  const _NumericField({
    required this.controller,
    required this.label,
    required this.suffix,
    required this.hint,
    required this.enabled,
    required this.decimal,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String suffix;
  final String hint;
  final bool enabled;
  final bool decimal;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: AppTypeScale.labelSm,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
            color: context.secondaryText,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        SizedBox(
          height: 56,
          child: TextField(
            controller: controller,
            enabled: enabled,
            keyboardType: TextInputType.numberWithOptions(
              decimal: decimal,
              signed: false,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                decimal ? RegExp(r'[0-9.]') : RegExp(r'[0-9]'),
              ),
            ],
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: AppTypeScale.headMd,
              fontWeight: FontWeight.w700,
              color: enabled ? context.primaryText : context.secondaryText,
            ),
            decoration: InputDecoration(
              hintText: hint,
              suffixText: suffix.isNotEmpty ? suffix : null,
              suffixStyle: GoogleFonts.inter(
                fontSize: AppTypeScale.bodyMd,
                fontWeight: FontWeight.w500,
                color: context.secondaryText,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.md,
              ),
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

// ─── RPE selector ─────────────────────────────────────────────────────────────

class _RpeSelector extends StatelessWidget {
  const _RpeSelector({
    required this.selected,
    required this.values,
    required this.enabled,
    this.onSelected,
  });

  final double? selected;
  final List<double> values;
  final bool enabled;
  final ValueChanged<double>? onSelected;

  static String _label(double v) =>
      v % 1 == 0 ? v.toInt().toString() : v.toString();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.rpeLabel,
          style: GoogleFonts.inter(
            fontSize: AppTypeScale.labelSm,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
            color: context.secondaryText,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: values.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xs),
            itemBuilder: (context, i) {
              final v = values[i];
              return _RpeChip(
                label: _label(v),
                isSelected: selected == v,
                enabled: enabled,
                onTap: enabled ? () => onSelected?.call(v) : null,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RpeChip extends StatelessWidget {
  const _RpeChip({
    required this.label,
    required this.isSelected,
    required this.enabled,
    this.onTap,
  });

  final String label;
  final bool isSelected;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDuration.fast,
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : context.surface2,
          borderRadius: AppRadius.chip,
          border: Border.all(
            color: isSelected ? AppColors.accent : context.border,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: AppTypeScale.labelMd,
              fontWeight: FontWeight.w700,
              color: isSelected
                  ? Colors.black
                  : (enabled ? context.primaryText : context.tertiaryText),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Complete button ──────────────────────────────────────────────────────────

class _CompleteButton extends StatelessWidget {
  const _CompleteButton({required this.isActive, this.onTap});

  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? AppColors.accent : AppColors.accentDim,
          foregroundColor: isActive ? Colors.black : AppColors.accent,
          elevation: 0,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
        ),
        child: Text(
          isActive ? l10n.completeSet : l10n.markComplete,
          style: GoogleFonts.inter(
            fontSize: AppTypeScale.bodyLg,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
