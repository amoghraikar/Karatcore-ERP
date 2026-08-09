import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/routes.dart';
import '../../../../shared/widgets/feedback/kc_skeleton_loader.dart';

import '../../models/reports_model.dart';
import '../../providers/reports_providers.dart';
import '../../widgets/report_date_filter.dart';
import '../../widgets/report_table.dart';
import '../../widgets/report_error_state.dart';

class SavedReportDetailPage extends ConsumerWidget {
  const SavedReportDetailPage({super.key, required this.reportId});

  final String? reportId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedViewsAsync = ref.watch(savedReportViewsProvider);

    return Scaffold(
      body: savedViewsAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(24),
          child: KcSkeletonLoader(height: 300),
        ),
        error: (err, st) => Padding(
          padding: const EdgeInsets.all(24),
          child: ReportErrorState(
            error: err,
            onRetry: () => ref.invalidate(savedReportViewsProvider),
          ),
        ),
        data: (views) {
          final view = views.firstWhere(
            (v) => v.id == reportId,
            orElse: () => SavedReportView(
              id: reportId ?? 'VIEW-CUSTOM',
              title: 'Saved Custom Report View',
              category: ReportCategory.executive,
              filterPreset: DateFilterPreset.thisMonth,
              lastViewedAt: DateTime.now(),
            ),
          );

          return ListView(
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
                        Row(
                          children: [
                            Text(
                              view.title,
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(width: 8),
                            if (view.isFavorite)
                              const Icon(Icons.star_rounded, color: Colors.amber, size: 22),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Category: ${view.category.label} • Saved Filter Preset: ${view.filterPreset.label}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              const ReportDateFilter(),
              const SizedBox(height: 20),

              ReportTable(
                title: '${view.title} Data Table View',
                columns: const [
                  ReportColumnConfig(key: 'recordId', label: 'Reference ID'),
                  ReportColumnConfig(key: 'title', label: 'Item Name / Label'),
                  ReportColumnConfig(key: 'category', label: 'Category'),
                  ReportColumnConfig(key: 'status', label: 'Status'),
                  ReportColumnConfig(key: 'amount', label: 'Amount (₹)', isNumeric: true),
                ],
                rows: [
                  {
                    'recordId': 'REC-1001',
                    'title': '${view.title} Sample Item 1',
                    'category': view.category.label,
                    'status': 'ACTIVE',
                    'amount': '₹1,45,000',
                  },
                  {
                    'recordId': 'REC-1002',
                    'title': '${view.title} Sample Item 2',
                    'category': view.category.label,
                    'status': 'VERIFIED',
                    'amount': '₹82,500',
                  },
                  {
                    'recordId': 'REC-1003',
                    'title': '${view.title} Sample Item 3',
                    'category': view.category.label,
                    'status': 'COMPLETED',
                    'amount': '₹3,10,000',
                  },
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
