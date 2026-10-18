import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/product_sort_option.dart';

/// Modal bottom sheet allowing users to select catalogue sorting criteria.
class ProductSortBottomSheet extends StatelessWidget {
  final ProductSortOption selectedOption;
  final ValueChanged<ProductSortOption> onSelect;
  final VoidCallback onReset;

  const ProductSortBottomSheet({
    super.key,
    required this.selectedOption,
    required this.onSelect,
    required this.onReset,
  });

  /// Static helper to display the sheet.
  static Future<void> show({
    required BuildContext context,
    required ProductSortOption selectedOption,
    required ValueChanged<ProductSortOption> onSelect,
    required VoidCallback onReset,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ProductSortBottomSheet(
        selectedOption: selectedOption,
        onSelect: (option) {
          Navigator.of(ctx).pop();
          onSelect(option);
        },
        onReset: () {
          Navigator.of(ctx).pop();
          onReset();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final sheetBg = isDark ? AppColors.darkSurface : AppColors.ivorySurface;

    return Container(
      padding: const EdgeInsets.only(
        top: AppSpacing.md,
        bottom: AppSpacing.xxl,
      ),
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 40.0,
                height: 4.0,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorder : AppColors.ivoryBorder,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
              ),
            ),

            // Header Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sort Products',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (!selectedOption.isNone)
                    TextButton(
                      onPressed: onReset,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.saleOrange,
                      ),
                      child: const Text('Reset'),
                    ),
                ],
              ),
            ),
            const Divider(height: AppSpacing.lg),

            // Option List
            ...ProductSortOption.values.map((option) {
              final isSelected = option == selectedOption;
              return ListTile(
                title: Text(
                  option.label,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? (isDark
                              ? AppColors.darkForestGreen
                              : AppColors.forestGreen)
                        : null,
                  ),
                ),
                trailing: isSelected
                    ? Icon(
                        Icons.check_circle_rounded,
                        color: isDark
                            ? AppColors.darkForestGreen
                            : AppColors.forestGreen,
                      )
                    : const Icon(
                        Icons.circle_outlined,
                        color: Colors.transparent,
                      ),
                onTap: () => onSelect(option),
              );
            }),
          ],
        ),
      ),
    );
  }
}
