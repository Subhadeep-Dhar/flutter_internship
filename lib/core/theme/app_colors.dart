import 'package:flutter/material.dart';

/// Design tokens defining the ShopSphere color palette.
///
/// Visual identity:
/// - Warm ivory backgrounds
/// - Forest-green primary
/// - Muted sage accents
/// - Near-black typography
/// - Restrained orange sale accents
class AppColors {
  const AppColors._();

  // Primary: Forest Green (Sophisticated Deep Pine)
  static const Color forestGreen = Color(0xFF245747);
  static const Color forestGreenLight = Color(0xFF34705C);
  static const Color forestGreenDark = Color(0xFF183F34);
  static const Color forestGreenContainer = Color(0xFFE2EEE7);
  static const Color onForestGreenContainer = Color(0xFF0C241C);

  // Secondary: Muted Slate / Sage
  static const Color mutedSage = Color(0xFF626B65);
  static const Color mutedSageLight = Color(0xFF7E8781);
  static const Color mutedSageDark = Color(0xFF454D48);
  static const Color mutedSageContainer = Color(0xFFE3E8E4);
  static const Color onMutedSageContainer = Color(0xFF1E2621);

  // Tertiary / Accent: Restrained Terracotta (Sale / Discounts / Highlights)
  static const Color saleOrange = Color(0xFFC24E34);
  static const Color saleOrangeLight = Color(0xFFD6634A);
  static const Color saleOrangeContainer = Color(0xFFFBE8E4);
  static const Color onSaleOrangeContainer = Color(0xFF431308);

  // Backgrounds & Surfaces: Warm Neutral
  static const Color ivoryBackground = Color(0xFFF7F7F2);
  static const Color ivorySurface = Color(0xFFFFFFFF);
  static const Color ivorySurfaceVariant = Color(0xFFEFEFE9);
  static const Color ivoryBorder = Color(0xFFDDE3DD);

  // Neutral Typography: Charcoal
  static const Color textPrimary = Color(0xFF202722);
  static const Color textSecondary = Color(0xFF626B65);
  static const Color textTertiary = Color(0xFF8C958F);
  static const Color textInverse = Color(0xFFFFFFFF);

  // Dark Mode Palette
  static const Color darkBackground = Color(0xFF131714);
  static const Color darkSurface = Color(0xFF1B211D);
  static const Color darkSurfaceVariant = Color(0xFF252C27);
  static const Color darkBorder = Color(0xFF363E38);
  static const Color darkTextPrimary = Color(0xFFEDF2EE);
  static const Color darkTextSecondary = Color(0xFFA6AFA8);
  static const Color darkForestGreen = Color(0xFF6BB58E);
  static const Color darkMutedSage = Color(0xFFA6B3A9);
  static const Color darkSaleOrange = Color(0xFFF0907C);

  // Feedback Colors
  static const Color error = Color(0xFFBA3535);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFCE8E8);
  static const Color onErrorContainer = Color(0xFF4C0F0F);

  // Dark Mode Feedback Colors
  static const Color darkError = Color(0xFFFFB4AB);
  static const Color darkOnError = Color(0xFF690005);
  static const Color darkErrorContainer = Color(0xFF93000A);
  static const Color darkOnErrorContainer = Color(0xFFFFDAD6);

  static const Color success = Color(0xFF26734D);
  static const Color warning = Color(0xFFD97706);
}
