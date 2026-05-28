import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';

enum FpButtonVariant { primary, secondary, ghost, danger }
enum FpButtonSize    { large, medium, small }

class FpButton extends StatefulWidget {
  const FpButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant  = FpButtonVariant.primary,
    this.size     = FpButtonSize.large,
    this.icon,
    this.trailing,
    this.isLoading = false,
    this.expand    = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final FpButtonVariant variant;
  final FpButtonSize    size;
  final Widget? icon;
  final Widget? trailing;
  final bool isLoading;
  final bool expand;

  @override
  State<FpButton> createState() => _FpButtonState();
}

class _FpButtonState extends State<FpButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 80),
    lowerBound: 0.0,
    upperBound: 0.04,
  );

  void _onTapDown(_) => _ctrl.forward();
  void _onTapUp(_) {
    _ctrl.reverse();
    HapticFeedback.lightImpact();
    widget.onPressed?.call();
  }
  void _onTapCancel() => _ctrl.reverse();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onPressed == null && !widget.isLoading) {
      return _buildBody(context, disabled: true);
    }
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) => Transform.scale(
          scale: 1.0 - _ctrl.value,
          child: child,
        ),
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context, {bool disabled = false}) {
    final (bg, fg, borderColor) = _resolveColors(context, disabled);
    final (h, fs) = _resolveSize();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: widget.expand ? double.infinity : null,
      height: h,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: borderColor != null ? Border.all(color: borderColor) : null,
        boxShadow: widget.variant == FpButtonVariant.primary && !disabled
            ? [BoxShadow(color: AppColors.accentGlow, blurRadius: 20, offset: const Offset(0, 4))]
            : null,
      ),
      child: widget.isLoading
          ? Center(
              child: SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: fg,
                ),
              ),
            )
          : Row(
              mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  IconTheme(data: IconThemeData(color: fg, size: 18), child: widget.icon!),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: fs,
                    fontWeight: FontWeight.w700,
                    color: fg,
                    letterSpacing: 0.2,
                  ),
                ),
                if (widget.trailing != null) ...[
                  const SizedBox(width: 8),
                  IconTheme(data: IconThemeData(color: fg, size: 18), child: widget.trailing!),
                ],
              ],
            ),
    );
  }

  (Color bg, Color fg, Color? border) _resolveColors(
      BuildContext context, bool disabled) {
    if (disabled) {
      return (context.surface2, context.tertiaryText, null);
    }
    return switch (widget.variant) {
      FpButtonVariant.primary   => (AppColors.accent, Colors.black, null),
      FpButtonVariant.secondary => (context.surface, context.primaryText, context.border),
      FpButtonVariant.ghost     => (Colors.transparent, context.secondaryText, null),
      FpButtonVariant.danger    => (AppColors.danger.withAlpha(26), AppColors.danger, AppColors.danger.withAlpha(77)),
    };
  }

  (double h, double fs) _resolveSize() => switch (widget.size) {
    FpButtonSize.large  => (52.0, 16.0),
    FpButtonSize.medium => (44.0, 15.0),
    FpButtonSize.small  => (36.0, 13.0),
  };
}
