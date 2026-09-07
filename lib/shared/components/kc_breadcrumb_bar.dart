import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/localization/app_localizations.dart';
import '../models/breadcrumb_item.dart';

class KcBreadcrumbBar extends StatelessWidget {
  const KcBreadcrumbBar({super.key, required this.items});
  final List<BreadcrumbItem> items;

  static const Map<String, String> _breadcrumbKeyMap = {
    'Dashboard': 'dashboard',
    'Customers': 'customers',
    'KYC Verification': 'kyc_verification',
    'Ornaments & Inventory': 'inventory_and_stock',
    'Gold Loans': 'loans',
    'Reports & Analytics': 'reports_and_analytics',
    'Accounting Ledger': 'accounting_ledger',
    'Audit Log': 'audit_log',
    'Security Activity': 'security_activity',
    'Notifications': 'notifications',
    'Owner Profile': 'owner_profile',
    'Store Settings': 'store_settings',
    'Help & Docs': 'help_and_docs',
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ),
            InkWell(
              onTap: items[i].path != null ? () => context.go(items[i].path!) : null,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  _breadcrumbKeyMap[items[i].label] != null
                      ? context.tr(_breadcrumbKeyMap[items[i].label]!)
                      : items[i].label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: i == items.length - 1
                            ? scheme.onSurface
                            : scheme.onSurfaceVariant,
                        fontWeight: i == items.length - 1
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
