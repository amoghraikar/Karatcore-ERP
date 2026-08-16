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
        color: isDark ? KcColors.obsidian900 : KcColors.white,
        border: Border(
          right: BorderSide(
            color: isDark
                ? KcColors.obsidian800
                : KcColors.slate200,
          ),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: isCollapsed
                ? const EdgeInsets.symmetric(vertical: 16)
                : const EdgeInsets.fromLTRB(16, 18, 12, 18),
            child: isCollapsed
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const KcBrandMark(
                        showWordmark: false,
                        size: 34,
                      ),
                      const SizedBox(height: 10),
                      if (onToggleCollapse != null)
                        IconButton(
                          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.chevron_right_rounded, size: 22, color: KcColors.gold400),
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
                          icon: const Icon(Icons.chevron_left_rounded, size: 22, color: KcColors.slate400),
                          onPressed: onToggleCollapse,
                          tooltip: 'Collapse sidebar',
                        ),
                    ],
                  ),
          ),
          Divider(height: 1, color: isDark ? KcColors.obsidian800 : KcColors.slate200),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              children: [
                for (final nav in AppRoutes.navigationSections) ...[
                  if (nav.items.any((i) => ownerAuth.canAccessOwnerArea(user, i.path))) ...[
                    if (!isCollapsed && nav.sectionHeader != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 18, 12, 8),
                        child: Text(
                          nav.sectionHeader!.toUpperCase(),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: KcColors.gold500.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.4,
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
          Divider(height: 1, color: isDark ? KcColors.obsidian800 : KcColors.slate200),
          Padding(
            padding: const EdgeInsets.all(12),
            child: isCollapsed
                ? Center(child: KcAvatar(initials: initials, size: 38))
                : Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? KcColors.obsidian850 : KcColors.slate100,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: KcColors.gold500.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        KcAvatar(initials: initials, size: 36),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(color: KcColors.emerald500, shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'STORE OWNER',
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                            color: KcColors.gold400,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 10,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: selected
                  ? (isDark ? KcColors.gold500.withValues(alpha: 0.15) : KcColors.gold100)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected
                    ? KcColors.gold500.withValues(alpha: 0.5)
                    : Colors.transparent,
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  selected ? item.selectedIcon : item.icon,
                  size: 19,
                  color: selected
                      ? (isDark ? KcColors.gold400 : KcColors.gold700)
                      : scheme.onSurfaceVariant,
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: selected
                                ? (isDark ? KcColors.pureWhite : KcColors.slate900)
                                : scheme.onSurfaceVariant,
                            fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (selected)
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: KcColors.gold500,
                        shape: BoxShape.circle,
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
