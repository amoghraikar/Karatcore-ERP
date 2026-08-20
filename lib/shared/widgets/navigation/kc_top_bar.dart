import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

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
import 'kc_command_palette.dart';

class KcTopBar extends ConsumerWidget implements PreferredSizeWidget {
  const KcTopBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final breadcrumbs = ref.watch(breadcrumbProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authStateProvider);
    final user = authState.session;

    final name = user?.name ?? 'Amogh';
    final initials = name
        .split(' ')
        .take(2)
        .map((e) => e.isNotEmpty ? e[0] : '')
        .join()
        .toUpperCase();

    final bgColor = isDark ? KcColors.surfaceDark : KcColors.surfaceLight;
    final borderColor = isDark ? KcColors.borderDark : KcColors.borderLight;

    if (context.isMobile) {
      return Container(
        height: preferredSize.height,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border(
            bottom: BorderSide(color: borderColor, width: 1.0),
          ),
        ),
        child: Row(
          children: [
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu_rounded, size: 22),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
                tooltip: 'Open Menu',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                user?.storeName ?? user?.branch?.name ?? 'KaratCore ERP',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: isDark ? KcColors.textPrimaryDark : KcColors.textPrimaryLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.search_rounded, size: 20),
              onPressed: () => KcCommandPalette.show(context),
              tooltip: 'Command Palette (⌘K)',
            ),
            IconButton(
              onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
              icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined, size: 20),
              tooltip: 'Toggle Theme',
            ),
            Consumer(
              builder: (context, ref, _) {
                final unreadCount = ref.watch(unreadCountProvider);
                return Badge(
                  isLabelVisible: unreadCount > 0,
                  label: Text('$unreadCount'),
                  child: IconButton(
                    icon: const Icon(Icons.notifications_outlined, size: 20),
                    onPressed: () => context.go(AppRoutes.notifications),
                    tooltip: 'Notifications',
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          bottom: BorderSide(color: borderColor, width: 1.0),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: KcBreadcrumbBar(items: breadcrumbs),
          ),
          const SizedBox(width: 16),
          // Command Search Palette Trigger Button
          InkWell(
            onTap: () => KcCommandPalette.show(context),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 260,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0x0AFFFFFF) : const Color(0x08111214),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor, width: 1.0),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    size: 16,
                    color: isDark ? KcColors.textMutedDark : KcColors.textMutedLight,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Search customers, loans...',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: isDark ? KcColors.textMutedDark : KcColors.textMutedLight,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0x1FA0A0A0) : const Color(0x0F111214),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '⌘K',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isDark ? KcColors.textSecondaryDark : KcColors.textSecondaryLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Store Security Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: KcColors.successSubdued,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: KcColors.success.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: KcColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'VAULT SECURE',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: KcColors.success,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Theme Switcher
          IconButton(
            onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
            icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined, size: 20),
            tooltip: 'Toggle Theme Mode',
          ),
          // Notification Bell
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
                                  Text(
                                    'Store Alerts ($unreadCount Unread)',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                      color: isDark ? KcColors.textPrimaryDark : KcColors.textPrimaryLight,
                                    ),
                                  ),
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
                                    title: Text(
                                      n.title,
                                      style: TextStyle(
                                        fontWeight: n.isUnread ? FontWeight.w800 : FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                    subtitle: Text(
                                      n.message,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12),
                                    ),
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
                    icon: const Icon(Icons.notifications_outlined, size: 20),
                    tooltip: 'Notifications ($unreadCount Unread)',
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: urgentCount > 0 ? KcColors.danger : KcColors.deepNavy,
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
          // User Profile Menu
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
            offset: const Offset(0, 44),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      user?.name ?? 'Amogh',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          user?.role.label ?? 'Owner',
                          style: GoogleFonts.plusJakartaSans(fontSize: 11, color: KcColors.goldAccent, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'OWNER ACCESS',
                          style: GoogleFonts.plusJakartaSans(fontSize: 11, color: isDark ? KcColors.textSecondaryDark : KcColors.textSecondaryLight),
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
                    Icon(Icons.logout_rounded, size: 18, color: KcColors.danger),
                    SizedBox(width: 10),
                    Text('Sign Out', style: TextStyle(color: KcColors.danger)),
                  ],
                ),
              ),
            ],
            child: KcAvatar(initials: initials, size: 34),
          ),
        ],
      ),
    );
  }
}
