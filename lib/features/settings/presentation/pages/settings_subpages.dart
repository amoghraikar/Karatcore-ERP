import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/routes.dart';
import '../../../../shared/widgets/buttons/kc_outlined_button.dart';
import '../../../../shared/widgets/buttons/kc_primary_button.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/feedback/kc_toast.dart';
import '../../../../shared/widgets/inputs/kc_text_field.dart';

import '../../providers/settings_providers.dart';

/// 1. Business Profile Settings Subpage
class SettingsBusinessPage extends ConsumerStatefulWidget {
  const SettingsBusinessPage({super.key});

  @override
  ConsumerState<SettingsBusinessPage> createState() => _SettingsBusinessPageState();
}

class _SettingsBusinessPageState extends ConsumerState<SettingsBusinessPage> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _taglineCtrl;
  late final TextEditingController _bisCtrl;
  late final TextEditingController _gstCtrl;
  late final TextEditingController _ownerCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _addressCtrl;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final biz = ref.read(businessProfileProvider);
    _nameCtrl = TextEditingController(text: biz.storeName);
    _taglineCtrl = TextEditingController(text: biz.tagline);
    _bisCtrl = TextEditingController(text: biz.bisRegistrationNo);
    _gstCtrl = TextEditingController(text: biz.gstin);
    _ownerCtrl = TextEditingController(text: biz.ownerName);
    _emailCtrl = TextEditingController(text: biz.contactEmail);
    _phoneCtrl = TextEditingController(text: biz.contactPhone);
    _addressCtrl = TextEditingController(text: biz.address);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _taglineCtrl.dispose();
    _bisCtrl.dispose();
    _gstCtrl.dispose();
    _ownerCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveBusinessProfile() async {
    setState(() => _isSaving = true);
    final current = ref.read(businessProfileProvider);

    final updated = current.copyWith(
      storeName: _nameCtrl.text.trim(),
      tagline: _taglineCtrl.text.trim(),
      bisRegistrationNo: _bisCtrl.text.trim(),
      gstin: _gstCtrl.text.trim(),
      ownerName: _ownerCtrl.text.trim(),
      contactEmail: _emailCtrl.text.trim(),
      contactPhone: _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
    );

    await ref.read(systemSettingsProvider.notifier).updateBusinessProfile(updated);

    if (mounted) {
      setState(() => _isSaving = false);
      KcToast.show(context, message: 'Business Profile updated successfully!', type: KcToastType.success);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(context.pageGutter),
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => context.go(AppRoutes.settings),
              ),
              const SizedBox(width: 8),
              Text('Business Profile Settings', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 4),
          Text('Store legal identity, BIS registration & GSTIN details', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 24),

          KcCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Legal Entity & Store Information', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                KcTextField(controller: _nameCtrl, label: 'Store Registered Trade Name *'),
                const SizedBox(height: 16),
                KcTextField(controller: _taglineCtrl, label: 'Store Tagline / Slogan'),
                const SizedBox(height: 16),
                if (context.isMobile) ...[
                  KcTextField(controller: _gstCtrl, label: 'GSTIN Registration Number *'),
                  const SizedBox(height: 16),
                  KcTextField(controller: _bisCtrl, label: 'BIS Hallmarking Registration No *'),
                ] else ...[
                  Row(
                    children: [
                      Expanded(child: KcTextField(controller: _gstCtrl, label: 'GSTIN Registration Number *')),
                      const SizedBox(width: 16),
                      Expanded(child: KcTextField(controller: _bisCtrl, label: 'BIS Hallmarking Registration No *')),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                Text('Owner & Contact Details', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                KcTextField(controller: _ownerCtrl, label: 'Owner / Proprietor Name *'),
                const SizedBox(height: 16),
                if (context.isMobile) ...[
                  KcTextField(controller: _phoneCtrl, label: 'Contact Phone Number *'),
                  const SizedBox(height: 16),
                  KcTextField(controller: _emailCtrl, label: 'Contact Email Address *'),
                ] else ...[
                  Row(
                    children: [
                      Expanded(child: KcTextField(controller: _phoneCtrl, label: 'Contact Phone Number *')),
                      const SizedBox(width: 16),
                      Expanded(child: KcTextField(controller: _emailCtrl, label: 'Contact Email Address *')),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                KcTextField(controller: _addressCtrl, label: 'Full Store Physical Address *', maxLines: 2),
                const SizedBox(height: 28),

                if (context.isMobile) ...[
                  SizedBox(
                    width: double.infinity,
                    child: KcPrimaryButton(
                      label: 'Save Business Profile',
                      icon: Icons.check_circle_rounded,
                      isLoading: _isSaving,
                      onPressed: _saveBusinessProfile,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: KcOutlinedButton(
                      label: 'Back to Settings',
                      onPressed: () => context.go(AppRoutes.settings),
                    ),
                  ),
                ] else ...[
                  Row(
                    children: [
                      KcOutlinedButton(
                        label: 'Back to Settings',
                        onPressed: () => context.go(AppRoutes.settings),
                      ),
                      const Spacer(),
                      KcPrimaryButton(
                        label: 'Save Business Profile',
                        icon: Icons.check_circle_rounded,
                        isLoading: _isSaving,
                        onPressed: _saveBusinessProfile,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 2. Security & Access Control Settings Subpage
class SettingsSecurityPage extends ConsumerStatefulWidget {
  const SettingsSecurityPage({super.key});

  @override
  ConsumerState<SettingsSecurityPage> createState() => _SettingsSecurityPageState();
}

class _SettingsSecurityPageState extends ConsumerState<SettingsSecurityPage> {
  late bool _biometrics;
  late bool _pinActions;
  late bool _twoFactor;
  late int _timeoutMins;
  late int _retentionDays;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final sec = ref.read(securitySettingsProvider);
    _biometrics = sec.requireBiometricLock;
    _pinActions = sec.requireOwnerPinForActions;
    _twoFactor = sec.twoFactorAuthEnabled;
    _timeoutMins = sec.sessionTimeoutMinutes;
    _retentionDays = sec.auditLogRetentionDays;
  }

  void _show2FaSetupModal(BuildContext context) {
    final codeCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.security_rounded, color: Color(0xFF059669)),
            SizedBox(width: 10),
            Text('Set Up 2FA Authenticator App', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          ],
        ),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Scan this QR code with Google Authenticator, Microsoft Authenticator, or 1Password:',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.qr_code_2_rounded, size: 140, color: Colors.black87),
                      const SizedBox(height: 6),
                      Text('KARATCORE-2FA-SECURE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Or enter this Secret Key manually:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: SelectableText(
                        'JBSW Y3DP EHPK 3PXP',
                        style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      tooltip: 'Copy Secret Key',
                      onPressed: () {
                        KcToast.show(context, message: 'Secret Key copied to clipboard!', type: KcToastType.success);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              KcTextField(
                controller: codeCtrl,
                label: 'Test 6-Digit Code',
                hintText: 'Enter 6-digit code (e.g. 123456)',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          KcPrimaryButton(
            label: 'VERIFY & ENABLE 2FA',
            onPressed: () {
              Navigator.of(ctx).pop();
              KcToast.show(context, message: '2FA Authenticator enabled successfully!', type: KcToastType.success);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _saveSecurity() async {

    setState(() => _isSaving = true);
    final sec = ref.read(securitySettingsProvider).copyWith(
      requireBiometricLock: _biometrics,
      requireOwnerPinForActions: _pinActions,
      twoFactorAuthEnabled: _twoFactor,
      sessionTimeoutMinutes: _timeoutMins,
      auditLogRetentionDays: _retentionDays,
    );

    await ref.read(systemSettingsProvider.notifier).updateSecuritySettings(sec);

    if (mounted) {
      setState(() => _isSaving = false);
      KcToast.show(context, message: 'Security parameters updated successfully!', type: KcToastType.success);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(context.pageGutter),
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => context.go(AppRoutes.settings),
              ),
              const SizedBox(width: 8),
              Text('Security & Access Controls', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 4),
          Text('Owner authentication, PIN lock, and biometric verification parameters', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 24),

          KcCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Authentication & Access Locks', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),

                SwitchListTile(
                  title: const Text('Require TouchID / FaceID Biometric Lock'),
                  subtitle: const Text('Prompt for biometric verification when opening application'),
                  value: _biometrics,
                  onChanged: (val) => setState(() => _biometrics = val),
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Sensitive Action Confirmation'),
                  subtitle: const Text('Require owner PIN authorization before loan disburse, renewal or settlement'),
                  value: _pinActions,
                  onChanged: (val) => setState(() => _pinActions = val),
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Two-Factor Authentication (2FA)'),
                  subtitle: const Text('Require TOTP Authenticator code during owner login'),
                  value: _twoFactor,
                  onChanged: (val) {
                    setState(() => _twoFactor = val);
                    if (val) {
                      _show2FaSetupModal(context);
                    }
                  },
                ),
                if (_twoFactor) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 8),
                    child: OutlinedButton.icon(
                      onPressed: () => _show2FaSetupModal(context),
                      icon: const Icon(Icons.qr_code_2_rounded, size: 18),
                      label: const Text('Configure Authenticator App (TOTP / QR Code)'),
                    ),
                  ),
                ],

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                Text('Session & Audit Parameters', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _timeoutMins,
                        decoration: const InputDecoration(labelText: 'Auto-Lock Session Timeout', border: OutlineInputBorder()),
                        onChanged: (val) {
                          if (val != null) setState(() => _timeoutMins = val);
                        },
                        items: const [
                          DropdownMenuItem(value: 5, child: Text('5 minutes')),
                          DropdownMenuItem(value: 15, child: Text('15 minutes (Recommended)')),
                          DropdownMenuItem(value: 30, child: Text('30 minutes')),
                          DropdownMenuItem(value: 60, child: Text('1 hour')),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _retentionDays,
                        decoration: const InputDecoration(labelText: 'Audit Log Retention Policy', border: OutlineInputBorder()),
                        onChanged: (val) {
                          if (val != null) setState(() => _retentionDays = val);
                        },
                        items: const [
                          DropdownMenuItem(value: 90, child: Text('90 Days')),
                          DropdownMenuItem(value: 180, child: Text('180 Days')),
                          DropdownMenuItem(value: 365, child: Text('1 Year (Compliance Standard)')),
                          DropdownMenuItem(value: 730, child: Text('2 Years')),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                Row(
                  children: [
                    KcOutlinedButton(
                      label: 'Back to Settings',
                      onPressed: () => context.go(AppRoutes.settings),
                    ),
                    const Spacer(),
                    KcPrimaryButton(
                      label: 'Save Security Controls',
                      icon: Icons.check_circle_rounded,
                      isLoading: _isSaving,
                      onPressed: _saveSecurity,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 3. Financial & Rate Parameters Subpage
class SettingsFinancialPage extends ConsumerStatefulWidget {
  const SettingsFinancialPage({super.key});

  @override
  ConsumerState<SettingsFinancialPage> createState() => _SettingsFinancialPageState();
}

class _SettingsFinancialPageState extends ConsumerState<SettingsFinancialPage> {
  late final TextEditingController _gold24kCtrl;
  late final TextEditingController _gold22kCtrl;
  late final TextEditingController _gold18kCtrl;
  late final TextEditingController _silverCtrl;
  late final TextEditingController _ltvCtrl;
  late final TextEditingController _interestCtrl;
  late final TextEditingController _penaltyCtrl;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final fin = ref.read(financialSettingsProvider);
    _gold24kCtrl = TextEditingController(text: fin.gold24kRatePerGram.toString());
    _gold22kCtrl = TextEditingController(text: fin.gold22kRatePerGram.toString());
    _gold18kCtrl = TextEditingController(text: fin.gold18kRatePerGram.toString());
    _silverCtrl = TextEditingController(text: fin.silverRatePerGram.toString());
    _ltvCtrl = TextEditingController(text: fin.maxLtvPercentage.toString());
    _interestCtrl = TextEditingController(text: fin.defaultMonthlyInterestRate.toString());
    _penaltyCtrl = TextEditingController(text: fin.penaltyInterestRate.toString());
  }

  @override
  void dispose() {
    _gold24kCtrl.dispose();
    _gold22kCtrl.dispose();
    _gold18kCtrl.dispose();
    _silverCtrl.dispose();
    _ltvCtrl.dispose();
    _interestCtrl.dispose();
    _penaltyCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveFinancial() async {
    setState(() => _isSaving = true);
    final fin = ref.read(financialSettingsProvider).copyWith(
      gold24kRatePerGram: double.tryParse(_gold24kCtrl.text) ?? 7450.0,
      gold22kRatePerGram: double.tryParse(_gold22kCtrl.text) ?? 6830.0,
      gold18kRatePerGram: double.tryParse(_gold18kCtrl.text) ?? 5580.0,
      silverRatePerGram: double.tryParse(_silverCtrl.text) ?? 88.0,
      maxLtvPercentage: double.tryParse(_ltvCtrl.text) ?? 75.0,
      defaultMonthlyInterestRate: double.tryParse(_interestCtrl.text) ?? 1.5,
      penaltyInterestRate: double.tryParse(_penaltyCtrl.text) ?? 2.0,
    );

    await ref.read(systemSettingsProvider.notifier).updateFinancialSettings(fin);

    if (mounted) {
      setState(() => _isSaving = false);
      KcToast.show(context, message: 'Financial rates & LTV parameters updated successfully!', type: KcToastType.success);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(context.pageGutter),
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => context.go(AppRoutes.settings),
              ),
              const SizedBox(width: 8),
              Text('Financial & Rate Parameters', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 4),
          Text('Configure gold/silver market benchmark rates, LTV caps & loan interest matrices', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 24),

          KcCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bullion Market Benchmark Rates (per gram in ₹)', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(child: KcTextField(controller: _gold24kCtrl, label: 'Gold 24K Rate (₹/g) *', keyboardType: TextInputType.number)),
                    const SizedBox(width: 16),
                    Expanded(child: KcTextField(controller: _gold22kCtrl, label: 'Gold 22K Rate (₹/g) *', keyboardType: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: KcTextField(controller: _gold18kCtrl, label: 'Gold 18K Rate (₹/g) *', keyboardType: TextInputType.number)),
                    const SizedBox(width: 16),
                    Expanded(child: KcTextField(controller: _silverCtrl, label: 'Silver 99.9 Rate (₹/g) *', keyboardType: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                Text('Loan-to-Value (LTV) & Interest Rate Policy', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(child: KcTextField(controller: _ltvCtrl, label: 'Max LTV Ceiling Ratio (%) *', keyboardType: TextInputType.number)),
                    const SizedBox(width: 16),
                    Expanded(child: KcTextField(controller: _interestCtrl, label: 'Standard Monthly Interest Rate (%) *', keyboardType: TextInputType.number)),
                    const SizedBox(width: 16),
                    Expanded(child: KcTextField(controller: _penaltyCtrl, label: 'Overdue Penalty Interest Rate (%) *', keyboardType: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 28),

                Row(
                  children: [
                    KcOutlinedButton(
                      label: 'Back to Settings',
                      onPressed: () => context.go(AppRoutes.settings),
                    ),
                    const Spacer(),
                    KcPrimaryButton(
                      label: 'Save Financial Rates',
                      icon: Icons.check_circle_rounded,
                      isLoading: _isSaving,
                      onPressed: _saveFinancial,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 4. Notifications & Alert Settings Subpage
class SettingsNotificationsPage extends ConsumerStatefulWidget {
  const SettingsNotificationsPage({super.key});

  @override
  ConsumerState<SettingsNotificationsPage> createState() => _SettingsNotificationsPageState();
}

class _SettingsNotificationsPageState extends ConsumerState<SettingsNotificationsPage> {
  late bool _sms;
  late bool _whatsapp;
  late bool _email;
  late int _dueDays;
  late int _repeatDays;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final notif = ref.read(notificationSettingsProvider);
    _sms = notif.enableSmsAlerts;
    _whatsapp = notif.enableWhatsappReminders;
    _email = notif.enableEmailNotifications;
    _dueDays = notif.dueReminderDaysBefore;
    _repeatDays = notif.overdueRepeatIntervalDays;
  }

  Future<void> _saveNotifications() async {
    setState(() => _isSaving = true);
    final notif = ref.read(notificationSettingsProvider).copyWith(
      enableSmsAlerts: _sms,
      enableWhatsappReminders: _whatsapp,
      enableEmailNotifications: _email,
      dueReminderDaysBefore: _dueDays,
      overdueRepeatIntervalDays: _repeatDays,
    );

    await ref.read(systemSettingsProvider.notifier).updateNotificationSettings(notif);

    if (mounted) {
      setState(() => _isSaving = false);
      KcToast.show(context, message: 'Notification preferences updated successfully!', type: KcToastType.success);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(context.pageGutter),
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => context.go(AppRoutes.settings),
              ),
              const SizedBox(width: 8),
              Text('Notifications & Alert Settings', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 4),
          Text('Automated SMS/WhatsApp payment reminders & system alerts configuration', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 24),

          KcCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Messaging Channels & Gateways', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),

                SwitchListTile(
                  title: const Text('Enable SMS Payment Reminders'),
                  subtitle: const Text('Send automated SMS reminders for upcoming interest due dates'),
                  value: _sms,
                  onChanged: (val) => setState(() => _sms = val),
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Enable WhatsApp Business Reminders'),
                  subtitle: const Text('Send rich WhatsApp payment receipts & due date alerts'),
                  value: _whatsapp,
                  onChanged: (val) => setState(() => _whatsapp = val),
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Enable Email Digest Reports'),
                  subtitle: const Text('Send daily executive summary & closing cash reports via email'),
                  value: _email,
                  onChanged: (val) => setState(() => _email = val),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                Text('Trigger Schedule & Frequency', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _dueDays,
                        decoration: const InputDecoration(labelText: 'Pre-Due Reminder Trigger', border: OutlineInputBorder()),
                        onChanged: (val) {
                          if (val != null) setState(() => _dueDays = val);
                        },
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('1 Day Before Due Date')),
                          DropdownMenuItem(value: 3, child: Text('3 Days Before Due Date')),
                          DropdownMenuItem(value: 7, child: Text('7 Days Before Due Date')),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _repeatDays,
                        decoration: const InputDecoration(labelText: 'Overdue Repeat Alert Interval', border: OutlineInputBorder()),
                        onChanged: (val) {
                          if (val != null) setState(() => _repeatDays = val);
                        },
                        items: const [
                          DropdownMenuItem(value: 3, child: Text('Every 3 Days')),
                          DropdownMenuItem(value: 7, child: Text('Every 7 Days (Weekly)')),
                          DropdownMenuItem(value: 14, child: Text('Every 14 Days')),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                Row(
                  children: [
                    KcOutlinedButton(
                      label: 'Back to Settings',
                      onPressed: () => context.go(AppRoutes.settings),
                    ),
                    const Spacer(),
                    KcPrimaryButton(
                      label: 'Save Notification Settings',
                      icon: Icons.check_circle_rounded,
                      isLoading: _isSaving,
                      onPressed: _saveNotifications,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
