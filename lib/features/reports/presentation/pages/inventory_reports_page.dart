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

import '../../../ornaments/models/ornament_model.dart';
import '../../../ornaments/providers/inventory_providers.dart';
import '../../providers/reports_providers.dart';
import '../../widgets/report_date_filter.dart';
import '../../widgets/report_table.dart';
import '../../widgets/report_error_state.dart';

class InventoryReportsPage extends ConsumerWidget {
  const InventoryReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invAnalyticsAsync = ref.watch(inventoryAnalyticsProvider);
    final ornamentsAsync = ref.watch(ornamentListProvider);
    final filterParam = GoRouterState.of(context).uri.queryParameters['filter'];

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
                    Text('Ornament & Inventory Analytics', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text('Metal weights, purity breakdowns, vault valuations, pledged vs available stock & aging', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          const ReportDateFilter(),
          const SizedBox(height: 20),

          invAnalyticsAsync.when(
            loading: () => const KcSkeletonLoader(height: 180),
            error: (err, st) => ReportErrorState(error: err, onRetry: () { ref.invalidate(inventoryAnalyticsProvider); ref.invalidate(ornamentListProvider); }),
            data: (data) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: KcMetricCard(
                          title: 'Total Gross Weight',
                          value: '${(data['totalGrossWeightGrams'] as double).toStringAsFixed(1)} g',
                          trend: 'Total Vault Weight',
                          icon: Icons.scale_rounded,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: KcMetricCard(
                          title: 'Net Metal Weight',
                          value: '${(data['totalNetMetalWeightGrams'] as double).toStringAsFixed(1)} g',
                          trend: 'Purity Deducted Metal',
                          icon: Icons.fit_screen_rounded,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: KcMetricCard(
                          title: 'Pledged Vault Valuation',
                          value: KcFormatters.inr(data['pledgedValuation']),
                          trend: 'Active Collateral Stocks',
                          icon: Icons.lock_rounded,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Purity Distribution & Category Chart
          Row(
            children: [
              Expanded(
                child: KcCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Gold Purity Distribution (Karats)', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 12),
                      KcChartWrapper.donutChart(
                        context: context,
                        data: const [
                          KcDonutDataPoint(label: '22K Standard (91.6%)', value: 70, color: Color(0xFFD97706)),
                          KcDonutDataPoint(label: '24K Pure (99.9%)', value: 18, color: Color(0xFFEAB308)),
                          KcDonutDataPoint(label: '18K Ornaments (75.0%)', value: 12, color: Color(0xFF94A3B8)),
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
                      Text('Ornament Category Distribution', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 12),
                      KcChartWrapper.barChart(
                        context: context,
                        data: const [
                          KcChartDataPoint(xLabel: 'Bangles', value: 35),
                          KcChartDataPoint(xLabel: 'Chains', value: 28),
                          KcChartDataPoint(xLabel: 'Rings', value: 18),
                          KcChartDataPoint(xLabel: 'Necklaces', value: 14),
                          KcChartDataPoint(xLabel: 'Coins', value: 5),
                        ],
                        barColor: const Color(0xFF059669),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Inventory Master Table
          Text('Inventory Master Report Table', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),

          ornamentsAsync.when(
            loading: () => const KcSkeletonLoader(height: 350),
            error: (err, st) => ReportErrorState(error: err, onRetry: () => ref.invalidate(ornamentListProvider)),
            data: (ornaments) {
              final visibleOrnaments = filterParam == 'vault-audit'
                  ? ornaments.where((o) => o.status == OrnamentStatus.available || o.status == OrnamentStatus.damaged).toList()
                  : ornaments;

              final rows = visibleOrnaments.map((o) {
                return {
                  'ornamentId': o.id,
                  'name': o.name,
                  'metal': o.metalType.label,
                  'purity': o.purity.label,
                  'grossWeight': '${o.weight.grossWeight.toStringAsFixed(1)}g',
                  'stoneWeight': '${o.weight.stoneWeight.toStringAsFixed(1)}g',
                  'otherWeight': '${o.weight.otherWeight.toStringAsFixed(1)}g',
                  'netWeight': '${o.weight.netMetalWeight.toStringAsFixed(1)}g',
                  'metalValue': KcFormatters.inr(o.valuation.metalValue),
                  'makingValue': KcFormatters.inr(o.valuation.makingCharges),
                  'estimatedValue': KcFormatters.inr(o.valuation.totalEstimatedValue),
                  'status': o.status.label,
                  'location': o.location.fullLocationPath,
                };
              }).toList();

              return ReportTable(
                title: 'Ornament Inventory Master Report',
                columns: const [
                  ReportColumnConfig(key: 'ornamentId', label: 'Ornament ID'),
                  ReportColumnConfig(key: 'name', label: 'Item Description'),
                  ReportColumnConfig(key: 'metal', label: 'Metal'),
                  ReportColumnConfig(key: 'purity', label: 'Purity'),
                  ReportColumnConfig(key: 'grossWeight', label: 'Gross Wt', isNumeric: true),
                  ReportColumnConfig(key: 'stoneWeight', label: 'Stone Wt', isNumeric: true),
                  ReportColumnConfig(key: 'otherWeight', label: 'Other Wt', isNumeric: true),
                  ReportColumnConfig(key: 'netWeight', label: 'Net Metal Wt', isNumeric: true),
                  ReportColumnConfig(key: 'metalValue', label: 'Metal Val (₹)', isNumeric: true),
                  ReportColumnConfig(key: 'makingValue', label: 'Making (₹)', isNumeric: true),
                  ReportColumnConfig(key: 'estimatedValue', label: 'Total Value (₹)', isNumeric: true),
                  ReportColumnConfig(key: 'status', label: 'Status'),
                  ReportColumnConfig(key: 'location', label: 'Vault Location'),
                ],
                rows: rows,
                onRowTap: (row) => context.go('/inventory/${row['ornamentId']}'),
              );
            },
          ),
          const SizedBox(height: 24),

          // Inventory Weight Analysis Report Section
          Text('Inventory Weight Analysis Report (by Metal & Purity)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),

          ref.watch(inventoryWeightReportProvider).when(
                loading: () => const KcSkeletonLoader(height: 200),
                error: (err, st) => const SizedBox.shrink(),
                data: (weightItems) {
                  final rows = weightItems.map((w) {
                    return {
                      'groupKey': w.groupKey,
                      'metal': w.metal,
                      'purity': w.purity,
                      'category': w.category,
                      'itemCount': w.itemCount.toString(),
                      'grossWeight': '${w.grossWeightGrams.toStringAsFixed(1)}g',
                      'stoneWeight': '${w.stoneWeightGrams.toStringAsFixed(1)}g',
                      'otherWeight': '${w.otherWeightGrams.toStringAsFixed(1)}g',
                      'netMetalWeight': '${w.netMetalWeightGrams.toStringAsFixed(1)}g',
                    };
                  }).toList();

                  return ReportTable(
                    title: 'Inventory Metal Weight Analysis Report',
                    columns: const [
                      ReportColumnConfig(key: 'groupKey', label: 'Group Breakdown'),
                      ReportColumnConfig(key: 'itemCount', label: 'Quantity', isNumeric: true),
                      ReportColumnConfig(key: 'grossWeight', label: 'Gross Weight', isNumeric: true),
                      ReportColumnConfig(key: 'stoneWeight', label: 'Stone Weight', isNumeric: true),
                      ReportColumnConfig(key: 'otherWeight', label: 'Other Weight', isNumeric: true),
                      ReportColumnConfig(key: 'netMetalWeight', label: 'Net Metal Weight', isNumeric: true),
                    ],
                    rows: rows,
                  );
                },
              ),
        ],
      ),
    );
  }
}
