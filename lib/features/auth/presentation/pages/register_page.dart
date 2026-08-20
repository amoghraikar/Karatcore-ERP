import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/color_tokens.dart';
import '../../../../core/routing/routes.dart';
import '../../../../shared/components/kc_brand.dart';
import '../../../../shared/widgets/buttons/kc_primary_button.dart';
import '../../../../shared/widgets/inputs/kc_text_field.dart';
import '../../providers/auth_provider.dart';

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
            const SnackBar(content: Text('Account Created! Please enter your 6-digit OTP verification code.')),
          );
          context.go(AppRoutes.verify);
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
    final cardBg = isDark ? KcColors.surfaceDark : KcColors.surfaceLight;
    final borderColor = isDark ? KcColors.borderDark : KcColors.borderLight;
    final primaryTextColor = isDark ? KcColors.textPrimaryDark : KcColors.textPrimaryLight;
    final secondaryTextColor = isDark ? KcColors.textSecondaryDark : KcColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: isDark ? KcColors.bgDark : KcColors.bgLight,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(36),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.06),
                  blurRadius: 28,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Official KaratCore Emblem Logo
                  const KcBrandMark(
                    showWordmark: true,
                    subtitle: 'STORE OWNER REGISTRATION',
                    size: 40,
                  ).animate().fadeIn(duration: 300.ms),
                  const SizedBox(height: 24),
                  Divider(height: 1, color: borderColor),
                  const SizedBox(height: 24),

                  Text(
                    'Create Store Account',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
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
                  const SizedBox(height: 24),

                  KcTextField(
                    controller: _storeNameController,
                    label: 'Jewellery Store / Business Name *',
                    hintText: 'e.g. Royal Gold Jewellers',
                    validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your business name' : null,
                  ).animate().fadeIn(delay: 120.ms, duration: 350.ms),
                  const SizedBox(height: 16),

                  KcTextField(
                    controller: _fullNameController,
                    label: 'Owner Full Name *',
                    hintText: 'e.g. Rajesh Sharma',
                    validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your full name' : null,
                  ).animate().fadeIn(delay: 140.ms, duration: 350.ms),
                  const SizedBox(height: 16),

                  KcTextField(
                    controller: _emailController,
                    label: 'Owner Email Address *',
                    hintText: 'e.g. rajesh@royalgold.com',
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) => val == null || !val.contains('@') ? 'Please enter a valid email address' : null,
                  ).animate().fadeIn(delay: 160.ms, duration: 350.ms),
                  const SizedBox(height: 16),

                  KcTextField(
                    controller: _phoneController,
                    label: 'Mobile Phone Number *',
                    hintText: 'e.g. +91 98765 43210',
                    keyboardType: TextInputType.phone,
                    validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your mobile number' : null,
                  ).animate().fadeIn(delay: 180.ms, duration: 350.ms),
                  const SizedBox(height: 16),

                  KcTextField(
                    controller: _passwordController,
                    label: 'Password *',
                    obscureText: true,
                    validator: (val) => val == null || val.length < 6 ? 'Password must be at least 6 characters' : null,
                  ).animate().fadeIn(delay: 200.ms, duration: 350.ms),
                  const SizedBox(height: 16),

                  KcTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password *',
                    obscureText: true,
                    validator: (val) => val == null || val != _passwordController.text ? 'Passwords do not match' : null,
                  ).animate().fadeIn(delay: 220.ms, duration: 350.ms),
                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    child: KcPrimaryButton(
                      label: 'REGISTER & CREATE ACCOUNT',
                      icon: Icons.check_circle_rounded,
                      isLoading: _isSubmitting,
                      onPressed: _handleRegister,
                    ),
                  ).animate().fadeIn(delay: 240.ms, duration: 350.ms),
                  const SizedBox(height: 20),

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
          ),
        ),
      ),
    );
  }
}
