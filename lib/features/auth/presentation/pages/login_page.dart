import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../controllers/auth_state.dart';

/// Polished login screen conforming to ShopSphere's visual identity.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  final _usernameFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _submit() {
    // Hide keyboard
    FocusScope.of(context).unfocus();

    if (_formKey.currentState?.validate() ?? false) {
      ref
          .read(authNotifierProvider.notifier)
          .login(
            username: _usernameController.text.trim(),
            password: _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;

    // Check for inline error message (e.g. invalid credentials or session expiration)
    final errorMessage = switch (authState) {
      AuthUnauthenticated(:final message) when message != null => message,
      AuthSessionExpired(:final message) => message,
      _ => null,
    };

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.ivoryBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand Logo & Heading
                    Center(
                      child: Container(
                        width: 72.0,
                        height: 72.0,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkForestGreen
                              : AppColors.forestGreen,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusLg,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (isDark
                                          ? AppColors.darkForestGreen
                                          : AppColors.forestGreen)
                                      .withValues(alpha: 0.2),
                              blurRadius: 16.0,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          size: 36.0,
                          color: isDark
                              ? AppColors.darkBackground
                              : Colors.white,
                        ),
                      ),
                    ),
                    AppSpacing.gapXxl,
                    Text(
                      'Welcome to ShopSphere',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.forestGreenDark,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    AppSpacing.gapXs,
                    Text(
                      'Sign in to explore curated products & deals',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.mutedSage,
                      ),
                    ),
                    AppSpacing.gapXxl,

                    // Inline Error / Expired Session Banner
                    if (errorMessage != null) ...[
                      Container(
                        key: const ValueKey('login_error_banner'),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkErrorContainer.withValues(
                                  alpha: 0.3,
                                )
                              : AppColors.errorContainer,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMd,
                          ),
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkError.withValues(alpha: 0.4)
                                : AppColors.error.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              color: isDark
                                  ? AppColors.darkError
                                  : AppColors.error,
                              size: 20.0,
                            ),
                            AppSpacing.gapMd,
                            Expanded(
                              child: Text(
                                errorMessage,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: isDark
                                      ? AppColors.darkOnErrorContainer
                                      : AppColors.onErrorContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppSpacing.gapLg,
                    ],

                    // Username Input
                    TextFormField(
                      key: const ValueKey('login_username_field'),
                      controller: _usernameController,
                      focusNode: _usernameFocusNode,
                      enabled: !isLoading,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                      cursorColor: isDark
                          ? AppColors.darkForestGreen
                          : AppColors.forestGreen,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      autofillHints: const [AutofillHints.username],
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        hintText: 'Enter your username',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Username is required';
                        }
                        if (value.trim().length < 3) {
                          return 'Username must be at least 3 characters';
                        }
                        return null;
                      },
                    ),
                    AppSpacing.gapLg,

                    // Password Input with Visibility Toggle
                    TextFormField(
                      key: const ValueKey('login_password_field'),
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      obscureText: _obscurePassword,
                      enabled: !isLoading,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                      cursorColor: isDark
                          ? AppColors.darkForestGreen
                          : AppColors.forestGreen,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.visiblePassword,
                      autofillHints: const [AutofillHints.password],
                      onFieldSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20.0,
                          ),
                          tooltip: _obscurePassword
                              ? 'Show password'
                              : 'Hide password',
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        if (value.length < 4) {
                          return 'Password must be at least 4 characters';
                        }
                        return null;
                      },
                    ),
                    AppSpacing.gapXxl,

                    // Submit Button with Loading State & min 48dp height
                    FilledButton(
                      key: const ValueKey('login_submit_button'),
                      onPressed: isLoading ? null : _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: isDark
                            ? AppColors.darkForestGreen
                            : AppColors.forestGreen,
                        foregroundColor: isDark
                            ? AppColors.darkBackground
                            : Colors.white,
                        minimumSize: const Size(
                          double.infinity,
                          AppSpacing.minTapTarget,
                        ),
                      ),
                      child: isLoading
                          ? SizedBox(
                              width: 22.0,
                              height: 22.0,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isDark
                                      ? AppColors.darkBackground
                                      : Colors.white,
                                ),
                              ),
                            )
                          : const Text('Sign In'),
                    ),
                    AppSpacing.gapXxl,

                    // Test credentials helper banner (non-hardcoded, guide for reviewers)
                    Container(
                      key: const ValueKey('login_test_credentials'),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurface
                            : AppColors.ivorySurfaceVariant,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.ivoryBorder,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                size: 16.0,
                                color: isDark
                                    ? AppColors.darkMutedSage
                                    : AppColors.mutedSage,
                              ),
                              AppSpacing.gapSm,
                              Text(
                                'Assignment Test Account',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppColors.darkForestGreen
                                      : AppColors.forestGreenDark,
                                ),
                              ),
                            ],
                          ),
                          AppSpacing.gapXs,
                          Text(
                            'Username: emilys  •  Password: emilyspass',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
