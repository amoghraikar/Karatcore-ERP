import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/cards/kc_metric_card.dart';
import '../../../../shared/widgets/feedback/kc_skeleton_loader.dart';

import '../../models/reports_model.dart';
import '../../providers/reports_providers.dart';
import '../../widgets/attention_panel.dart';
import '../../widgets/report_date_filter.dart';
import '../../widgets/report_error_state.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final execAsync = ref.watch(executiveMetricsProvider);
    final savedViewsAsync = ref.watch(savedReportViewsProvider);
    final filter = ref.watch(reportDateFilterProvider);
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: EdgeInsets.all(context.pageGutter),
      children: [
        // Header
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reports & Business Intelligence Center',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Executive dashboards, operational analytics, risk indicators & exportable financial statements',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Global Date Filter System
        const ReportDateFilter(),
        const SizedBox(height: 20),

        // Attention Required Panel
        const AttentionPanel(),
        const SizedBox(height: 24),

        // 12 Premium KPI Metric Cards with Interactive Drill-Downs
        Text('Executive KPI Summary Metrics (Interactive Drill-Down)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),

        execAsync.when(
          loading: () => const KcSkeletonLoader(height: 300),
          error: (err, st) => ReportErrorState(error: err, onRetry: () { ref.invalidate(executiveMetricsProvider); ref.invalidate(savedReportViewsProvider); }),
          data: (metrics) {
            final isComparison = filter.comparisonMode != ComparisonMode.none;

            return GridView.count(
              crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 4 : (MediaQuery.of(context).size.width > 768 ? 3 : 2),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              mainAxisExtent: 120,
              children: [
                KcMetricCard(
                  title: 'Revenue',
                  value: KcFormatters.inr(metrics.revenue),
                  trend: isComparison ? '+14.2% vs prev' : 'Gross Income',
                  icon: Icons.trending_up_rounded,
                  onTap: () => context.go(AppRoutes.reportsProfitability),
                ),
                KcMetricCard(
                  title: 'Expenses',
                  value: KcFormatters.inr(metrics.expenses),
                  trend: isComparison ? '-2.1% vs prev' : 'Store Rent & Wages',
                  icon: Icons.trending_down_rounded,
                  onTap: () => context.go(AppRoutes.reportsProfitability),
                ),
                KcMetricCard(
                  title: 'Net Profit',
                  value: KcFormatters.inr(metrics.netProfit),
                  trend: isComparison ? '+18.5% vs prev' : 'Net Business Yield',
                  icon: Icons.account_balance_wallet_rounded,
                  onTap: () => context.go(AppRoutes.reportsProfitability),
                ),
                KcMetricCard(
                  title: 'Active Loans',
                  value: '${metrics.activeLoansCount} Loans',
                  trend: 'Pledge Portfolio',
                  icon: Icons.request_quote_rounded,
                  onTap: () => context.go(AppRoutes.reportsLoans),
                ),
                KcMetricCard(
                  title: 'Loan Outstanding',
                  value: KcFormatters.inr(metrics.loanOutstanding),
                  trend: 'Active Principal Balance',
                  icon: Icons.account_balance_rounded,
                  onTap: () => context.go(AppRoutes.reportsLoans),
                ),
                KcMetricCard(
                  title: 'Interest Income',
                  value: KcFormatters.inr(metrics.interestIncome),
                  trend: 'Accumulated Yield',
                  icon: Icons.monetization_on_rounded,
                  onTap: () => context.go(AppRoutes.reportsPayments),
                ),
                KcMetricCard(
                  title: 'Inventory Value',
                  value: KcFormatters.inr(metrics.inventoryValue),
                  trend: 'Total Vault Stock',
                  icon: Icons.inventory_2_rounded,
                  onTap: () => context.go(AppRoutes.reportsInventory),
                ),
                KcMetricCard(
                  title: 'Pledged Inventory',
                  value: KcFormatters.inr(metrics.pledgedInventoryValue),
                  trend: 'Collateral Stocks',
                  icon: Icons.lock_rounded,
                  onTap: () => context.go(AppRoutes.reportsInventory),
                ),
                KcMetricCard(
                  title: 'Customer Count',
                  value: '${metrics.customerCount} Users',
                  trend: 'Active Profiles',
                  icon: Icons.people_rounded,
                  onTap: () => context.go(AppRoutes.reportsCustomers),
                ),
                KcMetricCard(
                  title: 'Overdue Loans',
                  value: '${metrics.overdueLoansCount} Loans',
                  trend: 'Maturity Past Due',
                  icon: Icons.warning_rounded,
                  onTap: () => context.go(AppRoutes.reportsLoans),
                ),
                KcMetricCard(
                  title: 'Cash Balance',
                  value: KcFormatters.inr(metrics.cashBalance),
                  trend: 'Vault Physical Cash',
                  icon: Icons.payments_rounded,
                  onTap: () => context.go('/accounting/cash-book'),
                ),
                KcMetricCard(
                  title: 'Bank Balance',
                  value: KcFormatters.inr(metrics.bankBalance),
                  trend: 'HDFC & SBI Accounts',
                  icon: Icons.account_balance_rounded,
                  onTap: () => context.go('/accounting/bank-book'),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 28),

        // Saved Report Views & Favorites Section
        Text('Saved & Pinned Report Views', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),

        savedViewsAsync.when(
          loading: () => const KcSkeletonLoader(height: 80),
          error: (err, st) => ReportErrorState(error: err, onRetry: () => ref.invalidate(savedReportViewsProvider)),
          data: (views) {
            return SizedBox(
              height: 70,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: views.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final view = views[index];

                  return InkWell(
                    onTap: () => context.go(_getRouteForCategory(view.category)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: scheme.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(view.category.icon, size: 20, color: scheme.primary),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(view.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                              Text(view.filterPreset.label, style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
                            ],
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () async {
                              await ref.read(reportsRepositoryProvider).toggleFavorite(view.id);
                              ref.invalidate(savedReportViewsProvider);
                            },
                            child: Icon(
                              view.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                              size: 18,
                              color: view.isFavorite ? Colors.amber : scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
        const SizedBox(height: 28),

        // Recent Reports Section
        Text('Recent Reports & Favorites', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),

        savedViewsAsync.when(
          loading: () => const KcSkeletonLoader(height: 40),
          error: (err, st) => const SizedBox.shrink(),
          data: (views) {
            final recent = [...views]..sort((a, b) => b.lastViewedAt.compareTo(a.lastViewedAt));
            final pinned = views.where((v) => v.isPinned).toList();

            return Column(
              children: [
                for (final view in recent.take(3))
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(view.isFavorite ? Icons.star_rounded : Icons.history_rounded,
                        size: 18,
                        color: view.isFavorite ? Colors.amber : scheme.onSurfaceVariant),
                    title: Text(view.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    subtitle: Text('Last viewed ${KcFormatters.relativeTime(view.lastViewedAt)} • ${view.filterPreset.label}',
                        style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
                    trailing: view.isPinned ? const Icon(Icons.push_pin_rounded, size: 16) : null,
                    onTap: () => context.go(_getRouteForCategory(view.category)),
                  ),
                if (pinned.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('${pinned.length} pinned • ${views.where((v) => v.isFavorite).length} favorite view(s)',
                          style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 28),

        // 11 Dedicated Report Modules Directory
        Text('Dedicated Report Modules Directory', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),

        GridView.count(
          crossAxisCount: MediaQuery.of(context).size.width > 1000 ? 3 : (MediaQuery.of(context).size.width > 600 ? 2 : 1),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 2.4,
          children: [
            _buildReportCategoryCard(context, ReportCategory.executive, 'Owner-focused business performance & risk panel', AppRoutes.reportsExecutive, const Color(0xFF2563EB)),
            _buildReportCategoryCard(context, ReportCategory.customers, 'Growth, KYC status, pledge participation & segments', AppRoutes.reportsCustomers, const Color(0xFF059669)),
            _buildReportCategoryCard(context, ReportCategory.kyc, 'DigiLocker completion, review bottlenecks & rejection reasons', AppRoutes.reportsKyc, const Color(0xFF7C3AED)),
            _buildReportCategoryCard(context, ReportCategory.inventory, 'Gold/Silver weight breakdown, purity distribution & stock aging', AppRoutes.reportsInventory, const Color(0xFFD97706)),
            _buildReportCategoryCard(context, ReportCategory.loans, 'Disbursement trends, active/closed loans & dedicated overdue report', AppRoutes.reportsLoans, const Color(0xFFDC2626)),
            _buildReportCategoryCard(context, ReportCategory.payments, 'Daily collections, principal vs interest & payment methods', AppRoutes.reportsPayments, const Color(0xFF10B981)),
            _buildReportCategoryCard(context, ReportCategory.accounting, 'Direct links to Trial Balance, P&L, Balance Sheet & Ledgers', AppRoutes.reportsAccounting, const Color(0xFF0284C7)),
            _buildReportCategoryCard(context, ReportCategory.profitability, 'Revenue streams, operating expense breakdown & net profit margin', AppRoutes.reportsProfitability, const Color(0xFFEC4899)),
            _buildReportCategoryCard(context, ReportCategory.risk, 'High-risk loans, customer exposure report & collateral risk', AppRoutes.reportsRisk, const Color(0xFFF59E0B)),
            _buildReportCategoryCard(context, ReportCategory.operations, 'Daily processing velocity, staff action metrics & activity feed', AppRoutes.reportsOperations, const Color(0xFF6366F1)),
            _buildReportCategoryCard(context, ReportCategory.audit, 'Unified search across Customer, KYC, Loan & Accounting audit logs', AppRoutes.reportsAudit, const Color(0xFF6B7280)),
          ],
        ),
      ],
    );
  }

  Widget _buildReportCategoryCard(BuildContext context, ReportCategory cat, String subtitle, String route, Color accentColor) {
    return InkWell(
      onTap: () => context.go(route),
      borderRadius: BorderRadius.circular(12),
      child: KcCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: accentColor.withValues(alpha: 0.12),
              child: Icon(cat.icon, color: accentColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(cat.label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14),
          ],
        ),
      ),
    );
  }

  String _getRouteForCategory(ReportCategory cat) {
    switch (cat) {
      case ReportCategory.executive:
        return AppRoutes.reportsExecutive;
      case ReportCategory.customers:
        return AppRoutes.reportsCustomers;
      case ReportCategory.kyc:
        return AppRoutes.reportsKyc;
      case ReportCategory.inventory:
        return AppRoutes.reportsInventory;
      case ReportCategory.loans:
        return AppRoutes.reportsLoans;
      case ReportCategory.payments:
        return AppRoutes.reportsPayments;
      case ReportCategory.accounting:
        return AppRoutes.reportsAccounting;
      case ReportCategory.profitability:
        return AppRoutes.reportsProfitability;
      case ReportCategory.risk:
        return AppRoutes.reportsRisk;
      case ReportCategory.operations:
        return AppRoutes.reportsOperations;
      case ReportCategory.audit:
        return AppRoutes.reportsAudit;
    }
  }
}
