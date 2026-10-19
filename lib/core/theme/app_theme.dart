import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Centralized Material 3 ThemeData configuration for ShopSphere.
class AppTheme {
  const AppTheme._();

  /// Light theme matching the ShopSphere visual identity:
  /// Warm ivory background, forest green primary, muted sage secondary,
  /// restrained orange accents, and near-black typography.
  static ThemeData get lightTheme {
    final textTheme = AppTypography.createTextTheme(isDark: false);

    final colorScheme = const ColorScheme.light(
      primary: AppColors.forestGreen,
      onPrimary: Colors.white,
      primaryContainer: AppColors.forestGreenContainer,
      onPrimaryContainer: AppColors.onForestGreenContainer,
      secondary: AppColors.mutedSage,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.mutedSageContainer,
      onSecondaryContainer: AppColors.onMutedSageContainer,
      tertiary: AppColors.saleOrange,
      onTertiary: Colors.white,
      tertiaryContainer: AppColors.saleOrangeContainer,
      onTertiaryContainer: AppColors.onSaleOrangeContainer,
      surface: AppColors.ivorySurface,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.ivorySurfaceVariant,
      outline: AppColors.ivoryBorder,
      error: AppColors.error,
      onError: AppColors.onError,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.ivoryBackground,
      textTheme: textTheme,

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.ivoryBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
          size: 24.0,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.ivorySurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          side: const BorderSide(color: AppColors.ivoryBorder, width: 1.0),
        ),
      ),

