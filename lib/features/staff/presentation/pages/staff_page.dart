import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/components/kc_avatar.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/cards/kc_metric_card.dart';
import '../../providers/staff_providers.dart';

class StaffPage extends ConsumerWidget {
  const StaffPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStaff = ref.watch(currentStaffUserProvider);
    final initials = currentStaff.fullName.split(' ').take(2).map((e) => e.isNotEmpty ? e[0] : '').join().toUpperCase();

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(context.pageGutter),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Store Owner Dossier', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text('Proprietor account, business registration & store administrative settings', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Owner Metric Cards
          const Row(
            children: [
              Expanded(
                child: KcMetricCard(
                  title: 'Account Status',
                  value: 'Active Owner',
                  trend: 'Full System Un-restricted',
                  icon: Icons.verified_user_rounded,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: KcMetricCard(
                  title: 'Store Location',
                  value: 'Zaveri Bazaar HQ',
                  trend: 'Primary Vault Registered',
                  icon: Icons.storefront_rounded,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: KcMetricCard(
                  title: 'Operating Model',
                  value: 'Proprietorship',
                  trend: 'Direct Owner + Customer ERP',
                  icon: Icons.business_center_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Proprietor Details Card
          KcCard(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                KcAvatar(initials: initials, size: 64),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(currentStaff.fullName, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(color: const Color(0xFF7C3AED).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                            child: const Text('PROPRIETOR / OWNER', style: TextStyle(color: Color(0xFF7C3AED), fontWeight: FontWeight.w800, fontSize: 11)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('${currentStaff.employeeId} • ${currentStaff.email} • ${currentStaff.mobile}', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      const SizedBox(height: 4),
                      Text('Assigned Branch: ${currentStaff.branchName} • Joining Date: ${KcFormatters.date(currentStaff.joiningDate)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          KcCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Business & Store Configuration', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                _detailRow(context, 'Business Legal Name', 'Verma Jewellery & Gold Loan Pvt Ltd'),
                _detailRow(context, 'BIS Hallmarking Registration', 'BIS-HM-MH-400002-9812'),
                _detailRow(context, 'GSTIN Identification Number', '27AAACV9812A1Z4'),
                _detailRow(context, 'RBI Pawn Broking License', 'RBI-PB-MUM-2022-0419'),
                _detailRow(context, 'Primary Store Address', '128 Zaveri Bazaar, Kalbadevi, Mumbai, MH 400002'),
                _detailRow(context, 'System Architecture', 'Single-Owner ERP Direct Model'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ),
    );
  }
}
