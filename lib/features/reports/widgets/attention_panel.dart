import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/feedback/kc_skeleton_loader.dart';

import '../models/reports_model.dart';
import '../providers/reports_providers.dart';
import 'report_error_state.dart';

class AttentionPanel extends ConsumerWidget {
  const AttentionPanel({super.key});

  String _getLocalizedTitle(BuildContext context, AttentionIndicatorItem item) {
    switch (item.id) {
      case 'ATTN-01':
        return context.tr('overdue_gold_loans');
      case 'ATTN-02':
        return context.tr('pending_kyc_records');
      case 'ATTN-03':
        return context.tr('loans_awaiting_approval');
      case 'ATTN-04':
        return context.tr('ornaments_requiring_attention');
      case 'ATTN-05':
        return context.tr('overdue_receivables');
      case 'ATTN-06':
        return context.tr('high_risk_customers');
      default:
        return item.title;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attentionAsync = ref.watch(attentionItemsProvider);
    final scheme = Theme.of(context).colorScheme;

    return KcCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.notifications_active_rounded, color: Color(0xFFDC2626), size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('attention_required'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.tr('attention_required_desc'),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          attentionAsync.when(
            loading: () => const KcSkeletonLoader(height: 150),
            error: (err, st) => ReportErrorState(error: err, onRetry: () => ref.invalidate(attentionItemsProvider)),
            data: (items) {
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 320,
                  mainAxisExtent: 90,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];

                  return InkWell(
                    onTap: () => context.go(item.route),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: scheme.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: item.statusColor.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: item.statusColor.withValues(alpha: 0.12),
                            child: Icon(item.icon, color: item.statusColor, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _getLocalizedTitle(context, item),
                                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: item.statusColor,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '${item.count}',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.description,
                                  style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
