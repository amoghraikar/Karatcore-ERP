import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/buttons/kc_outlined_button.dart';
import '../../../../shared/widgets/buttons/kc_primary_button.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/cards/kc_metric_card.dart';
import '../../../../shared/widgets/feedback/kc_empty_state.dart';
import '../../../../shared/widgets/feedback/kc_error_state.dart';
import '../../../../shared/widgets/feedback/kc_skeleton_loader.dart';

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
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pledge & Gold/Silver Loans',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Secured precious-metal lending, KYC verified customer pledges, interest accruals, repayments, full settlements, and collateral releases.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                KcPrimaryButton(
                  label: 'New Loan & Pledge',
                  icon: Icons.add_rounded,
                  onPressed: () => context.go('/loans/create'),
                ),
                const SizedBox(width: 10),
                KcOutlinedButton(
                  label: 'Loan Reports',
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
                            title: 'Active Loans',
                            value: m.activeLoansCount.toString(),
                            trend: '${KcFormatters.inr(m.totalOutstandingPrincipal)} Outstanding',
                            icon: Icons.account_balance_rounded,
                          ),
                          const SizedBox(height: 12),
                          KcMetricCard(
                            title: 'Interest Due',
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
                                title: 'Active Loans',
                                value: m.activeLoansCount.toString(),
                                trend: '${m.loansClosedThisMonthCount} Closed This Month',
                                icon: Icons.folder_open_rounded,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: KcMetricCard(
                                title: 'Outstanding Principal',
                                value: KcFormatters.inr(m.totalOutstandingPrincipal),
                                trend: 'Total Active Exposure',
                                icon: Icons.account_balance_wallet_rounded,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: KcMetricCard(
                                title: 'Interest Accrued Due',
                                value: KcFormatters.inr(m.totalInterestDue),
                                trend: '${m.overdueLoansCount} Overdue Accounts',
                                icon: Icons.schedule_rounded,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: KcMetricCard(
                                title: 'Total Collateral Value',
                                value: KcFormatters.inr(m.totalCollateralValue),
                                trend: '${m.totalPledgedWeightGrams.toStringAsFixed(1)}g Pledged Wt',
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
                  Text('Loan Portfolio & Collateral Analytics (Mock Summary)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
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
                              Text('Collateral Distribution', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Gold Collateral Loans', style: TextStyle(fontSize: 13)),
                                  Text('83.4%', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFD97706))),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Silver Collateral Loans', style: TextStyle(fontSize: 13)),
                                  Text('16.6%', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF6B7280))),
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
                              Text('Loan Health Performance', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Current On-Time Loans', style: TextStyle(fontSize: 13)),
                                  Text('92.1%', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF059669))),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Overdue Interest Accounts', style: TextStyle(fontSize: 13)),
                                  Text('7.9%', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFDC2626))),
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
            Card(
              elevation: 0,
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: _onSearchChanged,
                            decoration: InputDecoration(
                              hintText: 'Search Loans by Loan ID (KC-LN-xxx), Customer Name, Customer ID, Mobile, or Pledge ID...',
                              prefixIcon: const Icon(Icons.search_rounded),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear_rounded),
                                      onPressed: () {
                                        _searchController.clear();
                                        _onSearchChanged('');
                                      },
                                    )
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: scheme.surface,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Filter Button
                        Badge(
                          isLabelVisible: !activeFilters.isEmpty,
                          label: const Text('•'),
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16)),
                            icon: const Icon(Icons.filter_list_rounded, size: 18),
                            label: Text(context.isMobile ? 'Filter' : 'Filters'),
                            onPressed: () => showLoanFilterSheet(context),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Sort Dropdown
                        DropdownButtonHideUnderline(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: scheme.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: scheme.outline.withValues(alpha: 0.4)),
                            ),
                            child: DropdownButton<LoanSortOption>(
                              value: currentSort,
                              icon: const Icon(Icons.sort_rounded, size: 18),
                              style: Theme.of(context).textTheme.bodyMedium,
                              onChanged: (sort) {
                                if (sort != null) {
                                  ref.read(loanListProvider.notifier).updateSort(sort);
                                }
                              },
                              items: LoanSortOption.values.map((sort) {
                                return DropdownMenuItem(value: sort, child: Text(sort.label));
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Filter Chips
                    if (!activeFilters.isEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text('Active Filters:', style: Theme.of(context).textTheme.labelSmall),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  if (activeFilters.status != null)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: Chip(
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
                                    ),
                                  if (activeFilters.riskStatus != null)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: Chip(
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
                                    ),
                                  TextButton(
                                    onPressed: () => ref.read(loanListProvider.notifier).clearFilters(),
                                    child: const Text('Clear All'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
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
