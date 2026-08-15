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
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

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
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final authState = ref.watch(authStateProvider);
    final user = authState.session;

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
                                user?.name ?? 'Arjun Rathore',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                              ),
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
                      '${user?.email ?? "arjun@karatcore.com"} • ${user?.phone ?? "+91 98200 12345"}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Assigned Branch: ${user?.branch?.name ?? "Main Branch (Bandra)"}',
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
                                user?.name ?? 'Arjun Rathore',
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
                          const SizedBox(height: 4),
                          Text(
                            '${user?.email ?? "arjun@karatcore.com"} • ${user?.phone ?? "+91 98200 12345"}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Assigned Branch: ${user?.branch?.name ?? "Main Branch (Bandra)"}',
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
                        const SizedBox(height: 16),
                        if (context.isMobile) ...[
                          KcTextField(label: 'Full Name', hintText: user?.name ?? 'Arjun Rathore'),
                          const SizedBox(height: 14),
                          KcTextField(label: 'Email Address', hintText: user?.email ?? 'arjun@karatcore.com'),
                          const SizedBox(height: 14),
                          KcTextField(label: 'Mobile Phone', hintText: user?.phone ?? '+91 98200 12345'),
                          const SizedBox(height: 14),
                          KcTextField(label: 'Role Scope', hintText: user?.role.label ?? 'Owner'),
                        ] else ...[
                          Row(
                            children: [
                              Expanded(child: KcTextField(label: 'Full Name', hintText: user?.name ?? 'Arjun Rathore')),
                              const SizedBox(width: 16),
                              Expanded(child: KcTextField(label: 'Email Address', hintText: user?.email ?? 'arjun@karatcore.com')),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: KcTextField(label: 'Mobile Phone', hintText: user?.phone ?? '+91 98200 12345')),
                              const SizedBox(width: 16),
                              Expanded(child: KcTextField(label: 'Role Scope', hintText: user?.role.label ?? 'Owner')),
                            ],
                          ),
                        ],
                        const SizedBox(height: 24),
                        KcPrimaryButton(
                          label: 'Save Profile Changes',
                          icon: Icons.save_rounded,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Profile details updated successfully.')),
                            );
                          },
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
                        KcPasswordField(controller: _newPasswordController, label: 'New Password'),
                        const SizedBox(height: 12),
                        KcPasswordField(controller: _confirmPasswordController, label: 'Confirm New Password'),
                        const SizedBox(height: 16),
                        KcPrimaryButton(
                          label: 'Update Password',
                          icon: Icons.shield_rounded,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Security password updated.'),
                                backgroundColor: KcColors.signalGreen,
                              ),
                            );
                          },
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