      // Button Themes (enforcing 48dp min interactive tap target)
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(
            AppSpacing.minTapTarget,
            AppSpacing.minTapTarget,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(
            AppSpacing.minTapTarget,
            AppSpacing.minTapTarget,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.md,
          ),
          side: const BorderSide(color: AppColors.forestGreen, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(
            AppSpacing.minTapTarget,
            AppSpacing.minTapTarget,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.ivorySurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.textTertiary,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: WidgetStateTextStyle.resolveWith((states) {
          if (states.contains(WidgetState.error)) {
            return textTheme.bodyMedium!.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.w600,
            );
          }
          if (states.contains(WidgetState.focused)) {
            return textTheme.bodyMedium!.copyWith(
              color: AppColors.forestGreen,
              fontWeight: FontWeight.w600,
            );
          }
          return textTheme.bodyMedium!.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          );
        }),
        floatingLabelStyle: WidgetStateTextStyle.resolveWith((states) {
          if (states.contains(WidgetState.error)) {
            return textTheme.bodyMedium!.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.w700,
            );
          }
          if (states.contains(WidgetState.focused)) {
            return textTheme.bodyMedium!.copyWith(
              color: AppColors.forestGreen,
              fontWeight: FontWeight.w700,
            );
          }
          return textTheme.bodyMedium!.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          );
        }),
        prefixIconColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.error)) {
            return AppColors.error;
          }
          if (states.contains(WidgetState.focused)) {
            return AppColors.forestGreen;
          }
          return AppColors.textSecondary;
        }),
        suffixIconColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.error)) {
            return AppColors.error;
          }
          if (states.contains(WidgetState.focused)) {
            return AppColors.forestGreen;
          }
          return AppColors.textSecondary;
        }),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(
            color: AppColors.ivoryBorder,
            width: 1.2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(
            color: AppColors.ivoryBorder,
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(
            color: AppColors.forestGreen,
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.error, width: 2.0),
        ),
        errorStyle: textTheme.bodySmall?.copyWith(
          color: AppColors.error,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Navigation Bar Theme
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.ivorySurface,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        height: 64.0,
        indicatorColor: AppColors.forestGreenContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelSmall?.copyWith(
              color: AppColors.forestGreen,
              fontWeight: FontWeight.w700,
            );
          }
          return textTheme.labelSmall?.copyWith(color: AppColors.textSecondary);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: AppColors.forestGreen,
              size: 24.0,
            );
          }
          return const IconThemeData(
            color: AppColors.textSecondary,
            size: 24.0,
          );
        }),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.ivorySurface,
        selectedColor: AppColors.forestGreenContainer,
        disabledColor: AppColors.ivorySurfaceVariant,
        side: const BorderSide(color: AppColors.ivoryBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        labelStyle: textTheme.labelMedium?.copyWith(
          color: AppColors.textPrimary,
        ),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.ivoryBorder,
        thickness: 1,
        space: 1,
      ),

      // Navigation Rail Theme
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.ivorySurface,
        indicatorColor: AppColors.forestGreenContainer,
        selectedLabelTextStyle: textTheme.labelSmall?.copyWith(
          color: AppColors.forestGreen,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelTextStyle: textTheme.labelSmall?.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
        selectedIconTheme: const IconThemeData(
          color: AppColors.forestGreen,
          size: 24.0,
        ),
        unselectedIconTheme: const IconThemeData(
          color: AppColors.textSecondary,
          size: 24.0,
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.ivorySurface,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          side: const BorderSide(color: AppColors.ivoryBorder, width: 1.0),
        ),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
        ),
      ),

      // SnackBar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.textInverse,
          fontWeight: FontWeight.w500,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
    );
  }

  /// Dark theme counterpart for ShopSphere.
  static ThemeData get darkTheme {
    final textTheme = AppTypography.createTextTheme(isDark: true);

    final colorScheme = const ColorScheme.dark(
      primary: AppColors.darkForestGreen,
      onPrimary: AppColors.darkBackground,
      primaryContainer: AppColors.forestGreenDark,
      onPrimaryContainer: AppColors.darkForestGreen,
      secondary: AppColors.darkMutedSage,
      onSecondary: AppColors.darkBackground,
      secondaryContainer: AppColors.mutedSageDark,
      onSecondaryContainer: AppColors.darkMutedSage,
      tertiary: AppColors.darkSaleOrange,
      onTertiary: AppColors.darkBackground,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkTextPrimary,
      surfaceContainerHighest: AppColors.darkSurfaceVariant,
      outline: AppColors.darkBorder,
      error: AppColors.darkError,
      onError: AppColors.darkOnError,
      errorContainer: AppColors.darkErrorContainer,
      onErrorContainer: AppColors.darkOnErrorContainer,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.darkTextPrimary,
          size: 24.0,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          side: const BorderSide(color: AppColors.darkBorder, width: 1.0),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(
            AppSpacing.minTapTarget,
            AppSpacing.minTapTarget,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(
            AppSpacing.minTapTarget,
            AppSpacing.minTapTarget,
          ),
          side: const BorderSide(color: AppColors.darkForestGreen, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.darkTextSecondary,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: WidgetStateTextStyle.resolveWith((states) {
          if (states.contains(WidgetState.error)) {
            return textTheme.bodyMedium!.copyWith(
              color: AppColors.darkError,
              fontWeight: FontWeight.w600,
            );
          }
          if (states.contains(WidgetState.focused)) {
            return textTheme.bodyMedium!.copyWith(
              color: AppColors.darkForestGreen,
              fontWeight: FontWeight.w700,
            );
          }
          return textTheme.bodyMedium!.copyWith(
            color: AppColors.darkTextSecondary,
            fontWeight: FontWeight.w600,
          );
        }),
        floatingLabelStyle: WidgetStateTextStyle.resolveWith((states) {
          if (states.contains(WidgetState.error)) {
            return textTheme.bodyMedium!.copyWith(
              color: AppColors.darkError,
              fontWeight: FontWeight.w700,
            );
          }
          if (states.contains(WidgetState.focused)) {
            return textTheme.bodyMedium!.copyWith(
              color: AppColors.darkForestGreen,
              fontWeight: FontWeight.w700,
            );
          }
          return textTheme.bodyMedium!.copyWith(
            color: AppColors.darkTextSecondary,
            fontWeight: FontWeight.w600,
          );
        }),
        prefixIconColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.error)) {
            return AppColors.darkError;
          }
          if (states.contains(WidgetState.focused)) {
            return AppColors.darkForestGreen;
          }
          return AppColors.darkTextSecondary;
        }),
        suffixIconColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.error)) {
            return AppColors.darkError;
          }
          if (states.contains(WidgetState.focused)) {
            return AppColors.darkForestGreen;
          }
          return AppColors.darkTextSecondary;
        }),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.darkBorder, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.darkBorder, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(
            color: AppColors.darkForestGreen,
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.darkError, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.darkError, width: 2.0),
        ),
        errorStyle: textTheme.bodySmall?.copyWith(
          color: AppColors.darkError,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Navigation Bar Theme
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        height: 64.0,
        indicatorColor: AppColors.forestGreenDark,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelSmall?.copyWith(
              color: AppColors.darkForestGreen,
              fontWeight: FontWeight.w700,
            );
          }
          return textTheme.labelSmall?.copyWith(
            color: AppColors.darkTextSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: AppColors.darkForestGreen,
              size: 24.0,
            );
          }
          return const IconThemeData(
            color: AppColors.darkTextSecondary,
            size: 24.0,
          );
        }),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedColor: AppColors.forestGreenDark,
        disabledColor: AppColors.darkSurfaceVariant,
        side: const BorderSide(color: AppColors.darkBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        labelStyle: textTheme.labelMedium?.copyWith(
          color: AppColors.darkTextPrimary,
        ),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 1,
        space: 1,
      ),

      // Navigation Rail Theme
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: AppColors.forestGreenDark,
        selectedLabelTextStyle: textTheme.labelSmall?.copyWith(
          color: AppColors.darkForestGreen,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelTextStyle: textTheme.labelSmall?.copyWith(
          color: AppColors.darkTextSecondary,
          fontWeight: FontWeight.w500,
        ),
        selectedIconTheme: const IconThemeData(
          color: AppColors.darkForestGreen,
          size: 24.0,
        ),
        unselectedIconTheme: const IconThemeData(
          color: AppColors.darkTextSecondary,
          size: 24.0,
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          side: const BorderSide(color: AppColors.darkBorder, width: 1.0),
        ),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.darkTextSecondary,
        ),
      ),

      // SnackBar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkSurfaceVariant,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w500,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
      ),
    );
  }
}
