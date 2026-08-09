import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/cards/kc_card.dart';

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

class SettingsNotificationsPage extends StatelessWidget {
  const SettingsNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(context.pageGutter),
        children: [
          Text('Notification Preferences', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('Customer SMS alerts, due-date reminders & operational push notifications', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 24),
          const KcCard(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Alert Dispatch Controls', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                SizedBox(height: 12),
                SwitchListTile(
                  title: Text('Customer Interest Due SMS Alerts'),
                  subtitle: Text('Automatically send SMS 7 days prior to interest payment due date'),
                  value: true,
                  onChanged: null,
                ),
                Divider(),
                SwitchListTile(
                  title: Text('Pledge Intake Payment Receipts'),
                  subtitle: Text('Instantly send digital receipt SMS upon pledge creation or payment'),
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
