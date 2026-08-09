import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/routes.dart';
import '../../../../shared/widgets/feedback/kc_skeleton_loader.dart';

import '../../providers/reports_providers.dart';
import '../../widgets/activity_feed_widget.dart';
import '../../widgets/report_date_filter.dart';
import '../../widgets/report_table.dart';
import '../../widgets/report_error_state.dart';

class OperationalReportsPage extends ConsumerWidget {
  const OperationalReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staffAsync = ref.watch(staffPerformanceProvider);

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(context.pageGutter),
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => context.go(AppRoutes.reports),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Operational & Staff Performance Reports', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text('Daily processing velocity, staff action metrics & store operational activity feed', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          const ReportDateFilter(),
          const SizedBox(height: 20),

          // Staff Performance Report Table
          Text('Staff Operational Performance Metrics Table', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),

          staffAsync.when(
            loading: () => const KcSkeletonLoader(height: 300),
            error: (err, st) => ReportErrorState(error: err, onRetry: () => ref.invalidate(staffPerformanceProvider)),
            data: (staffList) {
              final rows = staffList.map((s) {
                return {
                  'staffName': s.staffName,
                  'role': s.role,
                  'loansProcessed': s.loansProcessed.toString(),
                  'kycReviews': s.kycReviews.toString(),
                  'customersAdded': s.customersAdded.toString(),
                  'paymentsRecorded': s.paymentsRecorded.toString(),
                  'inventoryMovements': s.inventoryMovements.toString(),
                  'avgProcessingTime': '${s.avgProcessingTimeMinutes} mins',
                };
              }).toList();

              return ReportTable(
                title: 'Staff Performance Activity Report',
                columns: const [
                  ReportColumnConfig(key: 'staffName', label: 'Staff Member'),
                  ReportColumnConfig(key: 'role', label: 'Role'),
                  ReportColumnConfig(key: 'loansProcessed', label: 'Loans Disbursed', isNumeric: true),
                  ReportColumnConfig(key: 'kycReviews', label: 'KYC Reviews', isNumeric: true),
                  ReportColumnConfig(key: 'customersAdded', label: 'New Customers', isNumeric: true),
                  ReportColumnConfig(key: 'paymentsRecorded', label: 'Payments Taken', isNumeric: true),
                  ReportColumnConfig(key: 'inventoryMovements', label: 'Vault Movements', isNumeric: true),
                  ReportColumnConfig(key: 'avgProcessingTime', label: 'Avg Turnaround', isNumeric: true),
                ],
                rows: rows,
              );
            },
          ),
          const SizedBox(height: 24),

          // Unified Activity Feed
          const ActivityFeedWidget(),
        ],
      ),
    );
  }
}
