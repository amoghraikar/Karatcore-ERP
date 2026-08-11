import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/buttons/kc_outlined_button.dart';
import '../../../../shared/widgets/buttons/kc_primary_button.dart';
import '../../../../shared/widgets/dialogs/kc_bottom_sheets.dart';
import '../models/notification_models.dart';
import '../providers/notification_providers.dart';

class NotificationDetailSheet extends ConsumerWidget {
  const NotificationDetailSheet({super.key, required this.notification});

  final NotificationModel notification;

  static void show(BuildContext context, NotificationModel notification) {
    KcBottomSheets.show(
      context: context,
      child: NotificationDetailSheet(notification: notification),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: notification.type.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(notification.type.icon, color: notification.type.color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: notification.category.icon == Icons.security_rounded
                                ? const Color(0xFF7C3AED).withValues(alpha: 0.12)
                                : scheme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            notification.category.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: notification.category.icon == Icons.security_rounded
                                  ? const Color(0xFF7C3AED)
                                  : scheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: notification.priority.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'PRIORITY: ${notification.priority.label.toUpperCase()}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: notification.priority.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Message Container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
            ),
            child: Text(
              notification.message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.4,
                  ),
            ),
          ),
          const SizedBox(height: 16),

          // Metadata Grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Timestamp:', style: Theme.of(context).textTheme.bodySmall),
              Text(
                KcFormatters.dateTime(notification.createdAt),
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('State:', style: Theme.of(context).textTheme.bodySmall),
              Text(
                notification.status.label.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  color: notification.isUnread ? const Color(0xFF2563EB) : Colors.grey,
                ),
              ),
            ],
          ),
          if (notification.relatedEntityId != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Related Entity:', style: Theme.of(context).textTheme.bodySmall),
                Text(
                  '${notification.relatedEntityType ?? "RECORD"} #${notification.relatedEntityId}',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),

          // Actions Row
          Row(
            children: [
              Expanded(
                child: KcOutlinedButton(
                  label: notification.isUnread ? 'Mark Read' : 'Mark Unread',
                  icon: notification.isUnread ? Icons.mark_email_read_rounded : Icons.mark_email_unread_rounded,
                  onPressed: () {
                    if (notification.isUnread) {
                      ref.read(notificationsNotifierProvider.notifier).markAsRead(notification.id);
                    } else {
                      ref.read(notificationsNotifierProvider.notifier).markAsUnread(notification.id);
                    }
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(width: 12),
              if (notification.actionRoute != null)
                Expanded(
                  child: KcPrimaryButton(
                    label: notification.actionLabel ?? 'View Record',
                    icon: Icons.open_in_new_rounded,
                    onPressed: () {
                      Navigator.pop(context);
                      context.go(notification.actionRoute!);
                    },
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
