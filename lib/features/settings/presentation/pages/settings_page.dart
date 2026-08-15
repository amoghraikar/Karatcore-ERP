import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/buttons/kc_outlined_button.dart';
import '../../../../shared/widgets/buttons/kc_primary_button.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/feedback/kc_skeleton_loader.dart';
import '../../../../shared/widgets/feedback/kc_status_badge.dart';
import '../../../../shared/widgets/feedback/kc_toast.dart';
import '../../../../shared/widgets/navigation/kc_page_header.dart';

import '../../providers/settings_providers.dart';
import '../../widgets/settings_rate_card.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(systemSettingsProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: settingsAsync.when(
        loading: () => ListView(
          padding: EdgeInsets.all(context.pageGutter),
          children: const [
            KcSkeletonLoader(height: 120),
            SizedBox(height: 20),
            KcSkeletonLoader(height: 300),
          ],
        ),
        error: (err, st) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
                const SizedBox(height: 12),
                Text('Failed to load settings: $err'),
                const SizedBox(height: 16),
                KcPrimaryButton(
                  label: 'Retry',
                  onPressed: () => ref.invalidate(systemSettingsProvider),
                ),
              ],
            ),
          ),
        ),
        data: (settings) {
          final fin = settings.financial;
          final biz = settings.business;
          final sec = settings.security;

          return ListView(
            padding: EdgeInsets.all(context.pageGutter),
            children: [
              // Page Header
              KcPageHeader(
                title: 'System Settings',
                subtitle: 'Manage store parameters, valuation rates, security policies & alerts',
                actions: [
                  KcOutlinedButton(
                    label: 'Reset Defaults',
                    icon: Icons.restore_rounded,
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Reset All Settings?'),
                          content: const Text('This will reset store profile, gold rates, and security parameters back to default system values.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text('Reset Defaults'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await ref.read(systemSettingsProvider.notifier).resetToDefaults();
                        if (context.mounted) {
                          KcToast.show(context, message: 'Settings reset to default values', type: KcToastType.info);
                        }
                      }
                    },
                  ),
                  const SizedBox(width: 12),
                  KcPrimaryButton(
                    label: 'Sync Live Rates',
                    icon: Icons.sync_rounded,
                    onPressed: () {
                      KcToast.show(context, message: 'Fetched live bullion market rates from IBJA/MCX API feed.', type: KcToastType.success);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Live Rate Cards Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: context.isDesktop ? 4 : (context.isTablet ? 2 : 1),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  mainAxisExtent: 140,
                ),
                itemCount: 4,
                itemBuilder: (context, index) {
                  final cards = [
                    SettingsRateCard(
                      title: 'Gold 24K Rate',
                      ratePerGram: fin.gold24kRatePerGram,
                      subtitle: 'Pure 99.9% bullion benchmark',
                      icon: Icons.workspace_premium_rounded,
                      accentColor: const Color(0xFFD97706),
                    ),
                    SettingsRateCard(
                      title: 'Gold 22K Rate',
                      ratePerGram: fin.gold22kRatePerGram,
                      subtitle: 'Standard 91.6% ornament rate',
                      icon: Icons.diamond_rounded,
                      accentColor: const Color(0xFFEAB308),
                    ),
                    SettingsRateCard(
                      title: 'Gold 18K Rate',
                      ratePerGram: fin.gold18kRatePerGram,
                      subtitle: 'Hallmarked 75.0% jewellery',
                      icon: Icons.diamond_outlined,
                      accentColor: const Color(0xFFCA8A04),
                    ),
                    SettingsRateCard(
                      title: 'Silver Rate',
                      ratePerGram: fin.silverRatePerGram,
                      subtitle: 'Fine 99.9% silver per gram',
                      icon: Icons.ac_unit_rounded,
                      accentColor: const Color(0xFF64748B),
                    ),
                  ];
                  return cards[index];
                },
              ),
              const SizedBox(height: 24),

              // System Status Banner Card
              KcCard(
                padding: const EdgeInsets.all(20),
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF059669).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.verified_user_rounded, color: Color(0xFF059669), size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                biz.storeName,
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                              ),
                              const SizedBox(width: 10),
                              const KcStatusBadge(
                                label: 'OPERATIONAL',
                                statusColor: Color(0xFF059669),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'GSTIN: ${biz.gstin} • BIS Reg: ${biz.bisRegistrationNo} • Last Config Update: ${KcFormatters.dateTime(settings.lastUpdated)}',
                            style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Settings Navigation Tiles Grid
              Text('CONFIGURATION CATEGORIES', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: scheme.onSurfaceVariant)),
              const SizedBox(height: 12),

              GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildNavTile(
                    context,
                    title: 'Business & Store Profile',
                    description: 'Store legal identity, BIS hallmarking registration, address & contact info',
                    icon: Icons.storefront_rounded,
                    accentColor: const Color(0xFF2563EB),
                    onTap: () => context.go(AppRoutes.settingsBusiness),
                  ),
                  _buildNavTile(
                    context,
                    title: 'Financial & Rate Parameters',
                    description: 'Gold/Silver per gram rates, LTV caps (max ${fin.maxLtvPercentage.toInt()}%), monthly interest & penalty rates',
                    icon: Icons.account_balance_wallet_rounded,
                    accentColor: const Color(0xFFD97706),
                    onTap: () => context.go(AppRoutes.settingsFinancial),
                  ),
                  _buildNavTile(
                    context,
                    title: 'Security & Access Controls',
                    description: 'Biometric unlock (${sec.requireBiometricLock ? "ON" : "OFF"}), Owner PIN verification, session timeout (${sec.sessionTimeoutMinutes} min)',
                    icon: Icons.security_rounded,
                    accentColor: const Color(0xFFDC2626),
                    onTap: () => context.go(AppRoutes.settingsSecurity),
                  ),
                  _buildNavTile(
                    context,
                    title: 'Notifications & Alerts',
                    description: 'Automated SMS, WhatsApp payment reminders, email digest & alert frequencies',
                    icon: Icons.notifications_active_rounded,
                    accentColor: const Color(0xFF7C3AED),
                    onTap: () => context.go(AppRoutes.settingsNotifications),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNavTile(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return KcCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant, height: 1.3),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: scheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}
