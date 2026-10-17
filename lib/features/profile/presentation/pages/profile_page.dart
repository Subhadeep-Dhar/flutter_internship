import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// User profile screen displaying session details and logout action.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authNotifierProvider);
    final user = authState.userOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            children: [
              // Avatar Section
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 48.0,
                      backgroundColor: AppColors.forestGreenContainer,
                      child: user?.image != null
                          ? ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: user!.image!,
                                width: 96.0,
                                height: 96.0,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) => Text(
                                  user.initials,
                                  style: const TextStyle(
                                    fontSize: 28.0,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.forestGreenDark,
                                  ),
                                ),
                              ),
                            )
                          : Text(
                              user?.initials ?? '?',
                              style: const TextStyle(
                                fontSize: 28.0,
                                fontWeight: FontWeight.w700,
                                color: AppColors.forestGreenDark,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              AppSpacing.gapLg,
              Text(
                user?.fullName ?? 'User Profile',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              AppSpacing.gapXs,
              Text(
                '@${user?.username ?? 'username'}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.mutedSage,
                ),
              ),
              AppSpacing.gapXxl,

              // Profile Details Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      _buildProfileItem(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: user?.email ?? 'Not provided',
                        theme: theme,
                      ),
                      const Divider(),
                      _buildProfileItem(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: user?.phone ?? 'Not provided',
                        theme: theme,
                      ),
                      const Divider(),
                      _buildProfileItem(
                        icon: Icons.person_outline_rounded,
                        label: 'Gender',
                        value: user?.gender != null
                            ? '${user!.gender![0].toUpperCase()}${user.gender!.substring(1)}'
                            : 'Not specified',
                        theme: theme,
                      ),
                      const Divider(),
                      _buildProfileItem(
                        icon: Icons.badge_outlined,
                        label: 'User ID',
                        value: '#${user?.id ?? 0}',
                        theme: theme,
                      ),
                    ],
                  ),
                ),
              ),
              AppSpacing.gapXxl,

              // Logout Button
              FilledButton.icon(
                onPressed: () {
                  ref.read(authNotifierProvider.notifier).logout();
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Log Out'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(
                    double.infinity,
                    AppSpacing.minTapTarget,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 22.0, color: AppColors.mutedSage),
          AppSpacing.gapLg,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
