import 'package:flutter/material.dart';

/// Design tokens and palette for JivaanNet dark theme.
abstract final class AppColors {
  // Required core palette
  static const Color background = Color(0xFF0B111E);
  static const Color card = Color(0xFF131C2E);
  static const Color surfaceElevated = Color(0xFF1A253C);
  static const Color border = Color(0xFF22314E);
  static const Color sosRed = Color(0xFFE53935);
  static const Color successGreen = Color(0xFF30D158);
  static const Color pendingOrange = Color(0xFFFF9F0A);

  // Harmonized supplementary accents
  static const Color errorRed = Color(0xFFFF453A);
  static const Color cyanAccent = Color(0xFF00D2FF);
  static const Color blueAccent = Color(0xFF388AF6);
  static const Color purpleAccent = Color(0xFF9D65FF);

  // Typography & neutrals
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Status badge background tints (15-20% opacity)
  static const Color pendingBadgeBg = Color(0x33FF9F0A);
  static const Color successBadgeBg = Color(0x3330D158);
  static const Color failedBadgeBg = Color(0x33FF453A);
  static const Color redBadgeBg = Color(0x33E53935);
  static const Color cyanBadgeBg = Color(0x3300D2FF);

  // Glowing SOS button accents
  static const Color sosGlowOuter = Color(0x4DE53935);
  static const Color sosGlowMid = Color(0x80E53935);
  static const Color sosDarkCenter = Color(0xFF1C0D11);
}
