import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/color_tokens.dart';
import '../../../shared/widgets/cards/kc_card.dart';
import '../providers/dashboard_provider.dart';

class TodayTasksWidget extends ConsumerWidget {
  const TodayTasksWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(dashboardTasksProvider);
    final scheme = Theme.of(context).colorScheme;

    return KcCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Today's Vault Tasks",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const Spacer(),
              Text(
                '${tasks.where((t) => t.completed).length}/${tasks.length} Completed',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final task in tasks)
            CheckboxListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              activeColor: KcColors.pitchBlack,
              title: Text(
                task.title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      decoration: task.completed ? TextDecoration.lineThrough : null,
                      fontWeight: task.completed ? FontWeight.normal : FontWeight.w600,
                      color: task.completed ? scheme.onSurfaceVariant : scheme.onSurface,
                    ),
              ),
              subtitle: Text(
                task.subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
              value: task.completed,
              onChanged: (_) {
                ref.read(dashboardTasksProvider.notifier).toggleTask(task.id);
              },
            ),
        ],
      ),
    );
  }
}
