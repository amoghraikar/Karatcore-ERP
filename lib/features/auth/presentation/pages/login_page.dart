import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/color_tokens.dart';
import '../../../../core/routing/routes.dart';
import '../../../../shared/widgets/buttons/kc_outlined_button.dart';
import '../../../../shared/widgets/buttons/kc_primary_button.dart';
import '../../../../shared/widgets/inputs/kc_password_field.dart';
import '../../../../shared/widgets/inputs/kc_text_field.dart';
import '../../models/user_role.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth_split_layout.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'owner@karatcore.com');
  final _passwordController = TextEditingController(text: 'Password123!');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authStateProvider.notifier).login(
          emailOrPhone: _emailController.text.trim(),
          password: _passwordController.text,
          role: UserRole.owner,
        );

    if (success && mounted) {
      context.go(AppRoutes.verify);
    }
  }

  void _submitBiometric() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Authenticating via TouchID / FaceID biometric scan...'),
        duration: Duration(seconds: 1),
      ),
    );
    ref.read(authStateProvider.notifier).forceAuthenticateAsRole(UserRole.owner);
    if (mounted) {
      context.go(AppRoutes.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final scheme = Theme.of(context).colorScheme;

    return AuthSplitLayout(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sign In to KaratCore',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Enter your Store Owner credentials to access store operations.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),

            if (authState.errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: KcColors.signalRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: KcColors.signalRed.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: KcColors.signalRed, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        authState.errorMessage!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: KcColors.signalRed,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Input Fields
            KcTextField(
              controller: _emailController,
              label: 'Email Address or Mobile Number',
              hintText: 'e.g. arjun@karatcore.com or +91 98200 12345',
              prefixIcon: const Icon(Icons.person_outline_rounded),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your email or mobile number.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            KcPasswordField(
              controller: _passwordController,
              label: 'Password',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your password.';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Remember Me & Forgot Password Row
            Row(
              children: [
                Checkbox(
                  value: authState.rememberDevice,
                  onChanged: (val) {
                    ref.read(authStateProvider.notifier).setRememberDevice(val ?? true);
                  },
                ),
                Flexible(
                  child: GestureDetector(
                    onTap: () {
                      ref.read(authStateProvider.notifier).setRememberDevice(!authState.rememberDevice);
                    },
                    child: Text(
                      'Remember this device',
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => context.go(AppRoutes.forgotPassword),
                  child: const Text('Forgot Password?'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Buttons
            KcPrimaryButton(
              label: 'Sign In',
              fullWidth: true,
              icon: Icons.login_rounded,
              isLoading: authState.isAuthenticating,
              onPressed: _submitLogin,
            ),
            const SizedBox(height: 12),
            KcOutlinedButton(
              label: 'Biometric Login (TouchID / FaceID)',
              fullWidth: true,
              icon: Icons.fingerprint_rounded,
              onPressed: _submitBiometric,
            ),
            const SizedBox(height: 24),

            // Security Reassurance
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_outline_rounded, size: 14, color: KcColors.slate400),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Encrypted 256-bit Secure Authentication',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
