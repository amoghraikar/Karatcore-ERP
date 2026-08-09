import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/color_tokens.dart';
import '../../../../core/routing/routes.dart';
import '../../../../shared/widgets/buttons/kc_outlined_button.dart';
import '../../../../shared/widgets/buttons/kc_primary_button.dart';
import '../../../../shared/widgets/inputs/kc_password_field.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth_split_layout.dart';
import '../../widgets/password_strength_indicator.dart';

class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isSuccess = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match.'),
          backgroundColor: KcColors.signalRed,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).resetPassword(
            newPassword: _newPasswordController.text,
          );
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isSuccess = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: KcColors.signalRed),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AuthSplitLayout(
      headline: 'Set Strong Security Password',
      subheadline: 'Ensure your account has a robust password adhering to enterprise security standards.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Reset Password',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Create a new password for your KaratCore account.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),

            if (_isSuccess) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: KcColors.signalGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: KcColors.signalGreen.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: KcColors.signalGreen, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Password Updated Successfully!',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: KcColors.signalGreen,
                                ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Your credentials have been updated. Please sign in with your new password.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              KcPrimaryButton(
                label: 'Sign In Now',
                fullWidth: true,
                icon: Icons.login_rounded,
                onPressed: () => context.go(AppRoutes.login),
              ),
            ] else ...[
              KcPasswordField(
                controller: _newPasswordController,
                label: 'New Password',
                validator: (val) {
                  if (val == null || val.length < 8) {
                    return 'Password must be at least 8 characters long.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _newPasswordController,
                builder: (context, value, _) {
                  return PasswordStrengthIndicator(password: value.text);
                },
              ),
              const SizedBox(height: 16),
              KcPasswordField(
                controller: _confirmPasswordController,
                label: 'Confirm New Password',
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Please confirm your new password.';
                  }
                  if (val != _newPasswordController.text) {
                    return 'Passwords do not match.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              KcPrimaryButton(
                label: 'Update Password',
                fullWidth: true,
                icon: Icons.security_rounded,
                isLoading: _isLoading,
                onPressed: _onResetPassword,
              ),
              const SizedBox(height: 12),
              KcOutlinedButton(
                label: 'Cancel',
                fullWidth: true,
                onPressed: () => context.go(AppRoutes.login),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
