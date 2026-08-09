import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/feedback/kc_skeleton_loader.dart';

import '../../providers/reports_providers.dart';
import '../../widgets/report_date_filter.dart';
import '../../widgets/report_table.dart';
import '../../widgets/report_error_state.dart';

class AuditReportsPage extends ConsumerStatefulWidget {
  const AuditReportsPage({super.key});

  @override
  ConsumerState<AuditReportsPage> createState() => _AuditReportsPageState();
}

class _AuditReportsPageState extends ConsumerState<AuditReportsPage> {
  String _selectedModule = 'ALL';

  @override
  Widget build(BuildContext context) {
    final activityAsync = ref.watch(unifiedActivityFeedProvider);
    final scheme = Theme.of(context).colorScheme;

    const modules = ['ALL', 'CUSTOMER', 'KYC', 'INVENTORY', 'LOAN', 'PAYMENT', 'ACCOUNTING'];

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
                    Text('Unified System Audit Trail Search', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text('Immutable audit log tracking system actions across Customer, KYC, Inventory, Loans, Payments & Accounting', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          const ReportDateFilter(),
          const SizedBox(height: 20),

          // Module Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Text('Module Filter:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(width: 10),
                for (final mod in modules)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilterChip(
                      selected: _selectedModule == mod,
                      label: Text(mod),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: _selectedModule == mod ? FontWeight.w800 : FontWeight.w500,
                        color: _selectedModule == mod ? scheme.onPrimary : scheme.onSurface,
                      ),
                      selectedColor: scheme.primary,
                      onSelected: (selected) {
                        setState(() => _selectedModule = mod);
                      },
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          activityAsync.when(
            loading: () => const KcSkeletonLoader(height: 400),
            error: (err, st) => ReportErrorState(error: err, onRetry: () => ref.invalidate(unifiedActivityFeedProvider)),
            data: (activities) {
              final filtered = _selectedModule == 'ALL'
                  ? activities
                  : activities.where((a) => a.module.toUpperCase() == _selectedModule).toList();

              final rows = filtered.map((a) {
                return {
                  'id': a.id,
                  'timestamp': KcFormatters.dateTime(a.timestamp),
                  'module': a.module,
                  'actor': a.actor,
                  'action': a.action,
                  'recordId': a.recordId,
                  'description': a.description,
                };
              }).toList();

              return ReportTable(
                title: 'Unified Audit Log Search Report',
                columns: const [
                  ReportColumnConfig(key: 'timestamp', label: 'Timestamp'),
                  ReportColumnConfig(key: 'module', label: 'Module'),
                  ReportColumnConfig(key: 'actor', label: 'User / Actor'),
                  ReportColumnConfig(key: 'action', label: 'Action Code'),
                  ReportColumnConfig(key: 'recordId', label: 'Record ID'),
                  ReportColumnConfig(key: 'description', label: 'Audit Trail Description'),
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
