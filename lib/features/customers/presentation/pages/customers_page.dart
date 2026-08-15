import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/buttons/kc_outlined_button.dart';
import '../../../../shared/widgets/buttons/kc_primary_button.dart';
import '../../../../shared/widgets/cards/kc_metric_card.dart';
import '../../../../shared/widgets/feedback/kc_empty_state.dart';
import '../../../../shared/widgets/feedback/kc_error_state.dart';
import '../../../../shared/widgets/feedback/kc_skeleton_loader.dart';
import '../../../../shared/widgets/navigation/kc_page_header.dart';
import '../../../../shared/widgets/navigation/kc_search_bar_filter.dart';
import '../../models/customer_model.dart';
import '../../providers/customer_providers.dart';
import '../../repository/customer_repository.dart';
import '../../widgets/customer_card.dart';
import '../../widgets/customer_data_table.dart';
import '../../widgets/customer_filter_dialog.dart';

class CustomersPage extends ConsumerStatefulWidget {
  const CustomersPage({super.key});

  @override
  ConsumerState<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends ConsumerState<CustomersPage> {
  late TextEditingController _searchController;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: ref.read(customerSearchQueryProvider));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() => _isSearching = query.isNotEmpty);
    ref.read(customerListProvider.notifier).updateSearch(query);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final customersState = ref.watch(customerListProvider);
    final activeFilters = ref.watch(customerFilterProvider);
    final currentSort = ref.watch(customerSortProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(customerListProvider.notifier).loadCustomers(),
        child: ListView(
          padding: EdgeInsets.all(context.pageGutter),
          children: [
            // Page Header Row
            KcPageHeader(
              title: 'Customer Management & CRM',
              subtitle: 'Central customer directory, KYC compliance, pledged portfolio, and audit records.',
              actions: [
                KcPrimaryButton(
                  label: 'Add Customer',
                  icon: Icons.person_add_alt_1_rounded,
                  onPressed: () => context.go(AppRoutes.customerCreate),
                ),
                KcOutlinedButton(
                  label: 'Customer Reports',
                  icon: Icons.bar_chart_rounded,
                  onPressed: () => context.go(AppRoutes.reportsCustomers),
                ),
              ],
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.08, end: 0),
            const SizedBox(height: 24),

            // Top Metric Cards Row
            customersState.maybeWhen(
              data: (list) {
                final totalCount = list.length;
                final activeLoans = list.fold<int>(0, (sum, c) => sum + c.activeLoansCount);
                final totalOutstanding = list.fold<double>(0.0, (sum, c) => sum + c.totalOutstandingAmount);
                final verifiedCount = list.where((c) => c.kycStatus == CustomerKycStatus.verified).length;

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 650;
                    if (isMobile) {
                      return Column(
                        children: [
                          KcMetricCard(
                            title: 'Total Customers',
                            value: totalCount.toString(),
                            trend: '+8 this week',
                            icon: Icons.groups_rounded,
                          ),
                          const SizedBox(height: 12),
                          KcMetricCard(
                            title: 'Outstanding Loan Portfolio',
                            value: KcFormatters.inrCompact(totalOutstanding),
                            trend: '$activeLoans Active Pledges',
                            icon: Icons.account_balance_rounded,
                          ),
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(
                          child: KcMetricCard(
                            title: 'Total Directory Customers',
                            value: totalCount.toString(),
                            trend: '+12% vs last month',
                            icon: Icons.groups_rounded,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: KcMetricCard(
                            title: 'Active Gold Pledges',
                            value: '$activeLoans Loans',
                            trend: 'Collateral Secured',
                            icon: Icons.diamond_rounded,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: KcMetricCard(
                            title: 'Total Outstanding Principal',
                            value: KcFormatters.inrCompact(totalOutstanding),
                            trend: 'Risk Managed',
                            icon: Icons.account_balance_wallet_rounded,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: KcMetricCard(
                            title: 'KYC Verified Accounts',
                            value: '$verifiedCount / $totalCount',
                            trend: 'Audit Compliance Level 1',
                            icon: Icons.verified_user_rounded,
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              orElse: () => const SizedBox(
                height: 100,
                child: KcSkeletonLoader(),
              ),
            ),
            const SizedBox(height: 24),

            // Search Bar & Filter Bar
            KcSearchBarFilter(
              searchController: _searchController,
              hintText: 'Search by Name, Mobile, ID, Email, PAN, Aadhaar...',
              onSearchChanged: _onSearchChanged,
              filterButton: Badge(
                isLabelVisible: !activeFilters.isEmpty,
                label: const Text('•'),
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                  icon: const Icon(Icons.filter_list_rounded, size: 18),
                  label: const Text('Filters'),
                  onPressed: () => showCustomerFilterSheet(context),
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
                  child: DropdownButton<CustomerSortOption>(
                    value: currentSort,
                    isExpanded: true,
                    icon: const Icon(Icons.sort_rounded, size: 18),
                    style: Theme.of(context).textTheme.bodyMedium,
                    onChanged: (sort) {
                      if (sort != null) {
                        ref.read(customerListProvider.notifier).updateSort(sort);
                      }
                    },
                    items: CustomerSortOption.values.map((sort) {
                      return DropdownMenuItem(
                        value: sort,
                        child: Text(sort.label, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),

                    // Quick Filter Chips Row
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
                                  if (activeFilters.kycStatus != null)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: Chip(
                                        label: Text('KYC: ${activeFilters.kycStatus!.label}'),
                                        onDeleted: () {
                                          ref.read(customerListProvider.notifier).updateFilters(
                                                CustomerFilterParams(
                                                  kycStatus: null,
                                                  customerStatus: activeFilters.customerStatus,
                                                  customerType: activeFilters.customerType,
                                                  riskLevel: activeFilters.riskLevel,
                                                  hasActiveLoans: activeFilters.hasActiveLoans,
                                                ),
                                              );
                                        },
                                      ),
                                    ),
                                  if (activeFilters.customerStatus != null)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: Chip(
                                        label: Text('Status: ${activeFilters.customerStatus!.label}'),
                                        onDeleted: () {
                                          ref.read(customerListProvider.notifier).updateFilters(
                                                CustomerFilterParams(
                                                  kycStatus: activeFilters.kycStatus,
                                                  customerStatus: null,
                                                  customerType: activeFilters.customerType,
                                                  riskLevel: activeFilters.riskLevel,
                                                  hasActiveLoans: activeFilters.hasActiveLoans,
                                                ),
                                              );
                                        },
                                      ),
                                    ),
                                  TextButton(
                                    onPressed: () => ref.read(customerListProvider.notifier).clearFilters(),
                                    child: const Text('Clear All'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
            const SizedBox(height: 20),

            // Main Data List / Table Content
            customersState.when(
              loading: () => Column(
                children: List.generate(
                  5,
                  (index) => const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: KcSkeletonLoader(height: 72),
                  ),
                ),
              ),
              error: (err, st) => KcErrorState(
                message: 'Unable to load customer directory: ${err.toString()}',
                onRetry: () => ref.read(customerListProvider.notifier).loadCustomers(),
              ),
              data: (customers) {
                if (customers.isEmpty) {
                  return KcEmptyState(
                    title: _isSearching ? 'No Matching Customers Found' : 'No Customers Registered',
                    subtitle: _isSearching
                        ? 'No records match "${_searchController.text}". Try searching by phone, ID, or name.'
                        : 'Get started by onboarding your first jewellery business customer.',
                    action: KcPrimaryButton(
                      label: _isSearching ? 'Clear Search' : 'Add New Customer',
                      onPressed: _isSearching
                          ? () {
                              _searchController.clear();
                              _onSearchChanged('');
                            }
                          : () => context.go(AppRoutes.customerCreate),
                    ),
                  );
                }

                if (context.isDesktop) {
                  return CustomerDataTable(customers: customers);
                }

                return Column(
                  children: customers
                      .map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: CustomerCard(customer: c),
                          ))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
