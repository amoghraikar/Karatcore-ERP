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

import '../../models/reports_model.dart';
import '../../providers/reports_providers.dart';
import '../../widgets/activity_feed_widget.dart';
import '../../widgets/attention_panel.dart';
import '../../widgets/report_date_filter.dart';
import '../../widgets/report_error_state.dart';

class ExecutiveOverviewPage extends ConsumerWidget {
  const ExecutiveOverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final execAsync = ref.watch(executiveMetricsProvider);
    final filter = ref.watch(reportDateFilterProvider);

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
                    Text('Executive Overview Dashboard', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text('Owner-level business intelligence & actionable performance metrics', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          const ReportDateFilter(),
          const SizedBox(height: 20),

          // Attention Required Action Panel
          const AttentionPanel(),
          const SizedBox(height: 24),

          // Executive Metric Cards Grid
          execAsync.when(
            loading: () => const KcSkeletonLoader(height: 220),
            error: (err, st) => ReportErrorState(error: err, onRetry: () { ref.invalidate(executiveMetricsProvider); ref.invalidate(attentionItemsProvider); }),
            data: (metrics) {
              final isComparison = filter.comparisonMode != ComparisonMode.none;

              return Column(
                children: [
                  GridView.count(
                    crossAxisCount: MediaQuery.of(context).size.width > 1100 ? 4 : 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    mainAxisExtent: 120,
                    children: [
                      KcMetricCard(
                        title: 'Total Revenue',
                        value: KcFormatters.inr(metrics.revenue),
                        trend: isComparison ? '+14.2% vs previous period' : 'Total Gross Income',
                        icon: Icons.trending_up_rounded,
                        onTap: () => context.go('/reports/profitability'),
                      ),
                      KcMetricCard(
                        title: 'Operating Expenses',
                        value: KcFormatters.inr(metrics.expenses),
                        trend: isComparison ? '-2.1% vs previous period' : 'Store Rent, Salaries & Overhead',
                        icon: Icons.trending_down_rounded,
                        onTap: () => context.go('/reports/profitability'),
                      ),
                      KcMetricCard(
                        title: 'Net Profit',
                        value: KcFormatters.inr(metrics.netProfit),
                        trend: isComparison ? '+18.5% vs previous period' : 'Net Business Profit',
                        icon: Icons.account_balance_wallet_rounded,
                        onTap: () => context.go('/reports/profitability'),
                      ),
                      KcMetricCard(
                        title: 'Active Gold Loans',
                        value: '${metrics.activeLoansCount} Loans',
                        trend: '₹${(metrics.loanOutstanding / 100000).toStringAsFixed(1)}L Outstanding',
                        icon: Icons.request_quote_rounded,
                        onTap: () => context.go('/reports/loans'),
                      ),
                      KcMetricCard(
                        title: 'Total Inventory Valuation',
                        value: KcFormatters.inr(metrics.inventoryValue),
                        trend: 'Pledged: ${KcFormatters.inr(metrics.pledgedInventoryValue)}',
                        icon: Icons.inventory_2_rounded,
                        onTap: () => context.go('/reports/inventory'),
                      ),
                      KcMetricCard(
                        title: 'Total Customer Count',
                        value: '${metrics.customerCount} Customers',
                        trend: 'Active Borrowers & Retail Buyers',
                        icon: Icons.people_rounded,
                        onTap: () => context.go('/reports/customers'),
                      ),
                      KcMetricCard(
                        title: 'Interest Income Earned',
                        value: KcFormatters.inr(metrics.interestIncome),
                        trend: 'Pledge Interest Yield',
                        icon: Icons.monetization_on_rounded,
                        onTap: () => context.go('/reports/payments'),
                      ),
                      KcMetricCard(
                        title: 'Vault Cash & Bank Liquid',
                        value: KcFormatters.inr(metrics.cashBalance + metrics.bankBalance),
                        trend: 'Cash: ₹8.5L • Bank: ₹60.5L',
                        icon: Icons.account_balance_rounded,
                        onTap: () => context.go('/accounting/bank-book'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Business Performance & Portfolio Charts
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: KcCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Monthly Loan Disbursement Trend', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 12),
                      KcChartWrapper.lineChart(
                        context: context,
                        data: const [
                          KcChartDataPoint(xLabel: 'Jan', value: 32),
                          KcChartDataPoint(xLabel: 'Feb', value: 45),
                          KcChartDataPoint(xLabel: 'Mar', value: 52),
                          KcChartDataPoint(xLabel: 'Apr', value: 48),
                          KcChartDataPoint(xLabel: 'May', value: 65),
                          KcChartDataPoint(xLabel: 'Jun', value: 72),
                          KcChartDataPoint(xLabel: 'Jul', value: 88),
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
                      Text('Inventory Distribution by Metal Type', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 12),
                      KcChartWrapper.donutChart(
                        context: context,
                        data: const [
                          KcDonutDataPoint(label: '22K Gold Ornaments', value: 65, color: Color(0xFFD97706)),
                          KcDonutDataPoint(label: '24K Gold Bars & Coins', value: 20, color: Color(0xFFEAB308)),
                          KcDonutDataPoint(label: 'Silver Articles & Coins', value: 15, color: Color(0xFF94A3B8)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Unified Business Activity Feed
          const ActivityFeedWidget(),
        ],
      ),
    );
  }
}
