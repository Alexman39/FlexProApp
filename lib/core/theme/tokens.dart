import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

// ─── Spacing ──────────────────────────────────────────────────────────────────
abstract final class AppSpacing {
  static const double xs   = 4;
  static const double sm   = 8;
  static const double md   = 12;
  static const double base = 16;
  static const double lg   = 24;
  static const double xl   = 32;
  static const double xxl  = 40;

  static const EdgeInsets pagePadding =
      EdgeInsets.symmetric(horizontal: base);
  static const EdgeInsets cardPadding = EdgeInsets.all(base);
  static const EdgeInsets cardPaddingSm = EdgeInsets.all(md);
  static const EdgeInsets listItemPadding =
      EdgeInsets.symmetric(horizontal: base, vertical: md);
  static const EdgeInsets sectionPadding =
      EdgeInsets.fromLTRB(base, lg, base, 0);
}

// ─── Radius ───────────────────────────────────────────────────────────────────
abstract final class AppRadius {
  static const double xs  = 6;
  static const double sm  = 10;
  static const double md  = 16;
  static const double lg  = 20;
  static const double xl  = 24;
  static const double xxl = 32;

  // Prebuilt semantic shapes
  static const BorderRadius card = BorderRadius.all(Radius.circular(md));
  static const BorderRadius button = BorderRadius.all(Radius.circular(md));
  static const BorderRadius input = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius chip = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius bottomSheet = BorderRadius.only(
    topLeft: Radius.circular(xxl),
    topRight: Radius.circular(xxl),
  );
}

// ─── Type scale ───────────────────────────────────────────────────────────────
// Raw font-size constants. Full styles live in AppTextStyles.
abstract final class AppTypeScale {
  static const double displayLg = 34;
  static const double displayMd = 28;
  static const double displaySm = 22;
  static const double headLg    = 20;
  static const double headMd    = 18;
  static const double headSm    = 16;
  static const double bodyLg    = 16;
  static const double bodyMd    = 14;
  static const double bodySm    = 13;
  static const double labelLg   = 14;
  static const double labelMd   = 12;
  static const double labelSm   = 10;
  static const double metricLg  = 32;
  static const double metricMd  = 22;
  static const double metricSm  = 18;
  static const double timer     = 80;
}

// ─── Durations & Curves ───────────────────────────────────────────────────────
abstract final class AppDuration {
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast    = Duration(milliseconds: 150);
  static const Duration medium  = Duration(milliseconds: 250);
  static const Duration slow    = Duration(milliseconds: 400);
  static const Duration xslow  = Duration(milliseconds: 600);
}

abstract final class AppCurve {
  static const Curve standard = Curves.easeInOut;
  static const Curve enter    = Curves.easeOut;
  static const Curve exit     = Curves.easeIn;
  static const Curve spring   = Curves.elasticOut;
}

// ─── Shadows ─────────────────────────────────────────────────────────────────
// Keyed to the surface hierarchy; pass `context.isDark` from ThemeX.
abstract final class AppShadow {
  static List<BoxShadow> card(bool isDark) => [
    BoxShadow(
      color: Color(isDark ? 0x4D000000 : 0x0F000000),
      blurRadius: 12,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> elevated(bool isDark) => [
    BoxShadow(
      color: Color(isDark ? 0x80000000 : 0x1A000000),
      blurRadius: 24,
      spreadRadius: -2,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> modal(bool isDark) => [
    BoxShadow(
      color: Color(isDark ? 0xB3000000 : 0x26000000),
      blurRadius: 40,
      spreadRadius: -4,
      offset: const Offset(0, 16),
    ),
  ];

  static const List<BoxShadow> accentGlow = [
    BoxShadow(
      color: AppColors.accentGlow, // 30% cyan
      blurRadius: 20,
      spreadRadius: -2,
    ),
  ];
}

// ─── Surface hierarchy ────────────────────────────────────────────────────────
// surface1 — page / scaffold background
// surface2 — card background
// surface3 — elevated panel / bottom sheet
// surface4 — modal / popover
//
// Note: ThemeX (app_theme.dart) exposes these same colours as
// ctx.bg / ctx.surface / ctx.surface2 / ctx.surface3.
// AppSurface is the token-layer alias for use when BuildContext
// is unavailable or when semantic naming matters (e.g. decorators).
abstract final class AppSurface {
  static Color background(bool isDark) =>
      isDark ? AppColors.bgDark      : AppColors.bgLight;

  static Color card(bool isDark) =>
      isDark ? AppColors.surfaceDark  : AppColors.surfaceLight;

  static Color elevated(bool isDark) =>
      isDark ? AppColors.surface2Dark : AppColors.surface2Light;

  static Color modal(bool isDark) =>
      isDark ? AppColors.surface3Dark : AppColors.surface3Light;

  static Color border(bool isDark) =>
      isDark ? AppColors.borderDark   : AppColors.borderLight;
}
