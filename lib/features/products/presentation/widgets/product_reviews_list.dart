import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/review.dart';

/// Renders a list of verified customer reviews or a clean placeholder when empty.
class ProductReviewsList extends StatelessWidget {
  final List<Review> reviews;

  const ProductReviewsList({super.key, required this.reviews});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 20.0,
              color: isDark ? AppColors.darkForestGreen : AppColors.forestGreen,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Customer Reviews (${reviews.length})',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        AppSpacing.gapMd,

        if (reviews.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceVariant
                  : AppColors.ivorySurfaceVariant,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.ivoryBorder,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.reviews_outlined,
                  size: 40.0,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.mutedSage,
                ),
                AppSpacing.gapSm,
                Text(
                  'No reviews yet',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AppSpacing.gapXs,
                Text(
                  'There are no customer reviews for this product yet.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reviews.length,
            separatorBuilder: (context, index) => AppSpacing.gapSm,
            itemBuilder: (context, index) {
              final review = reviews[index];
              final initials = review.reviewerName.isNotEmpty
                  ? review.reviewerName
                        .trim()
                        .split(' ')
                        .map((e) => e.isNotEmpty ? e[0] : '')
                        .take(2)
                        .join()
                        .toUpperCase()
                  : '?';

              return Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceVariant
                      : AppColors.ivorySurfaceVariant,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.ivoryBorder,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Author & Date Row
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16.0,
                          backgroundColor: isDark
                              ? AppColors.darkForestGreen.withValues(alpha: 0.2)
                              : AppColors.forestGreenContainer,
                          child: Text(
                            initials,
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.darkForestGreen
                                  : AppColors.forestGreenDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review.reviewerName,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13.0,
                                ),
                              ),
                              if (review.formattedDate.isNotEmpty)
                                Text(
                                  review.formattedDate,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textTertiary,
                                    fontSize: 11.0,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // Star Rating
                        Row(
                          children: List.generate(5, (starIndex) {
                            final isFilled = starIndex < review.rating.round();
                            return Icon(
                              isFilled
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              size: 16.0,
                              color: isFilled
                                  ? const Color(0xFFE6A23C)
                                  : (isDark
                                        ? AppColors.darkBorder
                                        : AppColors.ivoryBorder),
                            );
                          }),
                        ),
                      ],
                    ),
                    if (review.comment.isNotEmpty) ...[
                      AppSpacing.gapSm,
                      Text(
                        review.comment,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
