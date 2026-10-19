import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/core/theme/app_colors.dart';
import 'package:shopsphere/core/theme/app_theme.dart';
import 'package:shopsphere/core/theme/app_typography.dart';

void main() {
  group('AppColors Palette Tokens', () {
    test('defines cohesive forest green primary tokens', () {
      expect(AppColors.forestGreen, const Color(0xFF245747));
      expect(AppColors.forestGreenDark, const Color(0xFF183F34));
      expect(AppColors.forestGreenContainer, const Color(0xFFE2EEE7));
    });

    test('defines warm neutral background and surface tokens', () {
      expect(AppColors.ivoryBackground, const Color(0xFFF7F7F2));
      expect(AppColors.ivorySurface, const Color(0xFFFFFFFF));
      expect(AppColors.ivoryBorder, const Color(0xFFDDE3DD));
    });

    test('defines high-contrast typography tokens', () {
      expect(AppColors.textPrimary, const Color(0xFF202722));
      expect(AppColors.textSecondary, const Color(0xFF626B65));
      expect(AppColors.textTertiary, const Color(0xFF8C958F));
    });

    test('defines restrained terracotta discount and feedback tokens', () {
      expect(AppColors.saleOrange, const Color(0xFFC24E34));
      expect(AppColors.error, const Color(0xFFBA3535));
      expect(AppColors.success, const Color(0xFF26734D));
    });
  });

  group('AppTheme Configuration', () {
    test('lightTheme configures Material 3 colorScheme correctly', () {
      final theme = AppTheme.lightTheme;
      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.primary, AppColors.forestGreen);
      expect(theme.colorScheme.surface, AppColors.ivorySurface);
      expect(theme.scaffoldBackgroundColor, AppColors.ivoryBackground);
      expect(theme.colorScheme.error, AppColors.error);
    });

    test('darkTheme configures Material 3 colorScheme correctly', () {
      final theme = AppTheme.darkTheme;
      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.primary, AppColors.darkForestGreen);
      expect(theme.scaffoldBackgroundColor, AppColors.darkBackground);
      expect(theme.colorScheme.error, AppColors.darkError);
    });

    test(
      'lightTheme inputDecorationTheme resolves states with readable contrast',
      () {
        final inputTheme = AppTheme.lightTheme.inputDecorationTheme;
        expect(inputTheme.filled, isTrue);
        expect(inputTheme.fillColor, AppColors.ivorySurface);

        // LabelStyle states
        final labelStyle = inputTheme.labelStyle as WidgetStateTextStyle?;
        final normalLabelStyle = labelStyle?.resolve({});
        expect(normalLabelStyle?.color, AppColors.textSecondary);

        final focusedLabelStyle = labelStyle?.resolve({WidgetState.focused});
        expect(focusedLabelStyle?.color, AppColors.forestGreen);
        expect(focusedLabelStyle?.fontWeight, FontWeight.w600);

        final errorLabelStyle = labelStyle?.resolve({WidgetState.error});
        expect(errorLabelStyle?.color, AppColors.error);

        // FloatingLabelStyle states
        final floatingStyle =
            inputTheme.floatingLabelStyle as WidgetStateTextStyle?;
        final normalFloating = floatingStyle?.resolve({});
        expect(normalFloating?.color, AppColors.textSecondary);

        final focusedFloating = floatingStyle?.resolve({WidgetState.focused});
        expect(focusedFloating?.color, AppColors.forestGreen);
        expect(focusedFloating?.fontWeight, FontWeight.w700);

        final errorFloating = floatingStyle?.resolve({WidgetState.error});
        expect(errorFloating?.color, AppColors.error);

        // Borders
        expect(
          inputTheme.focusedBorder?.borderSide.color,
          AppColors.forestGreen,
        );
        expect(inputTheme.focusedBorder?.borderSide.width, 2.0);
        expect(inputTheme.errorBorder?.borderSide.color, AppColors.error);
      },
    );

    test('navigation themes are consistent across bar and rail', () {
      final light = AppTheme.lightTheme;
      expect(
        light.navigationBarTheme.indicatorColor,
        AppColors.forestGreenContainer,
      );
      expect(
        light.navigationRailTheme.indicatorColor,
        AppColors.forestGreenContainer,
      );

      final dark = AppTheme.darkTheme;
      expect(dark.navigationBarTheme.indicatorColor, AppColors.forestGreenDark);
      expect(
        dark.navigationRailTheme.indicatorColor,
        AppColors.forestGreenDark,
      );
    });

    test('dialog and snackbar themes are defined with cohesive styling', () {
      final light = AppTheme.lightTheme;
      expect(light.dialogTheme.backgroundColor, AppColors.ivorySurface);
      expect(light.snackBarTheme.behavior, SnackBarBehavior.floating);

      final dark = AppTheme.darkTheme;
      expect(dark.dialogTheme.backgroundColor, AppColors.darkSurface);
      expect(dark.snackBarTheme.behavior, SnackBarBehavior.floating);
    });
  });

  group('AppTypography', () {
    test('provides legible font sizes and line heights', () {
      final textTheme = AppTypography.createTextTheme(isDark: false);
      expect(textTheme.headlineMedium?.fontSize, 20.0);
      expect(textTheme.bodyLarge?.fontSize, 16.0);
      expect(textTheme.bodyMedium?.fontSize, 14.0);
      expect(textTheme.bodySmall?.fontSize, 12.0);
      expect(textTheme.bodyLarge?.color, AppColors.textPrimary);
      expect(textTheme.bodySmall?.color, AppColors.textSecondary);
    });
  });
}
