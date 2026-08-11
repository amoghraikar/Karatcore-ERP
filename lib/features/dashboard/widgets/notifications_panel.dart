import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/routes.dart';
import '../../../shared/widgets/cards/kc_card.dart';
import '../../notifications/providers/notification_providers.dart';

class NotificationsPanelWidget extends ConsumerWidget {
  const NotificationsPanelWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifsAsync = ref.watch(notificationsNotifierProvider);
    final unreadCount = ref.watch(unreadCountProvider);

    return KcCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Notifications & Vault Alerts',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              TextButton(
                onPressed: () => context.go(AppRoutes.notifications),
                child: Text('View Center ($unreadCount)'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          notifsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, st) => Text('Error: $err'),
            data: (notifs) {
              if (notifs.isEmpty) {
                return const Text('No recent store alerts.');
              }

              return Column(
                children: notifs.take(3).map((n) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () {
                        if (n.isUnread) {
                          ref.read(notificationsNotifierProvider.notifier).markAsRead(n.id);
                        }
                        if (n.actionRoute != null) {
                          context.go(n.actionRoute!);
                        } else {
                          context.go(AppRoutes.notifications);
                        }
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: n.type.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(n.type.icon, size: 18, color: n.type.color),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  n.title,
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: n.isUnread ? FontWeight.w800 : FontWeight.w600,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  n.message,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
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
