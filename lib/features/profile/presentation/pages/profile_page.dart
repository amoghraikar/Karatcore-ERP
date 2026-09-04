import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/color_tokens.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/routes.dart';
import '../../../../shared/components/kc_avatar.dart';
import '../../../../shared/widgets/buttons/kc_outlined_button.dart';
import '../../../../shared/widgets/buttons/kc_primary_button.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/inputs/kc_password_field.dart';
import '../../../../shared/widgets/inputs/kc_text_field.dart';
import '../../../auth/providers/auth_provider.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _fullNameController = TextEditingController();
  final _storeNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _initialized = false;
  bool _isSavingProfile = false;
  bool _isUpdatingPassword = false;

  bool _is2faEnabled = true;
  bool _isBiometricEnabled = true;
  bool _securityAlerts = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fullNameController.dispose();
    _storeNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveProfile() async {
    final fullName = _fullNameController.text.trim();
    final storeName = _storeNameController.text.trim();
    final phone = _phoneController.text.trim();

    if (fullName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your full name.')),
      );
      return;
    }

    setState(() => _isSavingProfile = true);
    try {
      await ref.read(authStateProvider.notifier).updateOwnerProfile(
            fullName: fullName,
            storeName: storeName,
            phone: phone,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Owner profile details updated successfully!'),
            backgroundColor: Color(0xFF059669),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSavingProfile = false);
      }
    }
  }

  Future<void> _handleUpdatePassword() async {
    final current = _currentPasswordController.text;
    final newPass = _newPasswordController.text;
    final confirm = _confirmPasswordController.text;

    if (current.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your current password.')),
      );
      return;
    }
    if (newPass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New password must be at least 6 characters.')),
      );
      return;
    }
    if (newPass != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New passwords do not match.')),
      );
      return;
    }

    setState(() => _isUpdatingPassword = true);
    try {
      await ref.read(authStateProvider.notifier).changePassword(
            currentPassword: current,
            newPassword: newPass,
          );
      if (mounted) {
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Security password updated successfully!'),
            backgroundColor: Color(0xFF059669),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdatingPassword = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final authState = ref.watch(authStateProvider);
    final user = authState.session;

    if (!_initialized && user != null) {
      _fullNameController.text = user.name;
      _storeNameController.text = user.storeName ?? '';
      _emailController.text = user.email;
      _phoneController.text = user.phone;
      _initialized = true;
    }

    final initials = (user?.name ?? 'AR')
        .split(' ')
        .take(2)
        .map((e) => e.isNotEmpty ? e[0] : '')
        .join()
        .toUpperCase();

    return ListView(
      padding: EdgeInsets.all(context.pageGutter),
      children: [
        // Profile Header Card
        KcCard(
          padding: const EdgeInsets.all(24),
          child: context.isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        KcAvatar(initials: initials, size: 64),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.name ?? 'Store Owner',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              if (user?.storeName != null && user!.storeName!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  user.storeName!,
                                  style: const TextStyle(color: KcColors.gold500, fontSize: 13, fontWeight: FontWeight.w700),
                                ),
                              ],
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: KcColors.gold500.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: KcColors.gold500.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  user?.role.label.toUpperCase() ?? 'OWNER',
                                  style: const TextStyle(color: KcColors.gold500, fontSize: 10, fontWeight: FontWeight.w800),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${user?.email ?? "owner@karatcore.com"} • ${user?.phone ?? "+91 98200 12345"}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Assigned Branch: ${user?.branch?.name ?? "Main Vault & Showroom"}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: KcOutlinedButton(
                        label: 'Lock Session',
                        icon: Icons.lock_outline_rounded,
                        onPressed: () {
                          ref.read(authStateProvider.notifier).lockSession();
                          context.go(AppRoutes.locked);
                        },
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    KcAvatar(initials: initials, size: 72),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                user?.name ?? 'Store Owner',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: KcColors.gold500.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: KcColors.gold500.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  user?.role.label.toUpperCase() ?? 'OWNER',
                                  style: const TextStyle(
                                    color: KcColors.gold500,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (user?.storeName != null && user!.storeName!.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              user.storeName!,
                              style: const TextStyle(
                                color: KcColors.gold500,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                          const SizedBox(height: 4),
                          Text(
                            '${user?.email ?? "owner@karatcore.com"} • ${user?.phone ?? "+91 98200 12345"}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Assigned Branch: ${user?.branch?.name ?? "Main Vault & Showroom"}',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                    KcOutlinedButton(
                      label: 'Lock Session',
                      icon: Icons.lock_outline_rounded,
                      onPressed: () {
                        ref.read(authStateProvider.notifier).lockSession();
                        context.go(AppRoutes.locked);
                      },
                    ),
                  ],
                ),
        ),
        const SizedBox(height: 20),

        // Tabs Header
        TabBar(
          controller: _tabController,
          labelColor: scheme.primary,
          unselectedLabelColor: scheme.onSurfaceVariant,
          indicatorColor: scheme.primary,
          tabs: const [
            Tab(icon: Icon(Icons.person_outline_rounded), text: 'Profile & Identity'),
            Tab(icon: Icon(Icons.security_rounded), text: 'Security & Access Control'),
          ],
        ),
        const SizedBox(height: 20),

        SizedBox(
          height: 650,
          child: TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: Profile Details
              ListView(
                children: [
                  KcCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Personal Details',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Manage your store owner identity, registered jewellery business name, and contact information.',
                          style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 20),
                        if (context.isMobile) ...[
                          KcTextField(
                            controller: _fullNameController,
                            label: 'Owner Full Name *',
                            prefixIcon: const Icon(Icons.person_outline_rounded),
                          ),
                          const SizedBox(height: 14),
                          KcTextField(
                            controller: _storeNameController,
                            label: 'Jewellery Store / Business Name',
                            prefixIcon: const Icon(Icons.storefront_rounded),
                          ),
                          const SizedBox(height: 14),
                          KcTextField(
                            controller: _emailController,
                            label: 'Registered Email (Primary Identity)',
                            prefixIcon: const Icon(Icons.email_outlined),
                            enabled: false,
                          ),
                          const SizedBox(height: 14),
                          KcTextField(
                            controller: _phoneController,
                            label: 'Mobile Phone Number',
                            prefixIcon: const Icon(Icons.phone_outlined),
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.verified_user_rounded, color: KcColors.gold500, size: 20),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Access Scope: ${user?.role.label ?? "Owner"}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                    const Text('Full administrative & ledger authority', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          Row(
                            children: [
                              Expanded(
                                child: KcTextField(
                                  controller: _fullNameController,
                                  label: 'Owner Full Name *',
                                  prefixIcon: const Icon(Icons.person_outline_rounded),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: KcTextField(
                                  controller: _storeNameController,
                                  label: 'Jewellery Store / Business Name',
                                  prefixIcon: const Icon(Icons.storefront_rounded),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: KcTextField(
                                  controller: _emailController,
                                  label: 'Registered Email (Primary Identity)',
                                  prefixIcon: const Icon(Icons.email_outlined),
                                  enabled: false,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: KcTextField(
                                  controller: _phoneController,
                                  label: 'Mobile Phone Number',
                                  prefixIcon: const Icon(Icons.phone_outlined),
                                  keyboardType: TextInputType.phone,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.verified_user_rounded, color: KcColors.gold500, size: 20),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Access Scope: ${user?.role.label ?? "Owner"} (Super Administrator)', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                    const Text('Authorized for bullion settlement, loan approvals, and audit sign-off.', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        KcPrimaryButton(
                          label: 'Save Profile Changes',
                          icon: Icons.save_rounded,
                          isLoading: _isSavingProfile,
                          onPressed: _handleSaveProfile,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Tab 2: Security UI (Requirement 15)
              ListView(
                children: [
                  // Change Password Section
                  KcCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Change Password',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 16),
                        KcPasswordField(controller: _currentPasswordController, label: 'Current Password'),
                        const SizedBox(height: 12),
                        KcPasswordField(controller: _newPasswordController, label: 'New Password (min 6 characters)'),
                        const SizedBox(height: 12),
                        KcPasswordField(controller: _confirmPasswordController, label: 'Confirm New Password'),
                        const SizedBox(height: 16),
                        KcPrimaryButton(
                          label: 'Update Password',
                          icon: Icons.shield_rounded,
                          isLoading: _isUpdatingPassword,
                          onPressed: _handleUpdatePassword,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2FA & Biometric Toggles
                  KcCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Authentication Preferences',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile(
                          title: const Text('Two-Factor Authentication (2FA)'),
                          subtitle: const Text('Require 6-digit verification code on sign-in'),
                          value: _is2faEnabled,
                          onChanged: (val) => setState(() => _is2faEnabled = val),
                        ),
                        const Divider(),
                        SwitchListTile(
                          title: const Text('Biometric Authentication (TouchID / FaceID)'),
                          subtitle: const Text('Allow quick biometric unlocking on supported hardware'),
                          value: _isBiometricEnabled,
                          onChanged: (val) => setState(() => _isBiometricEnabled = val),
                        ),
                        const Divider(),
                        SwitchListTile(
                          title: const Text('Security Alerts & Notifications'),
                          subtitle: const Text('Receive push alerts for logins from unknown devices'),
                          value: _securityAlerts,
                          onChanged: (val) => setState(() => _securityAlerts = val),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Active Sessions Table
                  KcCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Active Login Sessions',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 16),
                        const ListTile(
                          leading: Icon(Icons.laptop_mac_rounded, color: KcColors.gold500),
                          title: Text('macOS Sonoma (Google Chrome) • Current Session'),
                          subtitle: Text('Mumbai, India • IP: 103.22.45.12 • Active Now'),
                          trailing: Text('THIS DEVICE', style: TextStyle(fontSize: 11, color: KcColors.signalGreen, fontWeight: FontWeight.bold)),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.smartphone_rounded, color: KcColors.slate400),
                          title: const Text('iPhone 15 Pro (KaratCore Mobile)'),
                          subtitle: const Text('Mumbai, India • IP: 103.22.45.98 • 2 hours ago'),
                          trailing: TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Session terminated.')),
                              );
                            },
                            child: const Text('Terminate', style: TextStyle(color: KcColors.signalRed)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
