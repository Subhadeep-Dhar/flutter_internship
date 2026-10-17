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

  // Primary: Forest Green
  static const Color forestGreen = Color(0xFF1E4633);
  static const Color forestGreenLight = Color(0xFF2C6147);
  static const Color forestGreenDark = Color(0xFF133022);
  static const Color forestGreenContainer = Color(0xFFD8EAD9);
  static const Color onForestGreenContainer = Color(0xFF082014);

  // Secondary: Muted Sage
  static const Color mutedSage = Color(0xFF586B5D);
  static const Color mutedSageLight = Color(0xFF7A8F7F);
  static const Color mutedSageDark = Color(0xFF3B4B3F);
  static const Color mutedSageContainer = Color(0xFFDCE8DD);
  static const Color onMutedSageContainer = Color(0xFF16261A);

  // Tertiary / Accent: Restrained Orange (Sale / Discounts / Highlights)
  static const Color saleOrange = Color(0xFFD45B28);
  static const Color saleOrangeLight = Color(0xFFE87544);
  static const Color saleOrangeContainer = Color(0xFFFFDBCF);
  static const Color onSaleOrangeContainer = Color(0xFF391300);

  // Backgrounds & Surfaces: Warm Ivory
  static const Color ivoryBackground = Color(0xFFFAF7F2);
  static const Color ivorySurface = Color(0xFFFFFFFF);
  static const Color ivorySurfaceVariant = Color(0xFFF3EFEA);
  static const Color ivoryBorder = Color(0xFFE5DFD5);

  // Neutral Typography: Near-Black
  static const Color textPrimary = Color(0xFF1A1D1A);
  static const Color textSecondary = Color(0xFF5A625B);
  static const Color textTertiary = Color(0xFF828B83);
  static const Color textInverse = Color(0xFFFFFFFF);

  // Dark Mode Palette
  static const Color darkBackground = Color(0xFF121513);
  static const Color darkSurface = Color(0xFF1B1F1C);
  static const Color darkSurfaceVariant = Color(0xFF242A25);
  static const Color darkBorder = Color(0xFF343C36);
  static const Color darkTextPrimary = Color(0xFFE8EDE9);
  static const Color darkTextSecondary = Color(0xFFA5B0A7);
  static const Color darkForestGreen = Color(0xFF76C495);
  static const Color darkMutedSage = Color(0xFFA5B8A8);
  static const Color darkSaleOrange = Color(0xFFFFB59B);

  // Feedback Colors
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF410002);

  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFED6C02);
}
