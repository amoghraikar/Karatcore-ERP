import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/color_tokens.dart';
import '../../../../core/routing/routes.dart';
import '../../../../shared/widgets/buttons/kc_outlined_button.dart';
import '../../../../shared/widgets/buttons/kc_primary_button.dart';
import '../../../../shared/widgets/inputs/kc_text_field.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth_split_layout.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _contactController = TextEditingController(text: 'arjun@karatcore.com');
  bool _isSubmitted = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _contactController.dispose();
    super.dispose();
  }

  void _onRequestReset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).requestPasswordReset(
            emailOrPhone: _contactController.text.trim(),
          );
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isSubmitted = true;
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
      headline: 'Account Security Recovery',
      subheadline: 'Reset your password securely via registered email or mobile phone multi-factor verification.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Forgot Password?',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Enter your registered email or phone number to receive reset instructions.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),

            if (_isSubmitted) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: KcColors.signalGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: KcColors.signalGreen.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: KcColors.signalGreen, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reset Password Link Sent!',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: KcColors.signalGreen,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'We sent instructions to ${_contactController.text}. Please check your inbox.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              KcPrimaryButton(
                label: 'Proceed to Reset Password',
                fullWidth: true,
                icon: Icons.lock_reset_rounded,
                onPressed: () => context.go(AppRoutes.resetPassword),
              ),
            ] else ...[
              KcTextField(
                controller: _contactController,
                label: 'Registered Email or Phone',
                prefixIcon: const Icon(Icons.mark_email_read_outlined),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter your email address or phone.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              KcPrimaryButton(
                label: 'Send Recovery Code',
                fullWidth: true,
                icon: Icons.send_rounded,
                isLoading: _isLoading,
                onPressed: _onRequestReset,
              ),
            ],

            const SizedBox(height: 16),
            KcOutlinedButton(
              label: 'Back to Sign In',
              fullWidth: true,
              icon: Icons.arrow_back_rounded,
              onPressed: () => context.go(AppRoutes.login),
            ),
          ],
        ),
      ),
    );
  }
}
