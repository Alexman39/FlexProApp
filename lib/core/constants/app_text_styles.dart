import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTextStyles {
  // ── Display ──────────────────────────────────────────────
  static TextStyle get displayLarge => GoogleFonts.inter(
    fontSize: 34, fontWeight: FontWeight.w900,
    letterSpacing: -0.8, height: 1.1,
  );

  static TextStyle get displayMedium => GoogleFonts.inter(
    fontSize: 28, fontWeight: FontWeight.w900,
    letterSpacing: -0.5, height: 1.15,
  );

  static TextStyle get displaySmall => GoogleFonts.inter(
    fontSize: 22, fontWeight: FontWeight.w800,
    letterSpacing: -0.3, height: 1.2,
  );

  // ── Headlines ────────────────────────────────────────────
  static TextStyle get headlineLarge => GoogleFonts.inter(
    fontSize: 20, fontWeight: FontWeight.w800, height: 1.25,
  );

  static TextStyle get headlineMedium => GoogleFonts.inter(
    fontSize: 18, fontWeight: FontWeight.w700, height: 1.3,
  );

  static TextStyle get headlineSmall => GoogleFonts.inter(
    fontSize: 16, fontWeight: FontWeight.w700, height: 1.35,
  );

  // ── Labels ───────────────────────────────────────────────
  static TextStyle get labelLarge => GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.1,
  );

  static TextStyle get labelMedium => GoogleFonts.inter(
    fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5,
  );

  static TextStyle get labelSmall => GoogleFonts.inter(
    fontSize: 10, fontWeight: FontWeight.w700,
    letterSpacing: 0.8, height: 1.2,
  );

  static TextStyle get labelCaps => GoogleFonts.inter(
    fontSize: 11, fontWeight: FontWeight.w700,
    letterSpacing: 1.0, height: 1.2,
  );

  // ── Body ─────────────────────────────────────────────────
  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16, fontWeight: FontWeight.w400, height: 1.5,
  );

  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.w400, height: 1.55,
  );

  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 13, fontWeight: FontWeight.w400, height: 1.5,
  );

  // ── Numbers (monospaced-feel for metrics) ────────────────
  static TextStyle get metricLarge => GoogleFonts.inter(
    fontSize: 32, fontWeight: FontWeight.w900,
    letterSpacing: -1.0, height: 1.0,
  );

  static TextStyle get metricMedium => GoogleFonts.inter(
    fontSize: 22, fontWeight: FontWeight.w900,
    letterSpacing: -0.5, height: 1.0,
  );

  static TextStyle get metricSmall => GoogleFonts.inter(
    fontSize: 18, fontWeight: FontWeight.w800,
    letterSpacing: -0.3, height: 1.0,
  );

  // ── Timer ────────────────────────────────────────────────
  static TextStyle get timerLarge => GoogleFonts.inter(
    fontSize: 80, fontWeight: FontWeight.w900,
    letterSpacing: -3.0, height: 1.0,
  );

  static TextStyle get timerSmall => GoogleFonts.inter(
    fontSize: 16, fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );
}
