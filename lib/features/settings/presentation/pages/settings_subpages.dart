import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/buttons/kc_primary_button.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/feedback/kc_toast.dart';
import '../../../notifications/models/notification_models.dart';
import '../../../notifications/providers/notification_providers.dart';

class SettingsSecurityPage extends StatelessWidget {
  const SettingsSecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(context.pageGutter),
        children: [
          Text('Security Settings', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('Owner authentication, PIN lock, and biometric verification parameters', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 24),
          const KcCard(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Owner Authentication & App Lock', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                SizedBox(height: 12),
                SwitchListTile(
                  title: Text('Require TouchID / FaceID Biometric Lock'),
                  subtitle: Text('Prompt for biometric verification when app is opened'),
                  value: true,
                  onChanged: null,
                ),
                Divider(),
                SwitchListTile(
                  title: Text('Sensitive Action Confirmation'),
                  subtitle: Text('Prompt for owner confirmation before loan disburse / settlement'),
                  value: true,
                  onChanged: null,
                ),
                Divider(),
                SwitchListTile(
                  title: Text('Auto-Lock Inactive Session'),
                  subtitle: Text('Lock screen after 15 minutes of inactivity'),
                  value: true,
                  onChanged: null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsBusinessPage extends StatefulWidget {
  const SettingsBusinessPage({super.key});

  @override
  State<SettingsBusinessPage> createState() => _SettingsBusinessPageState();
}

class _SettingsBusinessPageState extends State<SettingsBusinessPage> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _bisCtrl;
  late final TextEditingController _gstCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: 'Verma Jewellery & Gold Loan Pvt Ltd');
    _bisCtrl = TextEditingController(text: 'BIS-HM-MH-400002-9812');
    _gstCtrl = TextEditingController(text: '27AAACV9812A1Z4');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bisCtrl.dispose();
    _gstCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(context.pageGutter),
        children: [
          Text('Business Profile Settings', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('Store legal identity, BIS registration & GSTIN details', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 24),
          KcCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Legal Proprietorship Entity', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(labelText: 'Store Legal Name', border: OutlineInputBorder()),
                  controller: _nameCtrl,
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(labelText: 'BIS Hallmarking Registration Number', border: OutlineInputBorder()),
                  controller: _bisCtrl,
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(labelText: 'GSTIN Registration', border: OutlineInputBorder()),
                  controller: _gstCtrl,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsFinancialPage extends StatefulWidget {
  const SettingsFinancialPage({super.key});

  @override
  State<SettingsFinancialPage> createState() => _SettingsFinancialPageState();
}

class _SettingsFinancialPageState extends State<SettingsFinancialPage> {
  late final TextEditingController _rateCtrl;
  late final TextEditingController _ltvCtrl;

  @override
  void initState() {
    super.initState();
    _rateCtrl = TextEditingController(text: '12.0% p.a.');
    _ltvCtrl = TextEditingController(text: '75.0% LTV (RBI Benchmark)');
  }

  @override
  void dispose() {
    _rateCtrl.dispose();
    _ltvCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(context.pageGutter),
        children: [
          Text('Financial Parameters', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('Interest rate rules, LTV limits & pawn broking terms', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 24),
          KcCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Default Gold Loan Rate Terms', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(labelText: 'Standard Annual Interest Rate (%)', border: OutlineInputBorder()),
                  controller: _rateCtrl,
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(labelText: 'Maximum Loan-To-Value (LTV Cap %)', border: OutlineInputBorder()),
                  controller: _ltvCtrl,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsNotificationsPage extends ConsumerStatefulWidget {
  const SettingsNotificationsPage({super.key});

  @override
  ConsumerState<SettingsNotificationsPage> createState() => _SettingsNotificationsPageState();
}

class _SettingsNotificationsPageState extends ConsumerState<SettingsNotificationsPage> {
  late NotificationPreferencesModel _prefs;
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final prefsAsync = ref.watch(notificationPreferencesNotifierProvider);

    return Scaffold(
      body: prefsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error loading preferences: $err')),
        data: (savedPrefs) {
          if (!_initialized) {
            _prefs = savedPrefs;
            _initialized = true;
          }

          return ListView(
            padding: EdgeInsets.all(context.pageGutter),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Notification & Communication Preferences', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text('Store Owner alert rules, Quiet Hours parameters & customer channel dispatch controls', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  KcPrimaryButton(
                    label: 'Save Preferences',
                    icon: Icons.save_rounded,
                    onPressed: () async {
                      await ref.read(notificationPreferencesNotifierProvider.notifier).updatePreferences(_prefs);
                      if (context.mounted) {
                        KcToast.success(context, 'Notification and alert preferences saved successfully.', title: 'Preferences Saved');
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Owner Business Alerts
              KcCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Owner Alert Category Subscriptions', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('Pledge & Loan Due Alerts'),
                      subtitle: const Text('Notify 30, 7, and 1 days before loan installment due dates'),
                      value: _prefs.loanAlertsEnabled,
                      onChanged: (val) => setState(() => _prefs = _prefs.copyWith(loanAlertsEnabled: val)),
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('Payment & Receipt Confirmations'),
                      subtitle: const Text('Notify upon payment recording and digital receipt generation'),
                      value: _prefs.paymentAlertsEnabled,
                      onChanged: (val) => setState(() => _prefs = _prefs.copyWith(paymentAlertsEnabled: val)),
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('KYC Verification Review Requests'),
                      subtitle: const Text('Notify when new customer KYC documents require Store Owner review'),
                      value: _prefs.kycAlertsEnabled,
                      onChanged: (val) => setState(() => _prefs = _prefs.copyWith(kycAlertsEnabled: val)),
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('Security & Device Monitor Alerts'),
                      subtitle: const Text('Notify on web terminal logins, session locks & biometric actions'),
                      value: _prefs.securityAlertsEnabled,
                      onChanged: (val) => setState(() => _prefs = _prefs.copyWith(securityAlertsEnabled: val)),
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('Accounting & System Engine Alerts'),
                      subtitle: const Text('Notify on monthly ledger period closes & database backup reminders'),
                      value: _prefs.systemAlertsEnabled,
                      onChanged: (val) => setState(() => _prefs = _prefs.copyWith(systemAlertsEnabled: val)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Communication Channel Settings
              KcCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Communication Delivery Channels', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 4),
                    const Text('In-App delivery is active. External channels are placeholder architecture.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('In-App Notification Center'),
                      subtitle: const Text('Active internal notification feed (Always Recommended)'),
                      value: _prefs.inAppChannelEnabled,
                      onChanged: (val) => setState(() => _prefs = _prefs.copyWith(inAppChannelEnabled: val)),
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('Email Gateway (Placeholder Architecture)'),
                      subtitle: const Text('Simulated email dispatch for reports and ledger statements'),
                      value: _prefs.emailChannelEnabled,
                      onChanged: (val) => setState(() => _prefs = _prefs.copyWith(emailChannelEnabled: val)),
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('SMS Gateway (Placeholder Architecture)'),
                      subtitle: const Text('Simulated SMS dispatch for loan due reminders'),
                      value: _prefs.smsChannelEnabled,
                      onChanged: (val) => setState(() => _prefs = _prefs.copyWith(smsChannelEnabled: val)),
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('WhatsApp Business API (Placeholder Architecture)'),
                      subtitle: const Text('Simulated WhatsApp receipt & pledge updates'),
                      value: _prefs.whatsappChannelEnabled,
                      onChanged: (val) => setState(() => _prefs = _prefs.copyWith(whatsappChannelEnabled: val)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Quiet Hours Configuration
              KcCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Store Quiet Hours Configuration', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('Enable Store Quiet Hours'),
                      subtitle: const Text('Suppress non-urgent notifications during off-business hours'),
                      value: _prefs.quietHours.isEnabled,
                      onChanged: (val) => setState(() {
                        _prefs = _prefs.copyWith(
                          quietHours: _prefs.quietHours.copyWith(isEnabled: val),
                        );
                      }),
                    ),
                    if (_prefs.quietHours.isEnabled) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(labelText: 'Start Time (e.g. 22:00)', border: OutlineInputBorder()),
                              controller: TextEditingController(text: _prefs.quietHours.startTime),
                              onChanged: (v) => _prefs = _prefs.copyWith(quietHours: _prefs.quietHours.copyWith(startTime: v)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(labelText: 'End Time (e.g. 08:00)', border: OutlineInputBorder()),
                              controller: TextEditingController(text: _prefs.quietHours.endTime),
                              onChanged: (v) => _prefs = _prefs.copyWith(quietHours: _prefs.quietHours.copyWith(endTime: v)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        title: const Text('Allow Critical Security Exceptions'),
                        subtitle: const Text('Deliver urgent security and high-value overdue alerts during quiet hours'),
                        value: _prefs.quietHours.allowCriticalExceptions,
                        onChanged: (val) => setState(() {
                          _prefs = _prefs.copyWith(
                            quietHours: _prefs.quietHours.copyWith(allowCriticalExceptions: val),
                          );
                        }),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
