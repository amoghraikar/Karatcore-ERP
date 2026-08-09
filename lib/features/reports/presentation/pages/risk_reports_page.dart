import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/cards/kc_metric_card.dart';
import '../../../../shared/widgets/feedback/kc_skeleton_loader.dart';

import '../../../loans/providers/loan_providers.dart';
import '../../providers/reports_providers.dart';
import '../../widgets/report_date_filter.dart';
import '../../widgets/report_table.dart';
import '../../widgets/report_error_state.dart';

class RiskReportsPage extends ConsumerWidget {
  const RiskReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final riskAnalyticsAsync = ref.watch(riskAnalyticsProvider);

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
                    Text('Risk & Exposure Dashboard', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text('High exposure borrowers, collateral LTV risk analysis & overdue portfolio risk tracking', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          const ReportDateFilter(),
          const SizedBox(height: 20),

          riskAnalyticsAsync.when(
            loading: () => const KcSkeletonLoader(height: 180),
            error: (err, st) => ReportErrorState(error: err, onRetry: () { ref.invalidate(riskAnalyticsProvider); ref.invalidate(loanListProvider); }),
            data: (data) {
              return Row(
                children: [
                  Expanded(
                    child: KcMetricCard(
                      title: 'High-Risk Loan Accounts',
                      value: '${data['highRiskLoansCount']} Loans',
                      trend: 'LTV > 75% or Overdue > 30d',
                      icon: Icons.warning_amber_rounded,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: KcMetricCard(
                      title: 'Total Overdue Risk Exposure',
                      value: KcFormatters.inr(data['totalExposureAmount']),
                      trend: '${data['overdueLoansCount']} Overdue Accounts',
                      icon: Icons.shield_rounded,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: KcMetricCard(
                      title: 'Unverified KYC Borrowers',
                      value: '${data['unverifiedKycCount']} Accounts',
                      trend: 'Pending Document Validation',
                      icon: Icons.no_accounts_rounded,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Customer Exposure Report Table
          Text('Customer Risk & Total Exposure Report Table', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: const Color(0xFFDC2626))),
          const SizedBox(height: 12),

          ref.watch(customerExposureProvider).when(
                loading: () => const KcSkeletonLoader(height: 300),
                error: (err, st) => ReportErrorState(error: err, onRetry: () => ref.invalidate(customerExposureProvider)),
                data: (exposureItems) {
                  final rows = exposureItems.map((e) {
                    return {
                      'customer': e.customerName,
                      'customerId': e.customerId,
                      'activeLoans': e.activeLoansCount.toString(),
                      'totalPrincipal': KcFormatters.inr(e.totalPrincipal),
                      'outstanding': KcFormatters.inr(e.totalOutstanding),
                      'interestDue': KcFormatters.inr(e.interestDue),
                      'collateralValue': KcFormatters.inr(e.collateralValue),
                      'ltv': '${e.ltvPercentage.toStringAsFixed(1)}%',
                      'riskStatus': e.riskStatus,
                      'kycStatus': e.kycStatus,
                    };
                  }).toList();

                  return ReportTable(
                    title: 'Customer Total Risk Exposure Report',
                    columns: const [
                      ReportColumnConfig(key: 'customer', label: 'Customer'),
                      ReportColumnConfig(key: 'activeLoans', label: 'Active Loans', isNumeric: true),
                      ReportColumnConfig(key: 'totalPrincipal', label: 'Total Principal (₹)', isNumeric: true),
                      ReportColumnConfig(key: 'outstanding', label: 'Outstanding (₹)', isNumeric: true),
                      ReportColumnConfig(key: 'interestDue', label: 'Interest Due (₹)', isNumeric: true),
                      ReportColumnConfig(key: 'collateralValue', label: 'Collateral (₹)', isNumeric: true),
                      ReportColumnConfig(key: 'ltv', label: 'LTV %', isNumeric: true),
                      ReportColumnConfig(key: 'riskStatus', label: 'Risk Rating'),
                      ReportColumnConfig(key: 'kycStatus', label: 'KYC Status'),
                    ],
                    rows: rows,
                    onRowTap: (row) => context.go('/customers/${row['customerId']}'),
                  );
                },
              ),
          const SizedBox(height: 24),

          // Collateral Report Table
          Text('Pledged Ornaments & Collateral Risk Report Table', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),

          ref.watch(collateralReportProvider).when(
                loading: () => const KcSkeletonLoader(height: 300),
                error: (err, st) => ReportErrorState(error: err, onRetry: () => ref.invalidate(collateralReportProvider)),
                data: (collateralItems) {
                  final rows = collateralItems.map((c) {
                    return {
                      'customer': c.customerName,
                      'loanId': c.loanId,
                      'ornamentId': c.ornamentId,
                      'metal': c.metalType,
                      'purity': c.purity,
                      'netWeight': '${c.netWeightGrams.toStringAsFixed(1)}g',
                      'collateralValue': KcFormatters.inr(c.collateralValue),
                      'pledgeDate': KcFormatters.date(c.pledgeDate),
                      'loanStatus': c.loanStatus,
                      'releaseStatus': c.releaseStatus,
                    };
                  }).toList();

                  return ReportTable(
                    title: 'Pledged Collateral Master Report',
                    columns: const [
                      ReportColumnConfig(key: 'customer', label: 'Customer'),
                      ReportColumnConfig(key: 'loanId', label: 'Loan ID'),
                      ReportColumnConfig(key: 'ornamentId', label: 'Ornament ID'),
                      ReportColumnConfig(key: 'metal', label: 'Metal'),
                      ReportColumnConfig(key: 'purity', label: 'Purity'),
                      ReportColumnConfig(key: 'netWeight', label: 'Net Weight', isNumeric: true),
                      ReportColumnConfig(key: 'collateralValue', label: 'Collateral Val (₹)', isNumeric: true),
                      ReportColumnConfig(key: 'pledgeDate', label: 'Pledge Date'),
                      ReportColumnConfig(key: 'loanStatus', label: 'Loan Status'),
                      ReportColumnConfig(key: 'releaseStatus', label: 'Vault Release Status'),
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
