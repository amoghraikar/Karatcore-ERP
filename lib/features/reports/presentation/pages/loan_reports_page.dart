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

import '../../../loans/models/loan_model.dart';
import '../../../loans/providers/loan_providers.dart';
import '../../providers/reports_providers.dart';
import '../../widgets/report_date_filter.dart';
import '../../widgets/report_table.dart';
import '../../widgets/report_error_state.dart';

class LoanReportsPage extends ConsumerWidget {
  const LoanReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loanAnalyticsAsync = ref.watch(loanAnalyticsProvider);
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
                    Text('Gold & Silver Loan Portfolio Analytics', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text('Active, overdue & closed loan portfolio analysis, LTV distribution & repayment trends', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          const ReportDateFilter(),
          const SizedBox(height: 20),

          loanAnalyticsAsync.when(
            loading: () => const KcSkeletonLoader(height: 180),
            error: (err, st) => ReportErrorState(error: err, onRetry: () { ref.invalidate(loanAnalyticsProvider); ref.invalidate(loanListProvider); }),
            data: (data) {
              return Row(
                children: [
                  Expanded(
                    child: KcMetricCard(
                      title: 'Total Disbursed Principal',
                      value: KcFormatters.inr(data['totalDisbursed']),
                      trend: '${data['totalLoansCount']} Total Loans',
                      icon: Icons.payments_rounded,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: KcMetricCard(
                      title: 'Total Outstanding Balance',
                      value: KcFormatters.inr(data['totalOutstanding']),
                      trend: '${data['activeCount']} Active Loans',
                      icon: Icons.account_balance_wallet_rounded,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: KcMetricCard(
                      title: 'Interest Yield Earned',
                      value: KcFormatters.inr(data['totalInterestEarned']),
                      trend: 'Pledge Yield Income',
                      icon: Icons.trending_up_rounded,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Loan Portfolio Status Charts
          Row(
            children: [
              Expanded(
                child: KcCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Monthly Loan Disbursement vs Repayment (₹)', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 12),
                      KcChartWrapper.lineChart(
                        context: context,
                        data: const [
                          KcChartDataPoint(xLabel: 'Jan', value: 12.5),
                          KcChartDataPoint(xLabel: 'Feb', value: 18.2),
                          KcChartDataPoint(xLabel: 'Mar', value: 24.0),
                          KcChartDataPoint(xLabel: 'Apr', value: 22.8),
                          KcChartDataPoint(xLabel: 'May', value: 31.5),
                          KcChartDataPoint(xLabel: 'Jun', value: 38.0),
                          KcChartDataPoint(xLabel: 'Jul', value: 42.5),
                        ],
                        lineColor: const Color(0xFFD97706),
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
                      Text('Loan Portfolio Status Breakdown', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 12),
                      KcChartWrapper.donutChart(
                        context: context,
                        data: const [
                          KcDonutDataPoint(label: 'Active (Healthy)', value: 60, color: Color(0xFF059669)),
                          KcDonutDataPoint(label: 'Due Soon', value: 15, color: Color(0xFFD97706)),
                          KcDonutDataPoint(label: 'Overdue', value: 10, color: Color(0xFFDC2626)),
                          KcDonutDataPoint(label: 'Closed / Released', value: 15, color: Color(0xFF2563EB)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Dedicated Overdue Loans Dashboard Section
          Text('Overdue Gold Loans Report Table', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: const Color(0xFFDC2626))),
          const SizedBox(height: 12),

          loansAsync.when(
            loading: () => const KcSkeletonLoader(height: 350),
            error: (err, st) => ReportErrorState(error: err, onRetry: () => ref.invalidate(loanListProvider)),
            data: (loans) {
              final overdueLoans = loans.where((l) => l.status == LoanStatus.overdue || l.status == LoanStatus.dueSoon).toList();

              final rows = overdueLoans.map((l) {
                final daysOverdue = DateTime.now().difference(l.maturityDate).inDays;
                final daysOverdueText = daysOverdue > 0 ? '$daysOverdue Days' : 'Due Today';

                return {
                  'loanId': l.id,
                  'customer': l.customerName,
                  'outstanding': KcFormatters.inr(l.totalOutstanding),
                  'interestDue': KcFormatters.inr(l.accruedInterest),
                  'dueDate': KcFormatters.date(l.maturityDate),
                  'daysOverdue': daysOverdueText,
                  'risk': l.riskStatus.name.toUpperCase(),
                  'lastPayment': '12 Days Ago',
                  'nextAction': 'Send Notice / Record Payment',
                };
              }).toList();

              return ReportTable(
                title: 'Overdue Gold Loans Portfolio Report',
                columns: const [
                  ReportColumnConfig(key: 'loanId', label: 'Loan ID'),
                  ReportColumnConfig(key: 'customer', label: 'Customer'),
                  ReportColumnConfig(key: 'outstanding', label: 'Outstanding (₹)', isNumeric: true),
                  ReportColumnConfig(key: 'interestDue', label: 'Interest Due (₹)', isNumeric: true),
                  ReportColumnConfig(key: 'dueDate', label: 'Due Date'),
                  ReportColumnConfig(key: 'daysOverdue', label: 'Days Overdue', isNumeric: true),
                  ReportColumnConfig(key: 'risk', label: 'Risk'),
                  ReportColumnConfig(key: 'lastPayment', label: 'Last Payment'),
                  ReportColumnConfig(key: 'nextAction', label: 'Next Action'),
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
                          Text('Loan Actions — ${row['loanId']} (${row['customer']})', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                          const SizedBox(height: 14),
                          ListTile(
                            leading: const Icon(Icons.visibility_rounded, color: Color(0xFF2563EB)),
                            title: const Text('View Loan Details'),
                            onTap: () {
                              Navigator.pop(ctx);
                              context.go('/loans/${row['loanId']}');
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.payments_rounded, color: Color(0xFF059669)),
                            title: const Text('Record Repayment / Interest'),
                            onTap: () {
                              Navigator.pop(ctx);
                              context.go('/loans/${row['loanId']}/payments');
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.rate_review_rounded, color: Color(0xFFD97706)),
                            title: const Text('Review Risk & LTV Status'),
                            onTap: () {
                              Navigator.pop(ctx);
                              context.go('/loans/${row['loanId']}');
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.autorenew_rounded, color: Color(0xFF7C3AED)),
                            title: const Text('Renew Loan Contract'),
                            onTap: () {
                              Navigator.pop(ctx);
                              context.go('/loans/${row['loanId']}/renew');
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
