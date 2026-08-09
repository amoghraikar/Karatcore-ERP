import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/feedback/kc_empty_state.dart';
import '../../../../shared/widgets/feedback/kc_error_state.dart';
import '../../../../shared/widgets/feedback/kc_skeleton_loader.dart';

import '../../providers/kyc_providers.dart';
import '../../widgets/kyc_status_chip.dart';

class KycHistoryAuditPage extends ConsumerWidget {
  const KycHistoryAuditPage({super.key, this.customerId});

  final String? customerId;

  String _getTargetCustomerId(BuildContext context) {
    if (customerId != null && customerId!.isNotEmpty) return customerId!;
    final path = GoRouterState.of(context).uri.path;
    final parts = path.split('/');
    if (parts.length > 2 && parts[2].isNotEmpty) {
      return parts[2];
    }
    return 'KC-CUS-000101';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final custId = _getTargetCustomerId(context);
    final recordAsync = ref.watch(kycDetailProvider(custId));
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: recordAsync.when(
        loading: () => ListView(
          padding: EdgeInsets.all(context.pageGutter),
          children: const [KcSkeletonLoader(height: 100), SizedBox(height: 20), KcSkeletonLoader(height: 400)],
        ),
        error: (err, st) => KcErrorState(
          message: 'Unable to load KYC audit logs: ${err.toString()}',
          onRetry: () => ref.invalidate(kycDetailProvider(custId)),
        ),
        data: (record) {
          if (record == null) {
            return KcEmptyState(
              title: 'Record Not Found',
              subtitle: 'No audit records for customer "$custId".',
            );
          }

          return ListView(
            padding: EdgeInsets.all(context.pageGutter),
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => context.go(AppRoutes.kyc),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('KYC Audit Trail & Event History', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 2),
                        Text('Customer: ${record.customerName} (${record.customerId}) • Immutable System Audit Log', style: TextStyle(color: scheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  KycStatusChip(status: record.status),
                ],
              ),
              const SizedBox(height: 20),

              // Compliance Sealed Notice Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified_user_rounded, color: Colors.green, size: 22),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('IMMUTABLE COMPLIANCE AUDIT LOG', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.green)),
                          SizedBox(height: 2),
                          Text('All timestamped actions, consent versions, document replacements, and reviewer decisions are cryptographically logged.', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Audit Logs Table
              KcCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Chronological Audit Events (${record.auditLogs.length})', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 16),
                    if (record.auditLogs.isEmpty)
                      const Text('No audit events logged for this record.')
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: record.auditLogs.length,
                        separatorBuilder: (context, index) => const Divider(height: 20),
                        itemBuilder: (context, index) {
                          final log = record.auditLogs[index];
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: scheme.primaryContainer,
                                child: Icon(Icons.security_rounded, size: 16, color: scheme.primary),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(log.action, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                        const SizedBox(width: 10),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(color: scheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(4)),
                                          child: Text('${log.actorName} (${log.actorRole})', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                                        ),
                                        const Spacer(),
                                        Text(KcFormatters.dateTime(log.timestamp), style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(log.description, style: const TextStyle(fontSize: 13)),
                                    const SizedBox(height: 4),
                                    Text('IP: ${log.ipPlaceholder} • Terminal: ${log.devicePlaceholder}', style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
