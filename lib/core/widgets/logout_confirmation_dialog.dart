import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../di/providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Accessible Material 3 confirmation dialog to prevent accidental session logout.
class LogoutConfirmationDialog extends ConsumerStatefulWidget {
  const LogoutConfirmationDialog({super.key});

  /// Displays the logout confirmation modal.
  /// Returns `true` if logout was confirmed and performed, `false` or `null` otherwise.
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const LogoutConfirmationDialog(),
    );
  }

  @override
  ConsumerState<LogoutConfirmationDialog> createState() =>
      _LogoutConfirmationDialogState();
}

class _LogoutConfirmationDialogState
    extends ConsumerState<LogoutConfirmationDialog> {
  bool _isLoading = false;

  Future<void> _handleConfirm() async {
    if (_isLoading) return; // Prevent duplicate requests

    setState(() {
      _isLoading = true;
    });

    try {
      // Clear active cart to protect private user data
      await ref.read(cartNotifierProvider.notifier).clearCart();
      // Clear secure tokens and authentication state
      await ref.read(authNotifierProvider.notifier).logout();
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(true);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.ivorySurface,
      title: Row(
        children: [
          Icon(
            Icons.logout_rounded,
            color: isDark ? AppColors.darkSaleOrange : AppColors.error,
            size: 24.0,
          ),
          const SizedBox(width: AppSpacing.sm),
          const Text('Log out?'),
        ],
      ),
      content: const Text(
        'Are you sure you want to log out of ShopSphere?',
        style: TextStyle(fontSize: 14.0),
      ),
      actionsPadding: const EdgeInsets.only(
        right: AppSpacing.lg,
        bottom: AppSpacing.md,
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(
            minimumSize: const Size(80.0, AppSpacing.minTapTarget),
          ),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _handleConfirm,
          style: FilledButton.styleFrom(
            backgroundColor: isDark
                ? AppColors.darkSaleOrange
                : AppColors.error,
            foregroundColor: isDark ? AppColors.darkBackground : Colors.white,
            minimumSize: const Size(96.0, AppSpacing.minTapTarget),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 18.0,
                  height: 18.0,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Log out'),
        ),
      ],
    );
  }
}
