import 'package:flutter/material.dart';

abstract final class AppColors {
  // ── Brand ────────────────────────────────────────────────
  static const Color accent       = Color(0xFF02E6FF);
  static const Color accentDim    = Color(0x2602E6FF);  // 15%
  static const Color accentGlow   = Color(0x4D02E6FF);  // 30%
  static const Color accentSolid  = Color(0xFF00CFEA);  // pressed state

  // ── Dark mode backgrounds ────────────────────────────────
  static const Color bgDark        = Color(0xFF0E0E0E);
  static const Color surfaceDark   = Color(0xFF1A1A1A);
  static const Color surface2Dark  = Color(0xFF222222);
  static const Color surface3Dark  = Color(0xFF2A2A2A);
  static const Color borderDark    = Color(0x12FFFFFF);  // 7%

  // ── Dark mode text ───────────────────────────────────────
  static const Color textDark      = Color(0xFFF0F0F0);
  static const Color text2Dark     = Color(0xFFA0A0A0);
  static const Color text3Dark     = Color(0xFF606060);

  // ── Light mode backgrounds ───────────────────────────────
  static const Color bgLight       = Color(0xFFF5F5F7);
  static const Color surfaceLight  = Color(0xFFFFFFFF);
  static const Color surface2Light = Color(0xFFF0F0F2);
  static const Color surface3Light = Color(0xFFE8E8EA);
  static const Color borderLight   = Color(0x1A000000);  // 10%

  // ── Light mode text ──────────────────────────────────────
  static const Color textLight     = Color(0xFF0E0E0E);
  static const Color text2Light    = Color(0xFF5A5A6A);
  static const Color text3Light    = Color(0xFFA0A0B0);

  // ── Semantic ─────────────────────────────────────────────
  static const Color success  = Color(0xFF2ECC71);
  static const Color danger   = Color(0xFFFF4757);
  static const Color warning  = Color(0xFFF39C12);
  static const Color info     = Color(0xFF3498DB);

  // ── Level badges ─────────────────────────────────────────
  static const Color beginnerColor      = Color(0xFF2ECC71);
  static const Color intermediateColor  = Color(0xFFF39C12);
  static const Color advancedColor      = Color(0xFFFF4757);

  // ── Gradient stops ───────────────────────────────────────
  static const Color accentLight = Color(0xFF66F0FF);
  static const Color bgDeep      = Color(0xFF070707);

  static const LinearGradient heroCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A2A2E), Color(0xFF0D1F24), Color(0xFF0A1A1E)],
  );

  static const LinearGradient accentCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D2228), Color(0xFF1A3A44)],
  );

  static const LinearGradient logoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2A3F44), Color(0xFF0D2228)],
  );

  static const LinearGradient restDayCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1A2E), Color(0xFF0D0D20), Color(0xFF0A0A1A)],
  );

  static const Color instagramPink = Color(0xFFE1306C);

  // ── Glow overlays ─────────────────────────────────────────
  static const Color restDayGlow = Color(0x20644DFF);

  static const LinearGradient streakGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x26F39C12), Color(0x0DF39C12)],
  );

  static const RadialGradient splashGlow = RadialGradient(
    center: Alignment(0, -0.4),
    radius: 0.9,
    colors: [Color(0x1F02E6FF), Colors.transparent],
  );
}
