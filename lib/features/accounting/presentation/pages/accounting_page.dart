import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/buttons/kc_outlined_button.dart';
import '../../../../shared/widgets/buttons/kc_primary_button.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/cards/kc_metric_card.dart';
import '../../../../shared/widgets/feedback/kc_skeleton_loader.dart';

import '../../providers/accounting_providers.dart';
import '../../widgets/accounting_period_selector.dart';

class AccountingPage extends ConsumerWidget {
  const AccountingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final metricsAsync = ref.watch(accountingDashboardMetricsProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(accountingDashboardMetricsProvider);
        },
        child: ListView(
          padding: EdgeInsets.all(context.pageGutter),
          children: [
            // Page Header & Accounting Period Selector
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Accounting & Financial Bookkeeping',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Internal financial source of truth: Chart of accounts, double-entry journals, cash/bank books, income, expenses, receivables, payables, and trial balance.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                const AccountingPeriodSelector(),
                const SizedBox(width: 12),
                KcOutlinedButton(
                  label: 'Accounting Reports',
                  icon: Icons.bar_chart_rounded,
                  onPressed: () => context.go(AppRoutes.reportsAccounting),
                ),
                const SizedBox(width: 12),
                KcPrimaryButton(
                  label: 'New Journal Entry',
                  icon: Icons.edit_note_rounded,
                  onPressed: () => context.go(AppRoutes.accountingJournalCreate),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Top 10 Financial KPI Metric Cards
            metricsAsync.when(
              loading: () => const SizedBox(height: 120, child: KcSkeletonLoader()),
              error: (err, st) => Text('Error: $err'),
              data: (m) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: KcMetricCard(
                            title: 'Cash Vault Balance',
                            value: KcFormatters.inr(m.cashBalance),
                            trend: 'Vault Physical Funds',
                            icon: Icons.payments_rounded,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: KcMetricCard(
                            title: 'Bank Accounts Total',
                            value: KcFormatters.inr(m.bankBalance),
                            trend: 'HDFC + SBI Accounts',
                            icon: Icons.account_balance_rounded,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: KcMetricCard(
                            title: 'Total Revenue Income',
                            value: KcFormatters.inr(m.totalIncome),
                            trend: 'Interest + Sales',
                            icon: Icons.trending_up_rounded,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: KcMetricCard(
                            title: 'Operating Expenses',
                            value: KcFormatters.inr(m.totalExpenses),
                            trend: 'Rent, Salaries, Utilities',
                            icon: Icons.trending_down_rounded,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: KcMetricCard(
                            title: 'Net Profit / Loss',
                            value: KcFormatters.inr(m.netProfit),
                            trend: 'Income - Expenses',
                            icon: Icons.savings_rounded,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: KcMetricCard(
                            title: 'Customer Receivables',
                            value: KcFormatters.inr(m.receivablesTotal),
                            trend: 'Pledges & Sales Due',
                            icon: Icons.call_made_rounded,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: KcMetricCard(
                            title: 'Trade Payables',
                            value: KcFormatters.inr(m.payablesTotal),
                            trend: 'Bullion Suppliers Due',
                            icon: Icons.call_received_rounded,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: KcMetricCard(
                            title: 'Loan Principal Active',
                            value: KcFormatters.inr(m.loanOutstandingTotal),
                            trend: 'Pledge Assets Book',
                            icon: Icons.folder_shared_rounded,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: KcMetricCard(
                            title: 'Pledge Interest Income',
                            value: KcFormatters.inr(m.interestIncomeTotal),
                            trend: 'Gold Interest Collected',
                            icon: Icons.monetization_on_rounded,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: KcMetricCard(
                            title: 'Inventory Book Value',
                            value: KcFormatters.inr(m.inventoryValueTotal),
                            trend: 'Gold & Silver Assets',
                            icon: Icons.diamond_rounded,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Navigation Grid Cards for Accounting Sub-Modules
            Text('Financial Modules & Statements', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildNavShortcut(context, 'Chart of Accounts', 'Asset, Liability, Equity, Income, Expense tree', Icons.account_tree_rounded, AppRoutes.accountingAccounts),
                _buildNavShortcut(context, 'Journal Entries', 'Double-entry vouchers & line items', Icons.edit_note_rounded, AppRoutes.accountingJournal),
                _buildNavShortcut(context, 'Financial Transactions', 'Ledger transactions & source linking', Icons.receipt_long_rounded, AppRoutes.accountingTransactions),
                _buildNavShortcut(context, 'Cash Book', 'Physical vault cash movements & balances', Icons.payments_rounded, AppRoutes.accountingCashBook),
                _buildNavShortcut(context, 'Bank Book', 'Bank accounts & cash/bank transfers', Icons.account_balance_rounded, AppRoutes.accountingBankBook),
                _buildNavShortcut(context, 'Income Management', 'Interest, retail sales & service income', Icons.trending_up_rounded, AppRoutes.accountingIncome),
                _buildNavShortcut(context, 'Expense Management', 'Operating expenses, rent, salaries, utilities', Icons.trending_down_rounded, AppRoutes.accountingExpenses),
                _buildNavShortcut(context, 'Receivables', 'Customer loan receivables & aging', Icons.call_made_rounded, AppRoutes.accountingReceivables),
                _buildNavShortcut(context, 'Payables', 'Vendor trade payables & due dates', Icons.call_received_rounded, AppRoutes.accountingPayables),
                _buildNavShortcut(context, 'General Ledger', 'Account ledger transaction explorer', Icons.menu_book_rounded, AppRoutes.accountingLedger),
                _buildNavShortcut(context, 'Trial Balance', 'Debit & Credit equality verification', Icons.balance_rounded, AppRoutes.accountingTrialBalance),
                _buildNavShortcut(context, 'Profit & Loss', 'Revenue breakdown & net profit statement', Icons.assessment_rounded, AppRoutes.accountingProfitLoss),
                _buildNavShortcut(context, 'Balance Sheet', 'Assets = Liabilities + Equity statement', Icons.pie_chart_rounded, AppRoutes.accountingBalanceSheet),
                _buildNavShortcut(context, 'Cash Flow', 'Operating, investing & financing cash flow', Icons.water_drop_rounded, AppRoutes.accountingCashFlow),
                _buildNavShortcut(context, 'Accounting Periods', 'Period closure & fiscal locking UI', Icons.lock_clock_rounded, AppRoutes.accountingPeriods),
              ],
            ),
            const SizedBox(height: 24),

            // Mock Financial Analytics Charts Summary
            KcCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Financial Performance & Cash Flow Trends (Mock Analytics)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: scheme.surfaceContainerHighest.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(10)),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Revenue vs Expense Ratio', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Interest & Sales Revenue', style: TextStyle(fontSize: 13)),
                                  Text('₹97.65 Lakhs', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF059669))),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Operating Expenses', style: TextStyle(fontSize: 13)),
                                  Text('₹19.39 Lakhs', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFDC2626))),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: scheme.surfaceContainerHighest.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(10)),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Loan Portfolio vs Deposit Ratio', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Gold Loan Receivables', style: TextStyle(fontSize: 13)),
                                  Text('₹142.50 Lakhs', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFD97706))),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Customer Security Deposits', style: TextStyle(fontSize: 13)),
                                  Text('₹9.50 Lakhs', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF2563EB))),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavShortcut(BuildContext context, String title, String subtitle, IconData icon, String path) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => context.go(path),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: context.isDesktop ? 280 : double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: scheme.outline.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: scheme.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant), overflow: TextOverflow.ellipsis, maxLines: 1),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
