import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/buttons/kc_outlined_button.dart';
import '../../../../shared/widgets/buttons/kc_primary_button.dart';
import '../../../../shared/widgets/cards/kc_metric_card.dart';
import '../../../../shared/widgets/feedback/kc_empty_state.dart';
import '../../../../shared/widgets/feedback/kc_error_state.dart';
import '../../../../shared/widgets/feedback/kc_skeleton_loader.dart';
import '../../../../shared/widgets/navigation/kc_page_header.dart';
import '../../../../shared/widgets/navigation/kc_search_bar_filter.dart';

import '../../providers/inventory_providers.dart';
import '../../repository/inventory_repository.dart';
import '../../widgets/ornament_data_table.dart';
import '../../widgets/ornament_filter_dialog.dart';

class OrnamentsPage extends ConsumerStatefulWidget {
  const OrnamentsPage({super.key});

  @override
  ConsumerState<OrnamentsPage> createState() => _OrnamentsPageState();
}

class _OrnamentsPageState extends ConsumerState<OrnamentsPage> {
  late TextEditingController _searchController;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: ref.read(inventorySearchQueryProvider));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() => _isSearching = query.isNotEmpty);
    ref.read(ornamentListProvider.notifier).updateSearch(query);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ornamentState = ref.watch(ornamentListProvider);
    final metricsAsync = ref.watch(inventoryMetricsProvider);
    final activeFilters = ref.watch(inventoryFilterProvider);
    final currentSort = ref.watch(inventorySortProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(inventoryMetricsProvider);
          await ref.read(ornamentListProvider.notifier).loadOrnaments();
        },
        child: ListView(
          padding: EdgeInsets.all(context.pageGutter),
          children: [
            // Page Header
            KcPageHeader(
              title: 'Ornaments & Inventory',
              subtitle: 'Gold & Silver stock, purity tracking, weight breakdown (Gross - Stone = Net Metal Wt), vault lockers, and customer pledges.',
              actions: [
                KcOutlinedButton(
                  label: 'Movements Log',
                  icon: Icons.history_rounded,
                  onPressed: () => context.go('/inventory/movements'),
                ),
                KcOutlinedButton(
                  label: 'Reports',
                  icon: Icons.bar_chart_rounded,
                  onPressed: () => context.go('/reports/inventory'),
                ),
                KcPrimaryButton(
                  label: 'Add Ornament',
                  icon: Icons.add_rounded,
                  onPressed: () => context.go('/inventory/create'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Metrics Cards Row
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
                            title: 'Total Ornaments',
                            value: m.totalOrnamentsCount.toString(),
                            trend: '${m.totalNetMetalWeightGrams.toStringAsFixed(1)}g Net Metal Wt',
                            icon: Icons.inventory_2_rounded,
                          ),
                          const SizedBox(height: 12),
                          KcMetricCard(
                            title: 'Estimated Stock Value',
                            value: KcFormatters.inr(m.totalEstimatedValue),
                            trend: '${m.pledgedStockCount} Pledged Items',
                            icon: Icons.account_balance_wallet_rounded,
                          ),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(
                          child: KcMetricCard(
                            title: 'Total Gold Stock',
                            value: '${m.totalGoldWeightGrams.toStringAsFixed(1)}g',
                            trend: '${m.totalOrnamentsCount} Total Ornaments',
                            icon: Icons.savings_rounded,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: KcMetricCard(
                            title: 'Silver Stock',
                            value: '${m.totalSilverWeightGrams.toStringAsFixed(1)}g',
                            trend: 'Pure 925 & 999',
                            icon: Icons.monetization_on_rounded,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: KcMetricCard(
                            title: 'Available / Pledged',
                            value: '${m.availableStockCount} / ${m.pledgedStockCount}',
                            trend: '${m.soldReleasedCount} Released/Sold',
                            icon: Icons.lock_clock_rounded,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: KcMetricCard(
                            title: 'Estimated Inventory Value',
                            value: KcFormatters.inr(m.totalEstimatedValue),
                            trend: 'Real-time Valuation',
                            icon: Icons.account_balance_wallet_rounded,
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),

            // Search Bar & Filter Controls
            KcSearchBarFilter(
              searchController: _searchController,
              hintText: 'Search Inventory by Ornament ID, Name, Barcode, Category...',
              onSearchChanged: _onSearchChanged,
              filterButton: Badge(
                isLabelVisible: !activeFilters.isEmpty,
                label: const Text('•'),
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14)),
                  icon: const Icon(Icons.filter_list_rounded, size: 18),
                  label: const Text('Filters'),
                  onPressed: () => showOrnamentFilterSheet(context),
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
                  child: DropdownButton<InventorySortOption>(
                    value: currentSort,
                    isExpanded: true,
                    icon: const Icon(Icons.sort_rounded, size: 18),
                    style: Theme.of(context).textTheme.bodyMedium,
                    onChanged: (sort) {
                      if (sort != null) {
                        ref.read(ornamentListProvider.notifier).updateSort(sort);
                      }
                    },
                    items: InventorySortOption.values.map((sort) {
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
                                if (activeFilters.metalType != null)
                                  Chip(
                                    label: Text('Metal: ${activeFilters.metalType!.label}'),
                                    onDeleted: () {
                                      ref.read(ornamentListProvider.notifier).updateFilters(
                                            InventoryFilterParams(
                                              metalType: null,
                                              purity: activeFilters.purity,
                                              category: activeFilters.category,
                                              status: activeFilters.status,
                                              ownershipType: activeFilters.ownershipType,
                                            ),
                                          );
                                    },
                                  ),
                                if (activeFilters.status != null)
                                  Chip(
                                    label: Text('Status: ${activeFilters.status!.label}'),
                                    onDeleted: () {
                                      ref.read(ornamentListProvider.notifier).updateFilters(
                                            InventoryFilterParams(
                                              metalType: activeFilters.metalType,
                                              purity: activeFilters.purity,
                                              category: activeFilters.category,
                                              status: null,
                                              ownershipType: activeFilters.ownershipType,
                                            ),
                                          );
                                    },
                                  ),
                                TextButton(
                                  onPressed: () => ref.read(ornamentListProvider.notifier).clearFilters(),
                                  child: const Text('Clear All'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
            const SizedBox(height: 20),

            // Ornament Directory List/Table
            ornamentState.when(
              loading: () => Column(
                children: List.generate(5, (i) => const Padding(padding: EdgeInsets.only(bottom: 12), child: KcSkeletonLoader(height: 72))),
              ),
              error: (err, st) => KcErrorState(
                message: 'Unable to load Ornaments Inventory: ${err.toString()}',
                onRetry: () => ref.read(ornamentListProvider.notifier).loadOrnaments(),
              ),
              data: (ornaments) {
                if (ornaments.isEmpty) {
                  return KcEmptyState(
                    title: _isSearching ? 'No Matching Ornaments' : 'Inventory Vault Empty',
                    subtitle: _isSearching
                        ? 'No ornaments match "$_searchController.text". Try searching by ID, barcode, or purity.'
                        : 'No ornaments registered in system inventory.',
                    action: KcPrimaryButton(
                      label: _isSearching ? 'Clear Search' : 'Add New Ornament',
                      onPressed: _isSearching
                          ? () {
                              _searchController.clear();
                              _onSearchChanged('');
                            }
                          : () => context.go('/inventory/create'),
                    ),
                  );
                }

                return OrnamentDataTable(ornaments: ornaments);
              },
            ),
          ],
        ),
      ),
    );
  }
}
