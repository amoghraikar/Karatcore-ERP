import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/color_tokens.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/routing/breadcrumbs.dart';
import '../../../core/routing/routes.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/notifications/providers/notification_providers.dart';
import '../../components/kc_avatar.dart';
import '../../components/kc_breadcrumb_bar.dart';
import '../../widgets/dialogs/kc_bottom_sheets.dart';
import '../inputs/kc_search_field.dart';

class KcTopBar extends ConsumerWidget implements PreferredSizeWidget {
  const KcTopBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final breadcrumbs = ref.watch(breadcrumbProvider);
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authStateProvider);
    final user = authState.session;

    final initials = (user?.name ?? 'AR')
        .split(' ')
        .take(2)
        .map((e) => e.isNotEmpty ? e[0] : '')
        .join()
        .toUpperCase();

    if (context.isMobile) {
      return Container(
        height: preferredSize.height,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: scheme.surface,
          border: Border(
            bottom: BorderSide(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : KcColors.slate200,
            ),
          ),
        ),
        child: Row(
          children: [
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu_rounded),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
                tooltip: 'Open Menu',
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'KaratCore',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
              icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
              tooltip: 'Toggle Theme',
            ),
            Consumer(
              builder: (context, ref, _) {
                final unreadCount = ref.watch(unreadCountProvider);
                return Badge(
                  isLabelVisible: unreadCount > 0,
                  label: Text('$unreadCount'),
                  child: IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () => context.go(AppRoutes.notifications),
                    tooltip: 'Store Notifications',
                  ),
                );
              },
            ),
          ],
        ),
      );
    }

    return Container(
      height: preferredSize.height,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : KcColors.slate200,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: KcBreadcrumbBar(items: breadcrumbs),
          ),
          const SizedBox(width: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: const KcSearchField(),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF7C3AED).withValues(alpha: 0.3)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_user_rounded, size: 16, color: Color(0xFF7C3AED)),
                SizedBox(width: 6),
                Text(
                  'Owner / Proprietor',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF7C3AED)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
            icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
            tooltip: 'Toggle Theme',
          ),
          Consumer(
            builder: (context, ref, _) {
              final unreadCount = ref.watch(unreadCountProvider);
              final urgentCount = ref.watch(urgentAlertsCountProvider);
              final notifsAsync = ref.watch(notificationsNotifierProvider);
              final notifs = notifsAsync.valueOrNull ?? [];

              final badgeText = unreadCount > 99 ? '99+' : '$unreadCount';

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    onPressed: () {
                      KcBottomSheets.show(
                        context: context,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Recent Store Alerts ($unreadCount Unread)', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      context.go(AppRoutes.notifications);
                                    },
                                    child: const Text('View All'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (notifs.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24),
                                  child: Center(child: Text('No store notifications available.')),
                                )
                              else
                                ...notifs.take(4).map((n) {
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: n.type.color.withValues(alpha: 0.12),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(n.type.icon, color: n.type.color, size: 18),
                                    ),
                                    title: Text(n.title, style: TextStyle(fontWeight: n.isUnread ? FontWeight.w800 : FontWeight.w600, fontSize: 13)),
                                    subtitle: Text(n.message, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                                    onTap: () {
                                      Navigator.pop(context);
                                      if (n.isUnread) {
                                        ref.read(notificationsNotifierProvider.notifier).markAsRead(n.id);
                                      }
                                      if (n.actionRoute != null) {
                                        context.go(n.actionRoute!);
                                      } else {
                                        context.go(AppRoutes.notifications);
                                      }
                                    },
                                  );
                                }),
                            ],
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.notifications_outlined),
                    tooltip: 'Notifications ($unreadCount Unread)',
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: urgentCount > 0 ? KcColors.signalRed : const Color(0xFF2563EB),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          badgeText,
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            tooltip: 'User Profile Menu',
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  context.go(AppRoutes.profile);
                  break;
                case 'lock':
                  ref.read(authStateProvider.notifier).lockSession();
                  context.go(AppRoutes.locked);
                  break;
                case 'settings':
                  context.go(AppRoutes.settings);
                  break;
                case 'help':
                  context.go(AppRoutes.help);
                  break;
                case 'logout':
                  ref.read(authStateProvider.notifier).logout();
                  context.go(AppRoutes.login);
                  break;
              }
            },
            offset: const Offset(0, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      user?.name ?? 'Arjun Rathore',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Row(
                      children: [
                        Text(
                          user?.role.label ?? 'Owner',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: scheme.primary, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '• ${user?.branch?.name ?? "Main Branch"}',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                    const Divider(),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline_rounded, size: 18),
                    SizedBox(width: 10),
                    Text('My Profile & Security'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'lock',
                child: Row(
                  children: [
                    Icon(Icons.lock_outline_rounded, size: 18),
                    SizedBox(width: 10),
                    Text('Lock Application'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined, size: 18),
                    SizedBox(width: 10),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'help',
                child: Row(
                  children: [
                    Icon(Icons.help_outline_rounded, size: 18),
                    SizedBox(width: 10),
                    Text('Help & Support'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded, size: 18, color: KcColors.signalRed),
                    SizedBox(width: 10),
                    Text('Sign Out', style: TextStyle(color: KcColors.signalRed)),
                  ],
                ),
              ),
            ],
            child: KcAvatar(initials: initials, size: 36),
          ),
        ],
      ),
    );
  }
}
