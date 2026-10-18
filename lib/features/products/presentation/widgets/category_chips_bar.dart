import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/category.dart';

/// Horizontal scrollable bar of category filter chips with an "All" option.
class CategoryChipsBar extends StatelessWidget {
  final List<Category> categories;
  final String? selectedCategory;
  final ValueChanged<String?> onSelectCategory;

  const CategoryChipsBar({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onSelectCategory,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isAllSelected = selectedCategory == null || selectedCategory == 'all';

    return SizedBox(
      height: 48.0,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: categories.length + 1,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildChip(
              context: context,
              label: 'All',
              isSelected: isAllSelected,
              onTap: () => onSelectCategory(null),
              isDark: isDark,
            );
          }

          final category = categories[index - 1];
          final isSelected = selectedCategory == category.slug;

          return _buildChip(
            context: context,
            label: category.name,
            isSelected: isSelected,
            onTap: () => onSelectCategory(category.slug),
            isDark: isDark,
          );
        },
      ),
    );
  }

  Widget _buildChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final selectedBg = isDark
        ? AppColors.darkForestGreen
        : AppColors.forestGreen;
    final selectedText = isDark ? AppColors.darkBackground : Colors.white;

    final unselectedBg = isDark
        ? AppColors.darkSurfaceVariant
        : AppColors.ivorySurfaceVariant;
    final unselectedText = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.ivoryBorder;

    return Semantics(
      button: true,
      selected: isSelected,
      label: 'Category $label',
      child: Center(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isSelected ? selectedBg : unselectedBg,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              border: Border.all(
                color: isSelected ? selectedBg : borderColor,
                width: 1.0,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? selectedText : unselectedText,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
