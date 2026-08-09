import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/buttons/kc_outlined_button.dart';
import '../../../../shared/widgets/buttons/kc_primary_button.dart';
import '../../../../shared/widgets/cards/kc_metric_card.dart';
import '../../../../shared/widgets/feedback/kc_empty_state.dart';
import '../../../../shared/widgets/feedback/kc_error_state.dart';
import '../../../../shared/widgets/feedback/kc_skeleton_loader.dart';

import '../../providers/kyc_providers.dart';
import '../../repository/kyc_repository.dart';
import '../../widgets/kyc_filter_dialog.dart';
import '../../widgets/kyc_queue_table.dart';

class KycPage extends ConsumerStatefulWidget {
  const KycPage({super.key});

  @override
  ConsumerState<KycPage> createState() => _KycPageState();
}

class _KycPageState extends ConsumerState<KycPage> {
  late TextEditingController _searchController;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: ref.read(kycSearchQueryProvider));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() => _isSearching = query.isNotEmpty);
    ref.read(kycQueueProvider.notifier).updateSearch(query);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final queueState = ref.watch(kycQueueProvider);
    final metricsAsync = ref.watch(kycMetricsProvider);
    final activeFilters = ref.watch(kycFilterProvider);
    final currentSort = ref.watch(kycSortProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(kycMetricsProvider);
          await ref.read(kycQueueProvider.notifier).loadQueue();
        },
        child: ListView(
          padding: EdgeInsets.all(context.pageGutter),
          children: [
            // Page Title Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'KYC & Trust Layer',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Identity verification, government document audit queue, risk classification, and immutable audit logs.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                KcPrimaryButton(
                  label: 'Initiate KYC',
                  icon: Icons.verified_user_rounded,
                  onPressed: () => context.go('/kyc/KC-CUS-000101/start'),
                ),
                const SizedBox(width: 10),
                KcOutlinedButton(
                  label: 'KYC Reports',
                  icon: Icons.bar_chart_rounded,
                  onPressed: () => context.go('/reports/kyc'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Top Dashboard Metrics Row
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
                            title: 'Total KYC Audit Queue',
                            value: m.totalRequiringKyc.toString(),
                            trend: '${m.completionRatePercent.toStringAsFixed(1)}% Verified Rate',
                            icon: Icons.folder_copy_rounded,
                          ),
                          const SizedBox(height: 12),
                          KcMetricCard(
                            title: 'Pending Review',
                            value: m.pendingReviewCount.toString(),
                            trend: '${m.highRiskCount} High Risk Flags',
                            icon: Icons.hourglass_top_rounded,
                          ),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(
                          child: KcMetricCard(
                            title: 'Verified Accounts',
                            value: m.verifiedCount.toString(),
                            trend: '${m.completionRatePercent.toStringAsFixed(1)}% Verified Rate',
                            icon: Icons.verified_rounded,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: KcMetricCard(
                            title: 'Pending Staff Review',
                            value: m.pendingReviewCount.toString(),
                            trend: 'Awaiting Action',
                            icon: Icons.hourglass_top_rounded,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: KcMetricCard(
                            title: 'Reverification Needed',
                            value: m.reverificationCount.toString(),
                            trend: '${m.expiredCount} Expired Records',
                            icon: Icons.published_with_changes_rounded,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: KcMetricCard(
                            title: 'Rejected / High Risk',
                            value: '${m.rejectedCount} / ${m.highRiskCount}',
                            trend: 'Audit Warning',
                            icon: Icons.gpp_bad_rounded,
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),

            // Search Bar & Filter Controls Row
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
                              hintText: 'Search KYC Queue by Customer Name, ID, Mobile, or Record ID...',
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
                            onPressed: () => showKycFilterSheet(context),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Sort Selector
                        DropdownButtonHideUnderline(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: scheme.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: scheme.outline.withValues(alpha: 0.4)),
                            ),
                            child: DropdownButton<KycSortOption>(
                              value: currentSort,
                              icon: const Icon(Icons.sort_rounded, size: 18),
                              style: Theme.of(context).textTheme.bodyMedium,
                              onChanged: (sort) {
                                if (sort != null) {
                                  ref.read(kycQueueProvider.notifier).updateSort(sort);
                                }
                              },
                              items: KycSortOption.values.map((sort) {
                                return DropdownMenuItem(value: sort, child: Text(sort.label));
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Active Filter Chips
                    if (!activeFilters.isEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text('Active Queue Filters:', style: Theme.of(context).textTheme.labelSmall),
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
                                          ref.read(kycQueueProvider.notifier).updateFilters(
                                                KycFilterParams(
                                                  status: null,
                                                  level: activeFilters.level,
                                                  riskStatus: activeFilters.riskStatus,
                                                  method: activeFilters.method,
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
                                          ref.read(kycQueueProvider.notifier).updateFilters(
                                                KycFilterParams(
                                                  status: activeFilters.status,
                                                  level: activeFilters.level,
                                                  riskStatus: null,
                                                  method: activeFilters.method,
                                                ),
                                              );
                                        },
                                      ),
                                    ),
                                  TextButton(
                                    onPressed: () => ref.read(kycQueueProvider.notifier).clearFilters(),
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

            // Queue Table Content
            queueState.when(
              loading: () => Column(
                children: List.generate(5, (i) => const Padding(padding: EdgeInsets.only(bottom: 12), child: KcSkeletonLoader(height: 72))),
              ),
              error: (err, st) => KcErrorState(
                message: 'Unable to load KYC Queue: ${err.toString()}',
                onRetry: () => ref.read(kycQueueProvider.notifier).loadQueue(),
              ),
              data: (records) {
                if (records.isEmpty) {
                  return KcEmptyState(
                    title: _isSearching ? 'No Matching KYC Records' : 'KYC Audit Queue Clear',
                    subtitle: _isSearching
                        ? 'No records match "$_searchController.text". Try searching by customer name or phone.'
                        : 'No pending customer identity verifications in queue.',
                    action: KcPrimaryButton(
                      label: _isSearching ? 'Clear Search' : 'Start New Customer KYC',
                      onPressed: _isSearching
                          ? () {
                              _searchController.clear();
                              _onSearchChanged('');
                            }
                          : () => context.go('/kyc/KC-CUS-000101/start'),
                    ),
                  );
                }

                return KycQueueTable(records: records);
              },
            ),
          ],
        ),
      ),
    );
  }
}
