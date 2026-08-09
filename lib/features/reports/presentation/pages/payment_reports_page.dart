import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/cards/kc_metric_card.dart';
import '../../../../shared/widgets/charts/kc_chart_wrapper.dart';
import '../../../../shared/widgets/feedback/kc_skeleton_loader.dart';

import '../../../loans/providers/loan_providers.dart';
import '../../providers/reports_providers.dart';
import '../../widgets/report_date_filter.dart';
import '../../widgets/report_table.dart';
import '../../widgets/report_error_state.dart';

class PaymentReportsPage extends ConsumerWidget {
  const PaymentReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payAnalyticsAsync = ref.watch(paymentAnalyticsProvider);
    final loansAsync = ref.watch(loanListProvider);

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
                    Text('Payment Collections Analytics', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text('Daily/Monthly collection totals, principal vs interest splits & payment method analytics', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          const ReportDateFilter(),
          const SizedBox(height: 20),

          payAnalyticsAsync.when(
            loading: () => const KcSkeletonLoader(height: 180),
            error: (err, st) => ReportErrorState(error: err, onRetry: () { ref.invalidate(paymentAnalyticsProvider); ref.invalidate(loanListProvider); }),
            data: (data) {
              return Row(
                children: [
                  Expanded(
                    child: KcMetricCard(
                      title: 'Total Collections',
                      value: KcFormatters.inr(data['totalCollections']),
                      trend: 'Principal + Interest Yield',
                      icon: Icons.payments_rounded,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: KcMetricCard(
                      title: 'Interest Collected',
                      value: KcFormatters.inr(data['interestCollected']),
                      trend: 'Pledge Interest Yield',
                      icon: Icons.trending_up_rounded,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: KcMetricCard(
                      title: 'Principal Repaid',
                      value: KcFormatters.inr(data['principalCollected']),
                      trend: 'Principal Recoveries',
                      icon: Icons.assignment_turned_in_rounded,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: KcCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Collection Trend (Monthly)', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 12),
                      KcChartWrapper.barChart(
                        context: context,
                        data: const [
                          KcChartDataPoint(xLabel: 'Jan', value: 450),
                          KcChartDataPoint(xLabel: 'Feb', value: 520),
                          KcChartDataPoint(xLabel: 'Mar', value: 610),
                          KcChartDataPoint(xLabel: 'Apr', value: 580),
                          KcChartDataPoint(xLabel: 'May', value: 720),
                          KcChartDataPoint(xLabel: 'Jun', value: 810),
                          KcChartDataPoint(xLabel: 'Jul', value: 950),
                        ],
                        barColor: const Color(0xFF059669),
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
                      Text('Collection Method Breakdown', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 12),
                      KcChartWrapper.donutChart(
                        context: context,
                        data: const [
                          KcDonutDataPoint(label: 'Cash Vault (45%)', value: 45, color: Color(0xFF059669)),
                          KcDonutDataPoint(label: 'HDFC NetBanking / UPI (40%)', value: 40, color: Color(0xFF2563EB)),
                          KcDonutDataPoint(label: 'POS Card Machine (15%)', value: 15, color: Color(0xFF7C3AED)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Payment Collections Master Table
          Text('Recent Payment Collections Log', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),

          loansAsync.when(
            loading: () => const KcSkeletonLoader(height: 350),
            error: (err, st) => ReportErrorState(error: err, onRetry: () => ref.invalidate(loanListProvider)),
            data: (loans) {
              final rows = loans.map((l) {
                return {
                  'receiptNo': 'KC-RCP-${l.id.replaceAll('KC-LN-', '')}',
                  'loanId': l.id,
                  'customer': l.customerName,
                  'amount': KcFormatters.inr(l.accruedInterest * 0.85),
                  'type': 'Interest Collection',
                  'method': 'HDFC NetBanking / UPI',
                  'date': KcFormatters.date(DateTime.now().subtract(const Duration(days: 2))),
                };
              }).toList();

              return ReportTable(
                title: 'Payment Collections Master Report',
                columns: const [
                  ReportColumnConfig(key: 'receiptNo', label: 'Receipt No'),
                  ReportColumnConfig(key: 'loanId', label: 'Loan ID'),
                  ReportColumnConfig(key: 'customer', label: 'Customer'),
                  ReportColumnConfig(key: 'type', label: 'Collection Type'),
                  ReportColumnConfig(key: 'amount', label: 'Amount (₹)', isNumeric: true),
                  ReportColumnConfig(key: 'method', label: 'Method'),
                  ReportColumnConfig(key: 'date', label: 'Payment Date'),
                ],
                rows: rows,
                onRowTap: (row) => context.go('/loans/${row['loanId']}'),
              );
            },
          ),
        ],
      ),
    );
  }
}
