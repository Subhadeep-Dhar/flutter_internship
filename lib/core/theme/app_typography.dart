import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Centralized typographic scale for ShopSphere adhering to Material 3 guidelines.
class AppTypography {
  const AppTypography._();

  static TextTheme createTextTheme({required bool isDark}) {
    final primaryColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final secondaryColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;

    return TextTheme(
      // Display: large hero or promotional headers
      displayLarge: TextStyle(
        fontSize: 40.0,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.15,
        color: primaryColor,
      ),
      displayMedium: TextStyle(
        fontSize: 32.0,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.2,
        color: primaryColor,
      ),
      displaySmall: TextStyle(
        fontSize: 28.0,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
        height: 1.25,
        color: primaryColor,
      ),

      // Headline: Section titles and screen headers
      headlineLarge: TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        height: 1.3,
        color: primaryColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.15,
        height: 1.35,
        color: primaryColor,
      ),
      headlineSmall: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.0,
        height: 1.4,
        color: primaryColor,
      ),

      // Title: Card titles, dialog headers
      titleLarge: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.0,
        height: 1.4,
        color: primaryColor,
      ),
      titleMedium: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.45,
        color: primaryColor,
      ),
      titleSmall: TextStyle(
        fontSize: 12.0,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.45,
        color: primaryColor,
      ),

      // Body: General content and paragraphs
      bodyLarge: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        height: 1.5,
        color: primaryColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.5,
        color: primaryColor,
      ),
      bodySmall: TextStyle(
        fontSize: 12.0,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.5,
        color: secondaryColor,
      ),

      // Label: Buttons, badges, chips, captions
      labelLarge: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.3,
        color: primaryColor,
      ),
      labelMedium: TextStyle(
        fontSize: 12.0,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.3,
        color: secondaryColor,
      ),
      labelSmall: TextStyle(
        fontSize: 11.0,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.3,
        color: secondaryColor,
      ),
    );
  }
}
