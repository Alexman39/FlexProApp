import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';

/// Premium card with optional press animation and gradient support.
class FpCard extends StatefulWidget {
  const FpCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.borderRadius,
    this.gradient,
    this.borderColor,
    this.margin,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final Gradient? gradient;
  final Color? borderColor;
  final EdgeInsetsGeometry? margin;

  @override
  State<FpCard> createState() => _FpCardState();
}

class _FpCardState extends State<FpCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 80),
    lowerBound: 0.0,
    upperBound: 0.015,
  );

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? AppTheme.radius;
    final border = widget.borderColor ?? context.border;

    final container = AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => Transform.scale(
        scale: 1.0 - _ctrl.value,
        child: child,
      ),
      child: Container(
        margin: widget.margin,
        padding: widget.padding ?? const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: widget.gradient == null ? context.surface : null,
          gradient: widget.gradient,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: border),
        ),
        child: widget.child,
      ),
    );

    if (widget.onTap == null) return container;

    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.selectionClick();
        _ctrl.forward();
      },
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap!();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: container,
    );
  }
}

/// Thin label chip (e.g. "Intermediate", "12 Weeks")
class FpChip extends StatelessWidget {
  const FpChip({
    super.key,
    required this.label,
    this.color,
    this.backgroundColor,
    this.small = false,
  });

  final String label;
  final Color? color;
  final Color? backgroundColor;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final fg = color ?? context.secondaryText;
    final bg = backgroundColor ?? context.surface2;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 10,
        vertical: small ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: color != null ? Border.all(color: color!.withAlpha(77)) : null,
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: small ? 9 : 10,
          fontWeight: FontWeight.w800,
          color: fg,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

/// Section header row (title + optional action link)
class FpSectionHeader extends StatelessWidget {
  const FpSectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
    this.margin,
  });

  final String title;
  final String? action;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: context.primaryText,
              ),
            ),
          ),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                action!,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF02E6FF),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
