import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/routes.dart';

class KcMobileAppGridSheet extends ConsumerWidget {
  const KcMobileAppGridSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const KcMobileAppGridSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const modules = [
      _ModuleItem('Dashboard', Icons.dashboard_rounded, AppRoutes.dashboard, Color(0xFF2563EB)),
      _ModuleItem('Customers', Icons.people_alt_rounded, AppRoutes.customers, Color(0xFF059669)),
      _ModuleItem('Gold Loans', Icons.account_balance_rounded, AppRoutes.loans, Color(0xFFD97706)),
      _ModuleItem('Ornaments', Icons.diamond_rounded, AppRoutes.ornaments, Color(0xFF7C3AED)),
      _ModuleItem('KYC Queue', Icons.verified_user_rounded, AppRoutes.kyc, Color(0xFF0284C7)),
      _ModuleItem('Accounting', Icons.account_balance_wallet_rounded, AppRoutes.accounting, Color(0xFF059669)),
      _ModuleItem('Expenses', Icons.receipt_long_rounded, AppRoutes.expenses, Color(0xFFDC2626)),
      _ModuleItem('Reports', Icons.bar_chart_rounded, AppRoutes.reports, Color(0xFF4F46E5)),
      _ModuleItem('Audit Logs', Icons.shield_rounded, AppRoutes.securityActivity, Color(0xFF64748B)),
      _ModuleItem('Settings', Icons.settings_rounded, AppRoutes.settings, Color(0xFF475569)),
      _ModuleItem('Help & Specs', Icons.help_outline_rounded, AppRoutes.help, Color(0xFF0284C7)),
      _ModuleItem('Store Profile', Icons.person_rounded, AppRoutes.profile, Color(0xFF7C3AED)),
    ];

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle indicator
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'All Store Modules',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tap any section to launch',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 4-Column Responsive Grid
            Flexible(
              child: SingleChildScrollView(
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.82,
                  ),
                  itemCount: modules.length,
                  itemBuilder: (context, index) {
                    final item = modules[index];
                    return InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        context.go(item.route);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: item.color.withValues(alpha: isDark ? 0.2 : 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(item.icon, color: item.color, size: 24),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.title,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModuleItem {
  const _ModuleItem(this.title, this.icon, this.route, this.color);
  final String title;
  final IconData icon;
  final String route;
  final Color color;
}
