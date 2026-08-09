import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/charts/kc_chart_wrapper.dart';
import '../../../../shared/widgets/feedback/kc_skeleton_loader.dart';

import '../../../customers/providers/customer_providers.dart';
import '../../providers/reports_providers.dart';
import '../../widgets/report_date_filter.dart';
import '../../widgets/report_table.dart';
import '../../widgets/report_error_state.dart';

class CustomerReportsPage extends ConsumerWidget {
  const CustomerReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerAnalyticsAsync = ref.watch(customerAnalyticsProvider);
    final customersAsync = ref.watch(customerListProvider);

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
                    Text('Customer Analytics & Segmentation Reports', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text('Customer growth, KYC completion rates, pledge participation & payment behavior', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          const ReportDateFilter(),
          const SizedBox(height: 20),

          customerAnalyticsAsync.when(
            loading: () => const KcSkeletonLoader(height: 200),
            error: (err, st) => ReportErrorState(error: err, onRetry: () { ref.invalidate(customerAnalyticsProvider); ref.invalidate(customerListProvider); }),
            data: (data) {
              final segments = data['segments'] as List;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Customer Segmentation Categories', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 110,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: segments.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final seg = segments[index];

                        return KcCard(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(radius: 6, backgroundColor: seg.color),
                                  const SizedBox(width: 6),
                                  Text(seg.segmentName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('${seg.count} Customers', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                              const SizedBox(height: 2),
                              Text(seg.description, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Customer Growth & Distribution Charts
          Row(
            children: [
              Expanded(
                child: KcCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Customer Growth Trend (2026)', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 12),
                      KcChartWrapper.barChart(
                        context: context,
                        data: const [
                          KcChartDataPoint(xLabel: 'Jan', value: 12),
                          KcChartDataPoint(xLabel: 'Feb', value: 18),
                          KcChartDataPoint(xLabel: 'Mar', value: 24),
                          KcChartDataPoint(xLabel: 'Apr', value: 22),
                          KcChartDataPoint(xLabel: 'May', value: 31),
                          KcChartDataPoint(xLabel: 'Jun', value: 38),
                          KcChartDataPoint(xLabel: 'Jul', value: 45),
                        ],
                        barColor: const Color(0xFF2563EB),
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
                      Text('Customer KYC Verification Status', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 12),
                      KcChartWrapper.donutChart(
                        context: context,
                        data: const [
                          KcDonutDataPoint(label: 'Verified', value: 72, color: Color(0xFF059669)),
                          KcDonutDataPoint(label: 'Pending Review', value: 18, color: Color(0xFFD97706)),
                          KcDonutDataPoint(label: 'Rejected', value: 10, color: Color(0xFFDC2626)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Customer Report Table
          Text('Customer Master Report Table', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),

          customersAsync.when(
            loading: () => const KcSkeletonLoader(height: 350),
            error: (err, st) => ReportErrorState(error: err, onRetry: () => ref.invalidate(customerListProvider)),
            data: (customers) {
              final rows = customers.map((c) {
                return {
                  'customer': c.fullName,
                  'customerId': c.id,
                  'kycStatus': c.kycStatus.name.toUpperCase(),
                  'activeLoans': '1',
                  'outstanding': KcFormatters.inr(185000),
                  'totalPaid': KcFormatters.inr(45000),
                  'interestPaid': KcFormatters.inr(12500),
                  'ornamentCount': '3',
                  'lastActivity': KcFormatters.relativeTime(c.createdAt),
                  'customerSince': KcFormatters.date(c.createdAt),
                };
              }).toList();

              return ReportTable(
                title: 'Customer Master Analytics Report',
                columns: const [
                  ReportColumnConfig(key: 'customer', label: 'Customer'),
                  ReportColumnConfig(key: 'customerId', label: 'Customer ID'),
                  ReportColumnConfig(key: 'kycStatus', label: 'KYC Status'),
                  ReportColumnConfig(key: 'activeLoans', label: 'Active Loans', isNumeric: true),
                  ReportColumnConfig(key: 'outstanding', label: 'Outstanding (₹)', isNumeric: true),
                  ReportColumnConfig(key: 'totalPaid', label: 'Total Paid (₹)', isNumeric: true),
                  ReportColumnConfig(key: 'interestPaid', label: 'Interest Paid (₹)', isNumeric: true),
                  ReportColumnConfig(key: 'ornamentCount', label: 'Ornament Count', isNumeric: true),
                  ReportColumnConfig(key: 'lastActivity', label: 'Last Activity'),
                  ReportColumnConfig(key: 'customerSince', label: 'Customer Since'),
                ],
                rows: rows,
                onRowTap: (row) {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                    builder: (ctx) => Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Customer Actions — ${row['customer']}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                          const SizedBox(height: 14),
                          ListTile(
                            leading: const Icon(Icons.person_rounded, color: Color(0xFF2563EB)),
                            title: const Text('View Customer Profile'),
                            onTap: () {
                              Navigator.pop(ctx);
                              context.go('/customers/${row['customerId']}');
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.account_balance_rounded, color: Color(0xFFD97706)),
                            title: const Text('View Customer Gold Loans'),
                            onTap: () {
                              Navigator.pop(ctx);
                              context.go(AppRoutes.loans);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.receipt_long_rounded, color: Color(0xFF059669)),
                            title: const Text('View Financial Activity & Ledgers'),
                            onTap: () {
                              Navigator.pop(ctx);
                              context.go(AppRoutes.accounting);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
