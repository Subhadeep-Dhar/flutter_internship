import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/product_sort_option.dart';

/// Accessible search input field with sort button and clear action.
class ProductSearchBar extends StatefulWidget {
  final String initialQuery;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;
  final VoidCallback onSortTap;
  final ProductSortOption activeSort;

  const ProductSearchBar({
    super.key,
    required this.initialQuery,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
    required this.onSortTap,
    this.activeSort = ProductSortOption.none,
  });

  @override
  State<ProductSearchBar> createState() => _ProductSearchBarState();
}

class _ProductSearchBarState extends State<ProductSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
  }

  @override
  void didUpdateWidget(covariant ProductSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialQuery != oldWidget.initialQuery &&
        widget.initialQuery != _controller.text) {
      _controller.text = widget.initialQuery;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final fieldBg = isDark
        ? AppColors.darkSurfaceVariant
        : AppColors.ivorySurfaceVariant;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.ivoryBorder;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          // Search Input Field
          Expanded(
            child: Container(
              height: 48.0,
              decoration: BoxDecoration(
                color: fieldBg,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: borderColor, width: 1.0),
              ),
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.search,
                style: theme.textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textTertiary,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.mutedSage,
                    size: 22.0,
                  ),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 20.0),
                          tooltip: 'Clear search',
                          onPressed: () {
                            _controller.clear();
                            widget.onClear();
                            setState(() {});
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.md,
                    horizontal: AppSpacing.sm,
                  ),
                ),
                onChanged: (val) {
                  setState(() {});
                  widget.onChanged(val);
                },
                onSubmitted: widget.onSubmitted,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Sort Button with Active Indicator
          Container(
            height: 48.0,
            width: 48.0,
            decoration: BoxDecoration(
              color: widget.activeSort.isNone
                  ? fieldBg
                  : (isDark
                        ? AppColors.darkForestGreen.withValues(alpha: 0.2)
                        : AppColors.forestGreenContainer),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: widget.activeSort.isNone
                    ? borderColor
                    : (isDark
                          ? AppColors.darkForestGreen
                          : AppColors.forestGreen),
                width: 1.0,
              ),
            ),
            child: IconButton(
              icon: Icon(
                Icons.tune_rounded,
                size: 22.0,
                color: widget.activeSort.isNone
                    ? (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.mutedSage)
                    : (isDark
                          ? AppColors.darkForestGreen
                          : AppColors.forestGreenDark),
              ),
              tooltip: 'Sort: ${widget.activeSort.label}',
              onPressed: widget.onSortTap,
            ),
          ),
        ],
      ),
    );
  }
}
