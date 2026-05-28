import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

abstract final class AppTheme {
  // ── Radii ────────────────────────────────────────────────
  static const double radiusXS  = 6;
  static const double radiusSM  = 10;
  static const double radius    = 16;
  static const double radiusLG  = 20;
  static const double radiusXL  = 24;
  static const double radiusXXL = 32;

  static ThemeData get dark => _build(Brightness.dark);
  static ThemeData get light => _build(Brightness.light);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final bg       = isDark ? AppColors.bgDark       : AppColors.bgLight;
    final surface  = isDark ? AppColors.surfaceDark   : AppColors.surfaceLight;
    final surface2 = isDark ? AppColors.surface2Dark  : AppColors.surface2Light;
    final border   = isDark ? AppColors.borderDark    : AppColors.borderLight;
    final text     = isDark ? AppColors.textDark      : AppColors.textLight;
    final text2    = isDark ? AppColors.text2Dark     : AppColors.text2Light;

    return ThemeData(
      brightness: brightness,
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: AppColors.accent,
        onPrimary: Colors.black,
        primaryContainer: AppColors.accentDim,
        onPrimaryContainer: AppColors.accent,
        secondary: AppColors.surface3Dark,
        onSecondary: text,
        secondaryContainer: surface2,
        onSecondaryContainer: text,
        error: AppColors.danger,
        onError: Colors.white,
        surface: surface,
        onSurface: text,
        surfaceContainerHighest: surface2,
        outline: border,
        outlineVariant: border,
      ),
      scaffoldBackgroundColor: bg,
      textTheme: GoogleFonts.interTextTheme(
        ThemeData(brightness: brightness).textTheme,
      ).apply(
        bodyColor: text,
        displayColor: text,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: text,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18, fontWeight: FontWeight.w800,
          color: text, letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(color: border),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.inter(
            fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.2,
          ),
          minimumSize: const Size(double.infinity, 52),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: text2,
          side: BorderSide(color: border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.inter(
            fontSize: 15, fontWeight: FontWeight.w600,
          ),
          minimumSize: const Size(double.infinity, 52),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSM),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSM),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSM),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 15, fontWeight: FontWeight.w400, color: isDark ? AppColors.text3Dark : AppColors.text3Light,
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w600, color: text2,
          letterSpacing: 0.8,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: border,
        thickness: 1,
        space: 0,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: isDark ? AppColors.text3Dark : AppColors.text3Light,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: AppColors.accent,
        disabledColor: surface,
        labelStyle: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w600,
        ),
        side: BorderSide(color: border),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      extensions: const [
        AppThemeExtension(),
      ],
    );
  }
}

/// Custom theme extension for brand-specific tokens
@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  const AppThemeExtension();

  @override
  AppThemeExtension copyWith() => const AppThemeExtension();

  @override
  AppThemeExtension lerp(AppThemeExtension? other, double t) => this;
}

/// Convenience extension on BuildContext
extension ThemeX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get texts => Theme.of(this).textTheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get bg       => isDark ? AppColors.bgDark       : AppColors.bgLight;
  Color get surface  => isDark ? AppColors.surfaceDark   : AppColors.surfaceLight;
  Color get surface2 => isDark ? AppColors.surface2Dark  : AppColors.surface2Light;
  Color get surface3 => isDark ? AppColors.surface3Dark  : AppColors.surface3Light;
  Color get border   => isDark ? AppColors.borderDark    : AppColors.borderLight;
  Color get primaryText  => isDark ? AppColors.textDark  : AppColors.textLight;
  Color get secondaryText => isDark ? AppColors.text2Dark : AppColors.text2Light;
  Color get tertiaryText  => isDark ? AppColors.text3Dark : AppColors.text3Light;
}
