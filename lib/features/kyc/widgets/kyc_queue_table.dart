import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/components/kc_avatar.dart';
import '../../../../shared/widgets/buttons/kc_outlined_button.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/feedback/kc_status_badge.dart';

import '../../auth/providers/permission_provider.dart';
import '../models/kyc_model.dart';
import '../providers/kyc_permissions.dart';
import 'kyc_document_preview_dialog.dart';
import 'kyc_status_chip.dart';

class KycQueueTable extends ConsumerWidget {
  const KycQueueTable({
    super.key,
    required this.records,
  });

  final List<KycRecordModel> records;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final role = ref.watch(currentRoleProvider);

    if (!context.isDesktop) {
      return Column(
        children: records.map((r) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: KcCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      KcAvatar(initials: r.customerName.substring(0, 2), size: 40),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.customerName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                            const SizedBox(height: 2),
                            Text('${r.customerId} • ${r.customerMobile}', style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                          ],
                        ),
                      ),
                      KycStatusChip(status: r.status),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      KcStatusBadge(label: r.level.label, statusColor: scheme.primary),
                      KcStatusBadge(label: r.riskStatus.label, statusColor: r.riskStatus.color, icon: r.riskStatus.icon),
                      KcStatusBadge(label: r.method.label, statusColor: scheme.onSurfaceVariant),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Submitted: ${KcFormatters.date(r.submittedAt)}', style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                      Wrap(
                        spacing: 8,
                        children: [
                          if (KycPermissions.canReviewKyc(role))
                            KcOutlinedButton(
                              label: 'Review',
                              icon: Icons.rate_review_rounded,
                              onPressed: () => context.go('/kyc/${r.customerId}/review'),
                            )
                          else
                            KcOutlinedButton(
                              label: 'View',
                              icon: Icons.visibility_rounded,
                              onPressed: () => context.go('/kyc/${r.customerId}'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    }

    return KcCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
              border: Border(bottom: BorderSide(color: scheme.outline.withValues(alpha: 0.3))),
            ),
            child: const Row(
              children: [
                Expanded(flex: 3, child: Text('Customer', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
                Expanded(flex: 2, child: Text('KYC Status', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
                Expanded(flex: 2, child: Text('Level & Method', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
                Expanded(flex: 2, child: Text('Risk Assessment', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
                Expanded(flex: 2, child: Text('Submitted', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
                SizedBox(width: 140, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13), textAlign: TextAlign.center)),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: records.length,
            separatorBuilder: (context, index) => Divider(height: 1, color: scheme.outline.withValues(alpha: 0.15)),
            itemBuilder: (context, index) {
              final r = records[index];
              final initials = r.customerName.isNotEmpty ? (r.customerName.split(' ').map((e) => e[0]).take(2).join()) : 'KC';

              return InkWell(
                onTap: () => context.go('/kyc/${r.customerId}'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            KcAvatar(initials: initials, size: 38),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(r.customerName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14), overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 2),
                                  Text('${r.customerId} • ${r.customerMobile}', style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: KycStatusChip(status: r.status),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.level.label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                            const SizedBox(height: 2),
                            Text(r.method.label, style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: KcStatusBadge(label: r.riskStatus.label, statusColor: r.riskStatus.color, icon: r.riskStatus.icon),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(KcFormatters.relativeTime(r.submittedAt), style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
                      ),
                      SizedBox(
                        width: 140,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (r.documents.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.description_outlined, size: 18),
                                tooltip: 'Preview Document',
                                onPressed: () => showKycDocumentPreview(context, r.customerId, r.documents.first),
                              ),
                            IconButton(
                              icon: const Icon(Icons.history_rounded, size: 18),
                              tooltip: 'Audit History',
                              onPressed: () => context.go('/kyc/${r.customerId}/history'),
                            ),
                            IconButton(
                              icon: const Icon(Icons.rate_review_outlined, size: 18),
                              tooltip: 'Review & Verify',
                              onPressed: () => context.go('/kyc/${r.customerId}/review'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
