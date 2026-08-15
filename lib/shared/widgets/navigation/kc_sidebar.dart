import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/color_tokens.dart';
import '../../../core/routing/routes.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../components/kc_avatar.dart';
import '../../components/kc_brand.dart';

class KcSidebar extends ConsumerWidget {
  const KcSidebar({
    super.key,
    required this.currentPath,
    this.isCollapsed = false,
    this.onToggleCollapse,
  });

  final String currentPath;
  final bool isCollapsed;
  final VoidCallback? onToggleCollapse;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final authState = ref.watch(authStateProvider);
    final ownerAuth = ref.watch(ownerAuthorizationServiceProvider);
    final user = authState.session;

    final name = user?.name ?? 'Demo Owner';
    final initials = name
        .split(' ')
        .take(2)
        .map((e) => e.isNotEmpty ? e[0] : '')
        .join()
        .toUpperCase();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isCollapsed ? 76 : 264,
      decoration: BoxDecoration(
        color: isDark ? KcColors.obsidian950 : KcColors.white,
        border: Border(
          right: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : KcColors.slate200,
          ),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: isCollapsed
                ? const EdgeInsets.symmetric(vertical: 14)
                : const EdgeInsets.fromLTRB(16, 16, 8, 16),
            child: isCollapsed
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const KcBrandMark(
                        showWordmark: false,
                        size: 34,
                      ),
                      const SizedBox(height: 8),
                      if (onToggleCollapse != null)
                        IconButton(
                          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.chevron_right_rounded, size: 22),
                          onPressed: onToggleCollapse,
                          tooltip: 'Expand sidebar',
                        ),
                    ],
                  )
                : Row(
                    children: [
                      const KcBrandMark(
                        showWordmark: true,
                        subtitle: 'ERP Suite',
                      ),
                      const Spacer(),
                      if (onToggleCollapse != null)
                        IconButton(
                          icon: const Icon(Icons.chevron_left_rounded, size: 22),
                          onPressed: onToggleCollapse,
                          tooltip: 'Collapse sidebar',
                        ),
                    ],
                  ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              children: [
                for (final nav in AppRoutes.navigationSections) ...[
                  if (nav.items.any((i) => ownerAuth.canAccessOwnerArea(user, i.path))) ...[
                    if (!isCollapsed && nav.sectionHeader != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 16, 12, 6),
                        child: Text(
                          nav.sectionHeader!.toUpperCase(),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                        ),
                      ),
                    for (final item in nav.items)
                      if (ownerAuth.canAccessOwnerArea(user, item.path))
                        _NavTile(
                          item: item,
                          selected: currentPath.startsWith(item.path),
                          isCollapsed: isCollapsed,
                          onTap: () {
                            if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
                              Navigator.pop(context);
                            }
                            context.go(item.path);
                          },
                        ),
                  ],
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: isCollapsed
                ? Center(child: KcAvatar(initials: initials, size: 36))
                : Row(
                    children: [
                      KcAvatar(initials: initials, size: 38),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: Theme.of(context).textTheme.titleSmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'STORE OWNER • Main Branch',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.item,
    required this.selected,
    required this.isCollapsed,
    required this.onTap,
  });

  final NavItem item;
  final bool selected;
  final bool isCollapsed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: selected
                  ? (isDark ? KcColors.pureWhite : KcColors.pitchBlack)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(
                  selected ? item.selectedIcon : item.icon,
                  size: 18,
                  color: selected
                      ? (isDark ? KcColors.pitchBlack : KcColors.pureWhite)
                      : scheme.onSurfaceVariant,
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: selected
                                ? (isDark ? KcColors.pitchBlack : KcColors.pureWhite)
                                : scheme.onSurface,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
