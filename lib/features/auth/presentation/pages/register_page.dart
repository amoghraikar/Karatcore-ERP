import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/color_tokens.dart';
import '../../../../core/routing/routes.dart';
import '../../../../shared/widgets/buttons/karat_badge.dart';
import '../../../../shared/widgets/buttons/kc_primary_button.dart';
import '../../../../shared/widgets/inputs/kc_text_field.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth_split_layout.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _storeNameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _storeNameController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match. Please re-enter passwords.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final success = await ref.read(authStateProvider.notifier).registerOwner(
            fullName: _fullNameController.text.trim(),
            businessName: _storeNameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            password: _passwordController.text,
          );

      if (mounted) {
        setState(() => _isSubmitting = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Store Owner Account Created Successfully! Welcome to KaratCore ERP.')),
          );
          context.go(AppRoutes.dashboard);
        } else {
          final errorMsg = ref.read(authStateProvider).errorMessage;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg ?? 'Unable to create store account right now. Please check your details.')),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to complete registration right now. Please check your connection and try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? KcColors.textPrimaryDark : KcColors.textPrimaryLight;
    final secondaryTextColor = isDark ? KcColors.textSecondaryDark : KcColors.textSecondaryLight;

    return AuthSplitLayout(
      headline: 'The Gold Standard in Jewellery ERP.',
      subheadline: 'Register your jewellery store to manage sales, gold loan portfolios, live vault inventory, and double-entry ledgers.',
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
                  label: 'STORE OWNER ONBOARDING',
                  variant: KaratBadgeVariant.gold,
                  showDot: true,
                ),
              ],
            ).animate().fadeIn(duration: 300.ms),
            const SizedBox(height: 16),

            Text(
              'Create Store Account',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
                color: primaryTextColor,
              ),
            ).animate().fadeIn(delay: 50.ms, duration: 350.ms),
            const SizedBox(height: 4),
            Text(
              'Register your jewellery store to manage sales, gold loans, and ledgers.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: secondaryTextColor,
              ),
            ).animate().fadeIn(delay: 100.ms, duration: 350.ms),
            const SizedBox(height: 20),

            KcTextField(
              controller: _storeNameController,
              label: 'Jewellery Store / Business Name *',
              prefixIcon: const Icon(Icons.storefront_rounded),
              validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your business name' : null,
            ).animate().fadeIn(delay: 120.ms, duration: 350.ms),
            const SizedBox(height: 14),

            KcTextField(
              controller: _fullNameController,
              label: 'Owner Full Name *',
              prefixIcon: const Icon(Icons.person_outline_rounded),
              validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your full name' : null,
            ).animate().fadeIn(delay: 140.ms, duration: 350.ms),
            const SizedBox(height: 14),

            KcTextField(
              controller: _emailController,
              label: 'Owner Email Address *',
              prefixIcon: const Icon(Icons.email_outlined),
              keyboardType: TextInputType.emailAddress,
              validator: (val) => val == null || !val.contains('@') ? 'Please enter a valid email address' : null,
            ).animate().fadeIn(delay: 160.ms, duration: 350.ms),
            const SizedBox(height: 14),

            KcTextField(
              controller: _phoneController,
              label: 'Mobile Phone Number *',
              prefixIcon: const Icon(Icons.phone_outlined),
              keyboardType: TextInputType.phone,
              validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your mobile number' : null,
            ).animate().fadeIn(delay: 180.ms, duration: 350.ms),
            const SizedBox(height: 14),

            KcTextField(
              controller: _passwordController,
              label: 'Password *',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              obscureText: true,
              validator: (val) => val == null || val.length < 6 ? 'Password must be at least 6 characters' : null,
            ).animate().fadeIn(delay: 200.ms, duration: 350.ms),
            const SizedBox(height: 14),

            KcTextField(
              controller: _confirmPasswordController,
              label: 'Confirm Password *',
              prefixIcon: const Icon(Icons.lock_reset_rounded),
              obscureText: true,
              validator: (val) => val == null || val != _passwordController.text ? 'Passwords do not match' : null,
            ).animate().fadeIn(delay: 220.ms, duration: 350.ms),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: KcPrimaryButton(
                label: 'REGISTER & CREATE ACCOUNT',
                icon: Icons.check_circle_rounded,
                isLoading: _isSubmitting,
                onPressed: _handleRegister,
              ),
            ).animate().fadeIn(delay: 240.ms, duration: 350.ms),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Already have a store account? ', style: GoogleFonts.plusJakartaSans(color: secondaryTextColor, fontSize: 13)),
                TextButton(
                  onPressed: () => context.go(AppRoutes.login),
                  child: Text(
                    'Sign In Here',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      color: KcColors.goldAccent,
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 260.ms, duration: 350.ms),
          ],
        ),
      ),
    );
  }
}
