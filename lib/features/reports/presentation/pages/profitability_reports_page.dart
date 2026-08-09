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

import '../../providers/reports_providers.dart';
import '../../widgets/report_date_filter.dart';
import '../../widgets/report_error_state.dart';
import '../../widgets/report_table.dart';

class ProfitabilityReportsPage extends ConsumerWidget {
  const ProfitabilityReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profAsync = ref.watch(profitabilityAnalyticsProvider);

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
                    Text('Profitability & Expense Analytics', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text('Revenue streams, operating expense category breakdowns, net profit & profit margins', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          const ReportDateFilter(),
          const SizedBox(height: 20),

          profAsync.when(
            loading: () => const KcSkeletonLoader(height: 180),
            error: (err, st) => ReportErrorState(error: err, onRetry: () => ref.invalidate(profitabilityAnalyticsProvider)),
            data: (data) {
              return Row(
                children: [
                  Expanded(
                    child: KcMetricCard(
                      title: 'Total Gross Revenue',
                      value: KcFormatters.inr(data['totalRevenue']),
                      trend: 'Pledge Interest + Sales',
                      icon: Icons.trending_up_rounded,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: KcMetricCard(
                      title: 'Total Operating Expenses',
                      value: KcFormatters.inr(data['totalExpenses']),
                      trend: 'Store Rent & Salaries',
                      icon: Icons.trending_down_rounded,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: KcMetricCard(
                      title: 'Net Profit Margin',
                      value: '${(data['profitMarginPercentage'] as double).toStringAsFixed(1)}%',
                      trend: 'Net Profit: ${KcFormatters.inr(data['netProfit'])}',
                      icon: Icons.pie_chart_rounded,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Expense Breakdown Chart
          Row(
            children: [
              Expanded(
                child: KcCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Operating Expense Categories (Monthly)', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 12),
                      KcChartWrapper.barChart(
                        context: context,
                        data: const [
                          KcChartDataPoint(xLabel: 'Rent', value: 450),
                          KcChartDataPoint(xLabel: 'Salaries', value: 920),
                          KcChartDataPoint(xLabel: 'Utilities', value: 85),
                          KcChartDataPoint(xLabel: 'Marketing', value: 120),
                          KcChartDataPoint(xLabel: 'Insurance', value: 180),
                          KcChartDataPoint(xLabel: 'Maintenance', value: 64),
                        ],
                        barColor: const Color(0xFFDC2626),
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
                      Text('Revenue Source Composition', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 12),
                      KcChartWrapper.donutChart(
                        context: context,
                        data: const [
                          KcDonutDataPoint(label: 'Retail Jewellery Sales', value: 70, color: Color(0xFF059669)),
                          KcDonutDataPoint(label: 'Pledge Interest Yield', value: 25, color: Color(0xFFD97706)),
                          KcDonutDataPoint(label: 'Making & Other Charges', value: 5, color: Color(0xFF2563EB)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Expense Categories Master Table
          Text('Operating Expense Categories Analysis Report Table', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),

          const ReportTable(
            title: 'Operating Expense Categories Analysis Report',
            columns: [
              ReportColumnConfig(key: 'category', label: 'Expense Category'),
              ReportColumnConfig(key: 'monthlyAmount', label: 'Monthly Expense (₹)', isNumeric: true),
              ReportColumnConfig(key: 'ytdAmount', label: 'YTD Expense (₹)', isNumeric: true),
              ReportColumnConfig(key: 'paymentMethod', label: 'Primary Payment Method'),
              ReportColumnConfig(key: 'pctOfTotal', label: '% of Operating Expense', isNumeric: true),
            ],
            rows: [
              {'category': 'Rent', 'monthlyAmount': '₹4,50,000', 'ytdAmount': '₹18,00,000', 'paymentMethod': 'Bank Transfer (HDFC)', 'pctOfTotal': '23.2%'},
              {'category': 'Salaries', 'monthlyAmount': '₹9,20,000', 'ytdAmount': '₹36,80,000', 'paymentMethod': 'Bank Transfer (SBI)', 'pctOfTotal': '47.4%'},
              {'category': 'Utilities', 'monthlyAmount': '₹85,000', 'ytdAmount': '₹3,40,000', 'paymentMethod': 'Bank Auto-Debit', 'pctOfTotal': '4.4%'},
              {'category': 'Marketing', 'monthlyAmount': '₹1,20,000', 'ytdAmount': '₹4,80,000', 'paymentMethod': 'POS Card', 'pctOfTotal': '6.2%'},
              {'category': 'Transportation', 'monthlyAmount': '₹42,000', 'ytdAmount': '₹1,68,000', 'paymentMethod': 'Cash Vault', 'pctOfTotal': '2.2%'},
              {'category': 'Maintenance', 'monthlyAmount': '₹64,000', 'ytdAmount': '₹2,56,000', 'paymentMethod': 'Bank Transfer (HDFC)', 'pctOfTotal': '3.3%'},
              {'category': 'Bank Charges', 'monthlyAmount': '₹28,000', 'ytdAmount': '₹1,12,000', 'paymentMethod': 'System Direct Debit', 'pctOfTotal': '1.4%'},
              {'category': 'Other', 'monthlyAmount': '₹230,000', 'ytdAmount': '₹9,20,000', 'paymentMethod': 'Cash & UPI', 'pctOfTotal': '11.9%'},
            ],
          ),
        ],
      ),
    );
  }
}
