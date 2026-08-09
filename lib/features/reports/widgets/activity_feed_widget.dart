import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/feedback/kc_skeleton_loader.dart';

import '../providers/reports_providers.dart';
import 'report_error_state.dart';

class ActivityFeedWidget extends ConsumerWidget {
  const ActivityFeedWidget({super.key});

  Color _getModuleColor(String module) {
    switch (module.toUpperCase()) {
      case 'LOAN':
        return const Color(0xFFD97706);
      case 'PAYMENT':
        return const Color(0xFF059669);
      case 'KYC':
        return const Color(0xFF7C3AED);
      case 'INVENTORY':
        return const Color(0xFF2563EB);
      case 'ACCOUNTING':
        return const Color(0xFF0284C7);
      default:
        return const Color(0xFF4B5563);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityAsync = ref.watch(unifiedActivityFeedProvider);
    final scheme = Theme.of(context).colorScheme;

    return KcCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history_rounded, size: 22),
              const SizedBox(width: 10),
              Text(
                'Unified Business Activity Feed',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              Text('Owner Timeline', style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 16),

          activityAsync.when(
            loading: () => const KcSkeletonLoader(height: 250),
            error: (err, st) => ReportErrorState(error: err, onRetry: () => ref.invalidate(unifiedActivityFeedProvider)),
            data: (activities) {
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activities.length,
                separatorBuilder: (context, index) => Divider(height: 1, color: scheme.outline.withValues(alpha: 0.15)),
                itemBuilder: (context, index) {
                  final act = activities[index];
                  final color = _getModuleColor(act.module);

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                    onTap: () => context.go(act.route),
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundColor: color.withValues(alpha: 0.12),
                      child: Text(
                        act.module.substring(0, 1),
                        style: TextStyle(fontWeight: FontWeight.w900, color: color, fontSize: 13),
                      ),
                    ),
                    title: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                          child: Text(act.module, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 10, color: color)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(act.description, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13), overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                    subtitle: Text('By ${act.actor} • Ref: ${act.recordId} • ${KcFormatters.dateTime(act.timestamp)}', style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
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
