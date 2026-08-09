import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/charts/kc_chart_wrapper.dart';
import '../../../../shared/widgets/feedback/kc_skeleton_loader.dart';

import '../../../kyc/models/kyc_model.dart';
import '../../../kyc/providers/kyc_providers.dart';
import '../../providers/reports_providers.dart';
import '../../widgets/report_date_filter.dart';
import '../../widgets/report_table.dart';
import '../../widgets/report_error_state.dart';

class KycReportsPage extends ConsumerWidget {
  const KycReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kycAnalyticsAsync = ref.watch(kycAnalyticsProvider);
    final kycQueueAsync = ref.watch(kycQueueProvider);
    final filterParam = GoRouterState.of(context).uri.queryParameters['filter'];

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
                    Text('KYC & Trust Layer Analytics', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text('Identity verification completion, review bottlenecks, risk distribution & rejections', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          const ReportDateFilter(),
          const SizedBox(height: 20),

          kycAnalyticsAsync.when(
            loading: () => const KcSkeletonLoader(height: 200),
            error: (err, st) => ReportErrorState(error: err, onRetry: () { ref.invalidate(kycAnalyticsProvider); ref.invalidate(kycQueueProvider); }),
            data: (data) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: KcCard(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const CircleAvatar(radius: 20, backgroundColor: Color(0xFFEFF6FF), child: Icon(Icons.timer_rounded, color: Color(0xFF2563EB), size: 20)),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Avg Review Turnaround', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                                  const Text('14.5 Mins', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: KcCard(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const CircleAvatar(radius: 20, backgroundColor: Color(0xFFECFDF5), child: Icon(Icons.verified_rounded, color: Color(0xFF059669), size: 20)),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Completion Rate', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                                  const Text('84.2%', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: KcCard(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('KYC Verification Breakdown', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                              const SizedBox(height: 12),
                              KcChartWrapper.donutChart(
                                context: context,
                                data: [
                                  KcDonutDataPoint(label: 'Verified (${data['verifiedCount']})', value: (data['verifiedCount'] as int).toDouble(), color: const Color(0xFF059669)),
                                  KcDonutDataPoint(label: 'Pending Review (${data['pendingCount']})', value: (data['pendingCount'] as int).toDouble(), color: const Color(0xFFD97706)),
                                  KcDonutDataPoint(label: 'Rejected (${data['rejectedCount']})', value: (data['rejectedCount'] as int).toDouble(), color: const Color(0xFFDC2626)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: KcCard(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('KYC Rejection Reasons Breakdown', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                              const SizedBox(height: 12),
                              KcChartWrapper.barChart(
                                context: context,
                                data: const [
                                  KcChartDataPoint(xLabel: 'Blurry Photo', value: 45),
                                  KcChartDataPoint(xLabel: 'Name Mismatch', value: 30),
                                  KcChartDataPoint(xLabel: 'Expired ID', value: 15),
                                  KcChartDataPoint(xLabel: 'Address Diff', value: 10),
                                ],
                                barColor: const Color(0xFFDC2626),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // KYC Queue Table
          Text('KYC Verification Queue Report Table', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),

          kycQueueAsync.when(
            loading: () => const KcSkeletonLoader(height: 350),
            error: (err, st) => ReportErrorState(error: err, onRetry: () => ref.invalidate(kycQueueProvider)),
            data: (records) {
              final visibleRecords = filterParam == 'pending'
                  ? records.where((k) => k.status == KycStatus.underReview || k.status == KycStatus.submitted).toList()
                  : records;

              final rows = visibleRecords.map((k) {
                return {
                  'recordId': k.id,
                  'customer': k.customerName,
                  'customerId': k.customerId,
                  'status': k.status.name.toUpperCase(),
                  'idType': k.method.label,
                  'submittedDate': KcFormatters.dateTime(k.submittedAt),
                };
              }).toList();

              return ReportTable(
                title: 'KYC Verification Queue Report',
                columns: const [
                  ReportColumnConfig(key: 'recordId', label: 'Record ID'),
                  ReportColumnConfig(key: 'customerId', label: 'Customer ID'),
                  ReportColumnConfig(key: 'customer', label: 'Customer Name'),
                  ReportColumnConfig(key: 'idType', label: 'ID Type'),
                  ReportColumnConfig(key: 'status', label: 'Verification Status'),
                  ReportColumnConfig(key: 'submittedDate', label: 'Submitted Date'),
                ],
                rows: rows,
                onRowTap: (row) => context.go('/kyc/${row['customerId']}'),
              );
            },
          ),
        ],
      ),
    );
  }
}
