import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../core/widgets/logout_confirmation_dialog.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/controllers/auth_state.dart';

/// User profile screen displaying verified session details and logout action.
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authNotifierProvider);
      final user = authState.userOrNull;
      // If phone or full profile is not yet loaded, fetch the latest /auth/me data
      if (user != null && user.phone == null) {
        ref.read(authNotifierProvider.notifier).refreshProfile();
      }
    });
  }

  Future<void> _onRefresh() async {
    final result = await ref
        .read(authNotifierProvider.notifier)
        .refreshProfile();

    if (result.isError && mounted) {
      final msg =
          result.failureOrNull?.message ?? 'Failed to update profile data.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authState = ref.watch(authNotifierProvider);
    final user = authState.userOrNull;

    // 1. Initial loading state (no cached user available)
    if (authState.isLoading && user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Profile')),
        body: const Center(
          child: AppLoadingIndicator(message: 'Loading profile...'),
        ),
      );
    }

    // 2. Initial error state (no cached user and network/server error)
    if (authState is AuthSessionCheckFailed && user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Profile')),
        body: AppErrorView(
          message: authState.failure.message,
          retryLabel: 'Retry',
          onRetry: () =>
              ref.read(authNotifierProvider.notifier).refreshProfile(),
        ),
      );
    }

    // 3. User details display
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Log out',
            constraints: const BoxConstraints(minWidth: 48.0, minHeight: 48.0),
            onPressed: () => LogoutConfirmationDialog.show(context),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.forestGreen,
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              children: [
                // Avatar Section
                Center(
                  child: CircleAvatar(
                    radius: 48.0,
                    backgroundColor: isDark
                        ? AppColors.darkForestGreen.withValues(alpha: 0.2)
                        : AppColors.forestGreenContainer,
                    child: (user?.image != null && user!.image!.isNotEmpty)
                        ? ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: user.image!,
                              width: 96.0,
                              height: 96.0,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => Text(
                                user.initials,
                                style: TextStyle(
                                  fontSize: 28.0,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppColors.darkForestGreen
                                      : AppColors.forestGreenDark,
                                ),
                              ),
                            ),
                          )
                        : Text(
                            user?.initials ?? '?',
                            style: TextStyle(
                              fontSize: 28.0,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.darkForestGreen
                                  : AppColors.forestGreenDark,
                            ),
                          ),
                  ),
                ),
                AppSpacing.gapLg,

                // Full Name
                Text(
                  _formatFullName(user),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                AppSpacing.gapXs,

                // Username
                Text(
                  _formatUsername(user),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.darkMutedSage
                        : AppColors.mutedSage,
                  ),
                ),
                AppSpacing.gapXxl,

                // Profile Details Card
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    side: BorderSide(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.ivoryBorder,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      children: [
                        _buildProfileItem(
                          icon: Icons.email_outlined,
                          label: 'Email',
                          value: _formatField(user?.email),
                          theme: theme,
                          isDark: isDark,
                        ),
                        const Divider(height: 1),
                        _buildProfileItem(
                          icon: Icons.phone_outlined,
                          label: 'Phone Number',
                          value: _formatField(user?.phone),
                          theme: theme,
                          isDark: isDark,
                        ),
                        const Divider(height: 1),
                        _buildProfileItem(
                          icon: Icons.person_outline_rounded,
                          label: 'Gender',
                          value: _formatGender(user?.gender),
                          theme: theme,
                          isDark: isDark,
                        ),
                        const Divider(height: 1),
                        _buildProfileItem(
                          icon: Icons.badge_outlined,
                          label: 'User ID',
                          value: user != null && user.id > 0
                              ? '#${user.id}'
                              : 'Not provided',
                          theme: theme,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ),
                AppSpacing.gapXxl,

                // Logout Button
                FilledButton.icon(
                  key: const ValueKey('profile_logout_button'),
                  onPressed: () => LogoutConfirmationDialog.show(context),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Log Out'),
                  style: FilledButton.styleFrom(
                    backgroundColor: isDark
                        ? AppColors.darkSaleOrange
                        : AppColors.error,
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
      ),
    );
  }

  String _formatFullName(User? user) {
    if (user == null) return 'Not provided';
    final name = user.fullName;
    if (name.isNotEmpty) return name;
    if (user.username.isNotEmpty) return user.username;
    return 'Not provided';
  }

  String _formatUsername(User? user) {
    if (user == null || user.username.trim().isEmpty) return 'Not provided';
    return '@${user.username.trim()}';
  }

  String _formatField(String? value) {
    if (value == null || value.trim().isEmpty) return 'Not provided';
    return value.trim();
  }

  String _formatGender(String? gender) {
    if (gender == null || gender.trim().isEmpty) return 'Not provided';
    final trimmed = gender.trim();
    return '${trimmed[0].toUpperCase()}${trimmed.substring(1).toLowerCase()}';
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          Icon(
            icon,
            size: 22.0,
            color: isDark ? AppColors.darkMutedSage : AppColors.mutedSage,
          ),
          AppSpacing.gapLg,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
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
