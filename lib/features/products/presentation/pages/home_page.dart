import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../routing/app_router.dart';

/// Authenticated Home screen placeholder for end-to-end auth verification.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authNotifierProvider);
    final user = authState.userOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ShopSphere'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            tooltip: 'Profile',
            onPressed: () => context.push(AppRoutes.profile),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () {
              ref.read(authNotifierProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 28.0,
                    backgroundColor: AppColors.forestGreenContainer,
                    child: user?.image != null
                        ? ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: user!.image!,
                              width: 56.0,
                              height: 56.0,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => Text(
                                user.initials,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.forestGreenDark,
                                ),
                              ),
                            ),
                          )
                        : Text(
                            user?.initials ?? '?',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.forestGreenDark,
                            ),
                          ),
                  ),
                  AppSpacing.gapLg,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.mutedSage,
                          ),
                        ),
                        Text(
                          user?.fullName ?? 'Shopper',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              AppSpacing.gapXxl,

              // Status Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.verified_user_rounded,
                            color: AppColors.forestGreen,
                            size: 20.0,
                          ),
                          AppSpacing.gapSm,
                          Text(
                            'Session Active',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: AppColors.forestGreen,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.gapSm,
                      Text(
                        'Signed in as @${user?.username ?? 'user'} (${user?.email ?? 'no email'})',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      AppSpacing.gapMd,
                      Row(
                        children: [
                          OutlinedButton.icon(
                            icon: const Icon(Icons.person_rounded, size: 18.0),
                            label: const Text('View Profile'),
                            onPressed: () => context.push(AppRoutes.profile),
                          ),
                          AppSpacing.gapMd,
                          TextButton.icon(
                            icon: const Icon(Icons.logout_rounded, size: 18.0),
                            label: const Text('Log out'),
                            onPressed: () {
                              ref.read(authNotifierProvider.notifier).logout();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
