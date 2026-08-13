import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/routes.dart';
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
        const SnackBar(content: Text('Passwords do not match.')),
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
            SnackBar(content: Text(errorMsg ?? 'Registration failed. Check network or input details.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.storefront_rounded, color: scheme.onPrimaryContainer, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Register Store Owner', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                          Text('KaratCore Single Owner ERP', style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 20),

                  KcTextField(
                    controller: _storeNameController,
                    label: 'Jewellery Store / Business Name *',
                    hintText: 'e.g. Verma Jewellery Store',
                    validator: (val) => val == null || val.trim().isEmpty ? 'Business name is required' : null,
                  ),
                  const SizedBox(height: 16),

                  KcTextField(
                    controller: _fullNameController,
                    label: 'Owner Full Name *',
                    hintText: 'e.g. Ramesh Verma',
                    validator: (val) => val == null || val.trim().isEmpty ? 'Full name is required' : null,
                  ),
                  const SizedBox(height: 16),

                  KcTextField(
                    controller: _emailController,
                    label: 'Owner Email Address *',
                    hintText: 'e.g. ramesh@vermajewellers.com',
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) => val == null || !val.contains('@') ? 'Valid email required' : null,
                  ),
                  const SizedBox(height: 16),

                  KcTextField(
                    controller: _phoneController,
                    label: 'Mobile Phone Number *',
                    hintText: 'e.g. +91 98765 43210',
                    keyboardType: TextInputType.phone,
                    validator: (val) => val == null || val.trim().isEmpty ? 'Mobile phone required' : null,
                  ),
                  const SizedBox(height: 16),

                  KcTextField(
                    controller: _passwordController,
                    label: 'Password *',
                    obscureText: true,
                    validator: (val) => val == null || val.length < 6 ? 'Password must be at least 6 characters' : null,
                  ),
                  const SizedBox(height: 16),

                  KcTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password *',
                    obscureText: true,
                    validator: (val) => val == null || val != _passwordController.text ? 'Passwords do not match' : null,
                  ),
                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    child: KcPrimaryButton(
                      label: 'Register & Create Account',
                      icon: Icons.check_circle_rounded,
                      isLoading: _isSubmitting,
                      onPressed: _handleRegister,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have a store account? ', style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13)),
                      TextButton(
                        onPressed: () => context.go(AppRoutes.login),
                        child: const Text('Login Here', style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
