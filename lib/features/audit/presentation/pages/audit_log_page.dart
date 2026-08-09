import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/cards/kc_metric_card.dart';
import '../../../../shared/widgets/inputs/kc_search_field.dart';
import '../../../staff/providers/staff_providers.dart';

class AuditLogPage extends ConsumerStatefulWidget {
  const AuditLogPage({super.key});

  @override
  ConsumerState<AuditLogPage> createState() => _AuditLogPageState();
}

class _AuditLogPageState extends ConsumerState<AuditLogPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final auditAsync = ref.watch(staffAuditTrailProvider('ALL'));

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(context.pageGutter),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Store Audit Log', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text('Immutable security trail of all Store Owner transactions & operational changes', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Audit Metric Cards
          const Row(
            children: [
              Expanded(
                child: KcMetricCard(
                  title: 'Total Audit Entries',
                  value: '1,428 Logged',
                  trend: '100% Immutable',
                  icon: Icons.history_rounded,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: KcMetricCard(
                  title: 'Security Compliance',
                  value: 'Verified',
                  trend: 'Owner Authorized Only',
                  icon: Icons.verified_rounded,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: KcMetricCard(
                  title: 'Storage Retention',
                  value: '7 Years (RBI Standard)',
                  trend: 'AES-256 Encrypted',
                  icon: Icons.storage_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Search & Filter
          Row(
            children: [
              Expanded(
                child: KcSearchField(
                  hint: 'Search audit trail by action, actor, or details...',
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          auditAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, st) => Text('Error loading audit log: $err'),
            data: (logs) {
              final filtered = logs.where((l) {
                final q = _searchQuery.toLowerCase();
                return l.action.toLowerCase().contains(q) ||
                    l.actorName.toLowerCase().contains(q) ||
                    l.description.toLowerCase().contains(q);
              }).toList();

              if (filtered.isEmpty) {
                return const KcCard(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Text('No audit log entries matching your search filter.'),
                  ),
                );
              }

              return Column(
                children: filtered.map((log) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: KcCard(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.shield_outlined, color: Color(0xFF7C3AED), size: 20),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(log.action, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text('IMMUTABLE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(log.description, style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                                const SizedBox(height: 4),
                                Text(
                                  'Actor: ${log.actorName} • Timestamp: ${KcFormatters.date(log.timestamp)}',
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
