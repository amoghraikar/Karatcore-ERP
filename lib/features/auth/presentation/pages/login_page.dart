import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/color_tokens.dart';
import '../../../../core/routing/routes.dart';
import '../../../../shared/widgets/buttons/karat_badge.dart';
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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? KcColors.textPrimaryDark : KcColors.textPrimaryLight;
    final secondaryTextColor = isDark ? KcColors.textSecondaryDark : KcColors.textSecondaryLight;
    final borderColor = isDark ? KcColors.borderDark : KcColors.borderLight;

    return AuthSplitLayout(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Category Badge
            const Row(
              children: [
                KaratBadge(
                  label: 'STORE OWNER PORTAL',
                  variant: KaratBadgeVariant.gold,
                  showDot: true,
                ),
              ],
            ).animate().fadeIn(duration: 300.ms),
            const SizedBox(height: 16),

            Text(
              'Sign In to KaratCore',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.0,
                color: primaryTextColor,
              ),
            ).animate().fadeIn(delay: 50.ms, duration: 350.ms),
            const SizedBox(height: 6),
            Text(
              'Enter your Store Owner credentials to access store operations.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: secondaryTextColor,
              ),
            ).animate().fadeIn(delay: 100.ms, duration: 350.ms),
            const SizedBox(height: 24),

            // Humane Error Banner
            if (authState.errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: KcColors.dangerSubdued,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: KcColors.danger.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: KcColors.danger, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        authState.errorMessage!,
                        style: GoogleFonts.plusJakartaSans(
                          color: KcColors.danger,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 250.ms).shakeX(amount: 4),
              const SizedBox(height: 20),
            ],

            // Input Fields
            KcTextField(
              controller: _emailController,
              label: 'Email Address or Mobile Number',
              prefixIcon: const Icon(Icons.person_outline_rounded),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your email or mobile number.';
                }
                return null;
              },
            ).animate().fadeIn(delay: 150.ms, duration: 350.ms),
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
            ).animate().fadeIn(delay: 180.ms, duration: 350.ms),
            const SizedBox(height: 12),

            // Remember Me & Forgot Password Row
            Row(
              children: [
                Checkbox(
                  value: authState.rememberDevice,
                  activeColor: isDark ? KcColors.textPrimaryDark : KcColors.textPrimaryLight,
                  checkColor: isDark ? KcColors.bgDark : KcColors.surfaceLight,
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
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, color: primaryTextColor),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => context.go(AppRoutes.forgotPassword),
                  child: Text(
                    'Forgot Password?',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: KcColors.goldAccent,
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 200.ms, duration: 350.ms),
            const SizedBox(height: 20),

            // Primary & Secondary Action Buttons
            KcPrimaryButton(
              label: 'SIGN IN TO DASHBOARD',
              fullWidth: true,
              icon: Icons.arrow_forward_rounded,
              isLoading: authState.isAuthenticating,
              onPressed: _submitLogin,
            ).animate().fadeIn(delay: 220.ms, duration: 350.ms),

            const SizedBox(height: 12),
            KcOutlinedButton(
              label: 'SIGN IN VIA OTP VERIFICATION',
              fullWidth: true,
              icon: Icons.phonelink_ring_rounded,
              onPressed: () {
                ref.read(authStateProvider.notifier).requireOtpStep(_emailController.text.trim());
                context.go(AppRoutes.verify);
              },
            ).animate().fadeIn(delay: 260.ms, duration: 350.ms),
            const SizedBox(height: 20),

            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('New Store Owner? ', style: GoogleFonts.plusJakartaSans(color: secondaryTextColor, fontSize: 13)),
                TextButton(
                  onPressed: () => context.go(AppRoutes.register),
                  child: Text(
                    'Register Store Account',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      color: KcColors.goldAccent,
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 280.ms, duration: 350.ms),
            const SizedBox(height: 12),

            KcOutlinedButton(
              label: 'CUSTOMER PORTAL (MOBILE + OTP LOGIN)',
              fullWidth: true,
              icon: Icons.account_circle_outlined,
              onPressed: () => context.go('/customer'),
            ).animate().fadeIn(delay: 300.ms, duration: 350.ms),
            const SizedBox(height: 20),


            Divider(height: 1, color: borderColor),
            const SizedBox(height: 16),

            // Security Footnote
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_outline_rounded, size: 14, color: KcColors.goldAccent),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'ENCRYPTED 256-BIT SECURE AUTHENTICATION',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: secondaryTextColor,
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
