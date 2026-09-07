import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/buttons/kc_outlined_button.dart';
import '../../../../shared/widgets/buttons/kc_primary_button.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/cards/kc_metric_card.dart';
import '../../../../shared/widgets/feedback/kc_empty_state.dart';
import '../../../../shared/widgets/feedback/kc_error_state.dart';
import '../../../../shared/widgets/feedback/kc_skeleton_loader.dart';
import '../../../../shared/widgets/navigation/kc_page_header.dart';
import '../../../../shared/widgets/navigation/kc_search_bar_filter.dart';

import '../../models/loan_model.dart';
import '../../../ornaments/models/ornament_model.dart';
import '../../providers/loan_providers.dart';
import '../../repository/loan_repository.dart';
import '../../widgets/loan_data_table.dart';
import '../../widgets/loan_filter_dialog.dart';

class LoansPage extends ConsumerStatefulWidget {
  const LoansPage({super.key});

  @override
  ConsumerState<LoansPage> createState() => _LoansPageState();
}

class _LoansPageState extends ConsumerState<LoansPage> {
  late TextEditingController _searchController;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: ref.read(loanSearchQueryProvider));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() => _isSearching = query.isNotEmpty);
    ref.read(loanListProvider.notifier).updateSearch(query);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final loanState = ref.watch(loanListProvider);
    final metricsAsync = ref.watch(loanMetricsProvider);
    final activeFilters = ref.watch(loanFilterProvider);
    final currentSort = ref.watch(loanSortProvider);

    final loans = loanState.valueOrNull ?? [];
    final totalLoans = loans.length;
    final silverLoans = loans.where((l) => l.collateralOrnaments.any((o) => o.metalType == MetalType.silver)).length;
    final goldLoans = totalLoans - silverLoans;
    final goldPct = totalLoans > 0 ? ((goldLoans / totalLoans) * 100).toStringAsFixed(1) : '0.0';
    final silverPct = totalLoans > 0 ? ((silverLoans / totalLoans) * 100).toStringAsFixed(1) : '0.0';

    final activeLoans = loans.where((l) => l.status == LoanStatus.active || l.status == LoanStatus.dueSoon || l.status == LoanStatus.overdue).toList();
    final overdueLoans = activeLoans.where((l) => l.status == LoanStatus.overdue).length;
    final onTimeLoans = activeLoans.length - overdueLoans;
    final onTimePct = activeLoans.isNotEmpty ? ((onTimeLoans / activeLoans.length) * 100).toStringAsFixed(1) : (totalLoans == 0 ? '0.0' : '100.0');
    final overduePct = activeLoans.isNotEmpty ? ((overdueLoans / activeLoans.length) * 100).toStringAsFixed(1) : '0.0';

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(loanMetricsProvider);
          await ref.read(loanListProvider.notifier).loadLoans();
        },
        child: ListView(
          padding: EdgeInsets.all(context.pageGutter),
          children: [
            // Page Header
            KcPageHeader(
              title: context.tr('loans'),
              subtitle: context.tr('pledge_and_loans_desc'),
              actions: [
                KcPrimaryButton(
                  label: context.tr('new_loan_and_pledge'),
                  icon: Icons.add_rounded,
                  onPressed: () => context.go('/loans/create'),
                ),
                KcOutlinedButton(
                  label: context.tr('loan_reports'),
                  icon: Icons.bar_chart_rounded,
                  onPressed: () => context.go('/reports/loans'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Top KPI Metrics Row
            metricsAsync.when(
              loading: () => const SizedBox(height: 100, child: KcSkeletonLoader()),
              error: (err, st) => const SizedBox.shrink(),
              data: (m) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 650;
                    if (isMobile) {
                      return Column(
                        children: [
                          KcMetricCard(
                            title: context.tr('active_loans'),
                            value: m.activeLoansCount.toString(),
                            trend: m.totalOutstandingPrincipal > 0
                                ? '${KcFormatters.inr(m.totalOutstandingPrincipal)} Outstanding'
                                : 'No Active Loans',
                            icon: Icons.account_balance_rounded,
                          ),
                          const SizedBox(height: 12),
                          KcMetricCard(
                            title: context.tr('interest_accrued_due'),
                            value: KcFormatters.inr(m.totalInterestDue),
                            trend: '${KcFormatters.inr(m.totalInterestCollected)} Collected',
                            icon: Icons.monetization_on_rounded,
                          ),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: KcMetricCard(
                                title: context.tr('active_loans'),
                                value: m.activeLoansCount.toString(),
                                trend: m.loansClosedThisMonthCount > 0
                                    ? '${m.loansClosedThisMonthCount} Closed This Month'
                                    : 'No Closed Loans',
                                icon: Icons.folder_open_rounded,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: KcMetricCard(
                                title: context.tr('outstanding_principal'),
                                value: KcFormatters.inr(m.totalOutstandingPrincipal),
                                trend: m.totalOutstandingPrincipal > 0 ? 'Total Active Exposure' : 'No Active Exposure',
                                icon: Icons.account_balance_wallet_rounded,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: KcMetricCard(
                                title: context.tr('interest_accrued_due'),
                                value: KcFormatters.inr(m.totalInterestDue),
                                trend: '${m.overdueLoansCount} Overdue Accounts',
                                icon: Icons.schedule_rounded,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: KcMetricCard(
                                title: context.tr('total_collateral_value'),
                                value: KcFormatters.inr(m.totalCollateralValue),
                                trend: m.totalPledgedWeightGrams > 0
                                    ? '${m.totalPledgedWeightGrams.toStringAsFixed(1)}g Pledged Wt'
                                    : '0.0g Pledged Wt',
                                icon: Icons.savings_rounded,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),

            // Visual Loan Analytics Card
            KcCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.tr('loan_portfolio_analytics'), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 14),
                  if (context.isMobile) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: scheme.surfaceContainerHighest.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(context.tr('collateral_distribution'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(context.tr('gold_collateral_loans'), style: const TextStyle(fontSize: 13)),
                              Text('$goldPct%', style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFD97706))),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(context.tr('silver_collateral_loans'), style: const TextStyle(fontSize: 13)),
                              Text('$silverPct%', style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF6B7280))),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: scheme.surfaceContainerHighest.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(context.tr('loan_health_performance'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(context.tr('current_on_time_loans'), style: const TextStyle(fontSize: 13)),
                              Text('$onTimePct%', style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF059669))),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(context.tr('overdue_interest_accounts'), style: const TextStyle(fontSize: 13)),
                              Text('$overduePct%', style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFDC2626))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ] else
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: scheme.surfaceContainerHighest.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(10)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(context.tr('collateral_distribution'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(context.tr('gold_collateral_loans'), style: const TextStyle(fontSize: 13)),
                                    Text('$goldPct%', style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFD97706))),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(context.tr('silver_collateral_loans'), style: const TextStyle(fontSize: 13)),
                                    Text('$silverPct%', style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF6B7280))),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(context.tr('loan_health_performance'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(context.tr('current_on_time_loans'), style: const TextStyle(fontSize: 13)),
                                    Text('$onTimePct%', style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF059669))),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(context.tr('overdue_interest_accounts'), style: const TextStyle(fontSize: 13)),
                                    Text('$overduePct%', style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFDC2626))),
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
            const SizedBox(height: 24),

            // Search Bar & Filter Controls
            KcSearchBarFilter(
              searchController: _searchController,
              hintText: context.tr('search_loans_placeholder'),
              onSearchChanged: _onSearchChanged,
              filterButton: Badge(
                isLabelVisible: !activeFilters.isEmpty,
                label: const Text('•'),
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14)),
                  icon: const Icon(Icons.filter_list_rounded, size: 18),
                  label: Text(context.tr('filters')),
                  onPressed: () => showLoanFilterSheet(context),
                ),
              ),
              sortDropdown: DropdownButtonHideUnderline(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: scheme.outline.withValues(alpha: 0.4)),
                  ),
                  child: DropdownButton<LoanSortOption>(
                    value: currentSort,
                    isExpanded: true,
                    icon: const Icon(Icons.sort_rounded, size: 18),
                    style: Theme.of(context).textTheme.bodyMedium,
                    onChanged: (sort) {
                      if (sort != null) {
                        ref.read(loanListProvider.notifier).updateSort(sort);
                      }
                    },
                    items: LoanSortOption.values.map((sort) {
                      return DropdownMenuItem(value: sort, child: Text(sort.label, overflow: TextOverflow.ellipsis));
                    }).toList(),
                  ),
                ),
              ),
            ),

                    // Filter Chips
                    if (!activeFilters.isEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text('Active Filters:', style: Theme.of(context).textTheme.labelSmall),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                if (activeFilters.status != null)
                                  Chip(
                                    label: Text('Status: ${activeFilters.status!.label}'),
                                    onDeleted: () {
                                      ref.read(loanListProvider.notifier).updateFilters(
                                            LoanFilterParams(
                                              status: null,
                                              riskStatus: activeFilters.riskStatus,
                                              metalType: activeFilters.metalType,
                                              branch: activeFilters.branch,
                                            ),
                                          );
                                    },
                                  ),
                                if (activeFilters.riskStatus != null)
                                  Chip(
                                    label: Text('Risk: ${activeFilters.riskStatus!.label}'),
                                    onDeleted: () {
                                      ref.read(loanListProvider.notifier).updateFilters(
                                            LoanFilterParams(
                                              status: activeFilters.status,
                                              riskStatus: null,
                                              metalType: activeFilters.metalType,
                                              branch: activeFilters.branch,
                                            ),
                                          );
                                    },
                                  ),
                                TextButton(
                                  onPressed: () => ref.read(loanListProvider.notifier).clearFilters(),
                                  child: const Text('Clear All'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
            const SizedBox(height: 20),

            // Loan List / Table
            loanState.when(
              loading: () => Column(
                children: List.generate(5, (i) => const Padding(padding: EdgeInsets.only(bottom: 12), child: KcSkeletonLoader(height: 72))),
              ),
              error: (err, st) => KcErrorState(
                message: 'Unable to load Gold & Silver Loans: ${err.toString()}',
                onRetry: () => ref.read(loanListProvider.notifier).loadLoans(),
              ),
              data: (loans) {
                if (loans.isEmpty) {
                  return KcEmptyState(
                    title: _isSearching ? 'No Matching Loan Accounts' : 'No Loans Found',
                    subtitle: _isSearching
                        ? 'No gold/silver loan accounts match "$_searchController.text". Try searching by ID or customer name.'
                        : 'No active or historical gold loan accounts registered.',
                    action: KcPrimaryButton(
                      label: _isSearching ? 'Clear Search' : 'New Loan & Pledge Wizard',
                      onPressed: _isSearching
                          ? () {
                              _searchController.clear();
                              _onSearchChanged('');
                            }
                          : () => context.go('/loans/create'),
                    ),
                  );
                }

                return LoanDataTable(loans: loans);
              },
            ),
          ],
        ),
      ),
    );
  }
}
