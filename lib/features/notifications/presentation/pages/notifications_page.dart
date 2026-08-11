import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/color_tokens.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/buttons/kc_outlined_button.dart';
import '../../../../shared/widgets/buttons/kc_primary_button.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/cards/kc_metric_card.dart';
import '../../../../shared/widgets/feedback/kc_empty_state.dart';
import '../../../../shared/widgets/feedback/kc_error_state.dart';
import '../../../../shared/widgets/feedback/kc_skeleton_loader.dart';
import '../../../../shared/widgets/inputs/kc_search_field.dart';
import '../../models/notification_models.dart';
import '../../providers/notification_providers.dart';
import '../../widgets/notification_detail_sheet.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  final List<String> _tabs = [
    'All',
    'Unread',
    'Important',
    'Loans',
    'Payments',
    'KYC',
    'Security',
    'System',
  ];

  @override
  Widget build(BuildContext context) {
    final notifsAsync = ref.watch(notificationsNotifierProvider);
    final filteredNotifs = ref.watch(filteredNotificationsProvider);
    final unreadCount = ref.watch(unreadCountProvider);
    final urgentCount = ref.watch(urgentAlertsCountProvider);
    final filterState = ref.watch(notificationFilterProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(context.pageGutter),
        children: [
          // Header Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Notification Center',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        if (unreadCount > 0) ...[
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$unreadCount UNREAD',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Store Owner business alerts, loan due dates, customer KYC updates & security logs',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              KcOutlinedButton(
                label: 'Communication Logs',
                icon: Icons.forum_outlined,
                onPressed: () => context.go('/communication'),
              ),
              const SizedBox(width: 8),
              KcOutlinedButton(
                label: 'Settings',
                icon: Icons.settings_outlined,
                onPressed: () => context.go(AppRoutes.settingsNotifications),
              ),
              const SizedBox(width: 8),
              KcPrimaryButton(
                label: 'Mark All Read',
                icon: Icons.done_all_rounded,
                onPressed: unreadCount > 0
                    ? () {
                        ref.read(notificationsNotifierProvider.notifier).markAllAsRead();
                      }
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Metric Summary Cards
          Row(
            children: [
              Expanded(
                child: KcMetricCard(
                  title: 'Unread Notifications',
                  value: '$unreadCount',
                  trend: unreadCount > 0 ? 'Requires attention' : 'All clear',
                  icon: Icons.mark_email_unread_rounded,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: KcMetricCard(
                  title: 'Urgent Alerts',
                  value: '$urgentCount',
                  trend: urgentCount > 0 ? 'Critical priority' : 'No urgent alerts',
                  icon: Icons.warning_amber_rounded,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: KcMetricCard(
                  title: 'System Delivery Status',
                  value: '100% Active',
                  trend: 'In-App & Simulated Channels',
                  icon: Icons.sensors_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Filter Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _tabs.map((tab) {
                final isSelected = filterState.activeTab == tab;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(tab),
                    selected: isSelected,
                    onSelected: (val) {
                      ref.read(notificationFilterProvider.notifier).state =
                          filterState.copyWith(activeTab: tab);
                    },
                    selectedColor: const Color(0xFF7C3AED).withValues(alpha: 0.15),
                    checkmarkColor: const Color(0xFF7C3AED),
                    labelStyle: TextStyle(
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                      color: isSelected ? const Color(0xFF7C3AED) : scheme.onSurface,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Search & Dropdown Filters Row
          Row(
            children: [
              Expanded(
                child: KcSearchField(
                  hint: 'Search notifications by title, loan ID, or message...',
                  onChanged: (val) {
                    ref.read(notificationFilterProvider.notifier).state =
                        filterState.copyWith(searchQuery: val);
                  },
                ),
              ),
              const SizedBox(width: 12),
              DropdownButton<NotificationPriority?>(
                value: filterState.priorityFilter,
                hint: const Text('Priority Filter'),
                underline: const SizedBox(),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Priorities')),
                  ...NotificationPriority.values.map(
                    (p) => DropdownMenuItem(value: p, child: Text(p.label)),
                  ),
                ],
                onChanged: (val) {
                  ref.read(notificationFilterProvider.notifier).state = filterState.copyWith(
                    priorityFilter: val,
                    clearPriority: val == null,
                  );
                },
              ),
              const SizedBox(width: 12),
              DropdownButton<NotificationCategory?>(
                value: filterState.categoryFilter,
                hint: const Text('Category Filter'),
                underline: const SizedBox(),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Categories')),
                  ...NotificationCategory.values.map(
                    (c) => DropdownMenuItem(value: c, child: Text(c.label)),
                  ),
                ],
                onChanged: (val) {
                  ref.read(notificationFilterProvider.notifier).state = filterState.copyWith(
                    categoryFilter: val,
                    clearCategory: val == null,
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Main Notifications Content
          notifsAsync.when(
            loading: () => const KcSkeletonLoader(height: 300),
            error: (err, st) => KcErrorState(
              message: err.toString(),
              onRetry: () => ref.read(notificationsNotifierProvider.notifier).loadNotifications(),
            ),
            data: (_) {
              if (filteredNotifs.isEmpty) {
                return const KcEmptyState(
                  title: 'No Notifications Found',
                  subtitle: 'No notification records match your selected filter criteria or search query.',
                  icon: Icons.notifications_none_rounded,
                );
              }

              // Timeline Grouping
              final todayNotifs = <NotificationModel>[];
              final yesterdayNotifs = <NotificationModel>[];
              final earlierNotifs = <NotificationModel>[];

              final now = DateTime.now();
              for (final n in filteredNotifs) {
                final diffDays = now.difference(n.createdAt).inDays;
                if (diffDays == 0) {
                  todayNotifs.add(n);
                } else if (diffDays == 1) {
                  yesterdayNotifs.add(n);
                } else {
                  earlierNotifs.add(n);
                }
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (todayNotifs.isNotEmpty) ...[
                    _buildSectionHeader(context, 'TODAY'),
                    ...todayNotifs.map((n) => _NotificationTile(notification: n)),
                    const SizedBox(height: 16),
                  ],
                  if (yesterdayNotifs.isNotEmpty) ...[
                    _buildSectionHeader(context, 'YESTERDAY'),
                    ...yesterdayNotifs.map((n) => _NotificationTile(notification: n)),
                    const SizedBox(height: 16),
                  ],
                  if (earlierNotifs.isNotEmpty) ...[
                    _buildSectionHeader(context, 'EARLIER'),
                    ...earlierNotifs.map((n) => _NotificationTile(notification: n)),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  const _NotificationTile({required this.notification});

  final NotificationModel notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: KcCard(
        padding: const EdgeInsets.all(16),
        child: InkWell(
          onTap: () {
            if (notification.isUnread) {
              ref.read(notificationsNotifierProvider.notifier).markAsRead(notification.id);
            }
            if (notification.actionRoute != null) {
              context.go(notification.actionRoute!);
            } else {
              NotificationDetailSheet.show(context, notification);
            }
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: notification.type.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(notification.type.icon, color: notification.type.color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: notification.isUnread ? FontWeight.w800 : FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: notification.priority.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            notification.priority.label.toUpperCase(),
                            style: TextStyle(
                              color: notification.priority.color,
                              fontWeight: FontWeight.w800,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 13,
                        color: notification.isUnread ? scheme.onSurface : scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(notification.category.icon, size: 14, color: scheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          notification.category.label,
                          style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.access_time_rounded, size: 14, color: KcColors.slate400),
                        const SizedBox(width: 4),
                        Text(
                          KcFormatters.dateTime(notification.createdAt),
                          style: const TextStyle(fontSize: 11, color: KcColors.slate400),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (val) {
                  if (val == 'detail') {
                    NotificationDetailSheet.show(context, notification);
                  } else if (val == 'read') {
                    ref.read(notificationsNotifierProvider.notifier).markAsRead(notification.id);
                  } else if (val == 'unread') {
                    ref.read(notificationsNotifierProvider.notifier).markAsUnread(notification.id);
                  } else if (val == 'archive') {
                    ref.read(notificationsNotifierProvider.notifier).archiveNotification(notification.id);
                  } else if (val == 'dismiss') {
                    ref.read(notificationsNotifierProvider.notifier).dismissNotification(notification.id);
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(value: 'detail', child: Text('View Details')),
                  PopupMenuItem(
                    value: notification.isUnread ? 'read' : 'unread',
                    child: Text(notification.isUnread ? 'Mark as Read' : 'Mark as Unread'),
                  ),
                  const PopupMenuItem(value: 'archive', child: Text('Archive')),
                  const PopupMenuItem(value: 'dismiss', child: Text('Dismiss')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
