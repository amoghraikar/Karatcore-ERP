import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../shared/widgets/buttons/kc_primary_button.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/feedback/kc_toast.dart';
import '../../../../shared/widgets/navigation/language_selector.dart';
import '../../providers/customer_portal_providers.dart';

class CustomerProfilePage extends ConsumerStatefulWidget {
  const CustomerProfilePage({super.key});

  @override
  ConsumerState<CustomerProfilePage> createState() => _CustomerProfilePageState();
}

class _CustomerProfilePageState extends ConsumerState<CustomerProfilePage> {
  late TextEditingController _mobileCtrl;
  late TextEditingController _emailCtrl;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _mobileCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _mobileCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(currentCustomerSessionProvider);
    final profileAsync = ref.watch(customerProfileProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error loading profile: $err')),
        data: (profile) {
          if (profile == null) return const SizedBox();

          if (!_initialized) {
            _mobileCtrl.text = profile.mobile;
            _emailCtrl.text = profile.email;
            _initialized = true;
          }

          return ListView(
            padding: EdgeInsets.all(context.pageGutter),
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: const Color(0xFF7C3AED),
                    child: Text(
                      session.customerName.substring(0, 1),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(profile.fullName, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 2),
                        Text('Customer ID: ${profile.id} • Member Since 2025', style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Verified Lock Notice
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lock_rounded, color: Color(0xFF7C3AED), size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Verified identity name and PAN/Aadhaar details are locked. Contact the store counter to request verified profile updates.',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Contact & Communication Preferences
              KcCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Contact Information & Alerts', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _mobileCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Registered Mobile Number',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Email Address for Statements',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 20),
                    KcPrimaryButton(
                      label: 'Save Profile Changes',
                      icon: Icons.save_rounded,
                      onPressed: () {
                        KcToast.success(context, 'Contact preferences updated successfully.', title: 'Profile Saved');
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Address & Store Branch
              KcCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Registered Address & Store Counter', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 12),
                    Text('${profile.addressLine}, ${profile.city}, ${profile.state} - ${profile.pincode}', style: const TextStyle(fontSize: 13)),
                    const SizedBox(height: 8),
                    const Text('Primary Store Counter: M.G. Road Branch, Mumbai', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // App Language / Preferences Card
              KcCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF059669).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.language_rounded, color: Color(0xFF059669), size: 20),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.tr('language_and_regional'),
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Current: ${AppLocalizations.languageNames[ref.watch(localeProvider).languageCode] ?? "English"}',
                                  style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ],
                        ),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.translate_rounded, size: 16),
                          label: Text(context.tr('language')),
                          onPressed: () => LanguageSelector.showLanguageDialog(context, ref),
                        ),
                      ],
                    ),
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
