import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/color_tokens.dart';
import '../../../core/routing/breadcrumbs.dart';
import '../../../core/routing/routes.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';
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
          Stack(
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
                          Text('System Alerts & Notifications', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 16),
                          const ListTile(
                            leading: Icon(Icons.shield_rounded, color: KcColors.signalOrange),
                            title: Text('Vault Audit Scheduled for 4:00 PM'),
                            subtitle: Text('Inspecting 24K bullion reserve stock'),
                          ),
                          const ListTile(
                            leading: Icon(Icons.monetization_on_rounded, color: KcColors.signalGreen),
                            title: Text('Loan Repayment #902 Cleared'),
                            subtitle: Text('₹4,90,000 credited to store account'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.notifications_outlined),
                tooltip: 'Notifications',
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: KcColors.signalRed,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
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
