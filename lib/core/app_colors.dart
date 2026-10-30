import 'package:flutter/material.dart';

class AppColors {
  // Base colors from the design palette
  static const Color deepNavy = Color(0xFF0b132b); // #0b132b
  static const Color darkSlateBlue = Color(0xFF1c3144); // #1c3144
  static const Color mediumSlateGray = Color(0xFF4a525a); // #4a525a
  static const Color mutedGrayishTeal = Color(0xFF8a9597); // #8a9597
  static const Color lightIcyBlue = Color(0xFFe6f2f7); // #e6f2f7

  // Matching accent colors and harmonious variations for the app
  static const Color accentSky = Color(0xFF38bdf8); // Vibrant sky blue accent
  static const Color accentTeal = Color(0xFF2dd4bf); // Teal accent variant
  static const Color cardBackground = Color(
    0xFF162438,
  ); // Elevated dark surface

  // Semantic mappings
  static const Color backgroundDark = deepNavy;
  static const Color surfaceDark = darkSlateBlue;
  static const Color textLight = lightIcyBlue;
  static const Color textMuted = mutedGrayishTeal;

  static const Color error = Color(0xFFef4444);
  static const Color success = Color(0xFF22c55e);
}
