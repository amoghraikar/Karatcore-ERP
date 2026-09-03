import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

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

    final name = user?.name ?? 'Store Owner';
    final initials = name
        .split(' ')
        .take(2)
        .map((e) => e.isNotEmpty ? e[0] : '')
        .join()
        .toUpperCase();

    final bgColor = isDark ? KcColors.surfaceDark : KcColors.surfaceLight;
    final borderColor = isDark ? KcColors.borderDark : KcColors.borderLight;
    final headerTextColor = isDark ? KcColors.textMutedDark : KcColors.textSecondaryLight;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: isCollapsed ? 72 : 250,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          right: BorderSide(color: borderColor, width: 1.0),
        ),
      ),
      child: Column(
        children: [
          // Logo Header Area
          Padding(
            padding: isCollapsed
                ? const EdgeInsets.symmetric(vertical: 20)
                : const EdgeInsets.fromLTRB(20, 22, 14, 18),
            child: isCollapsed
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const KcBrandMark(
                        showWordmark: false,
                        size: 32,
                      ),
                      const SizedBox(height: 12),
                      if (onToggleCollapse != null)
                        IconButton(
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          padding: EdgeInsets.zero,
                          icon: Icon(Icons.chevron_right_rounded, size: 20, color: isDark ? KcColors.textSecondaryDark : KcColors.textSecondaryLight),
                          onPressed: onToggleCollapse,
                          tooltip: 'Expand navigation',
                        ),
                    ],
                  )
                : Row(
                    children: [
                      const KcBrandMark(
                        showWordmark: true,
                        subtitle: 'JEWELLERY ERP',
                      ),
                      const Spacer(),
                      if (onToggleCollapse != null)
                        IconButton(
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          icon: Icon(Icons.chevron_left_rounded, size: 20, color: isDark ? KcColors.textMutedDark : KcColors.textMutedLight),
                          onPressed: onToggleCollapse,
                          tooltip: 'Collapse navigation',
                        ),
                    ],
                  ),
          ),
          Divider(height: 1, color: borderColor),
          // Navigation Items List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
              children: [
                for (final nav in AppRoutes.navigationSections) ...[
                  if (nav.items.any((i) => ownerAuth.canAccessOwnerArea(user, i.path))) ...[
                    if (!isCollapsed && nav.sectionHeader != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 18, 14, 8),
                        child: Text(
                          nav.sectionHeader!.toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            color: headerTextColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ),
                    for (final item in nav.items)
                      if (ownerAuth.canAccessOwnerArea(user, item.path))
                        _SidebarTile(
                          item: item,
                          selected: currentPath == item.path || (item.path != '/' && currentPath.startsWith('${item.path}/')),
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
          Divider(height: 1, color: borderColor),
          // Minimal Owner Profile Footnote
          Padding(
            padding: const EdgeInsets.all(12),
            child: isCollapsed
                ? Center(child: KcAvatar(initials: initials, size: 36))
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0x0AFFFFFF) : const Color(0x08111214),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        KcAvatar(initials: initials, size: 32),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                name,
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: isDark ? KcColors.textPrimaryDark : KcColors.textPrimaryLight,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: const BoxDecoration(
                                      color: KcColors.goldAccent,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      'STORE OWNER',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: isDark ? KcColors.textSecondaryDark : KcColors.textSecondaryLight,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 9,
                                        letterSpacing: 0.8,
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

class _SidebarTile extends StatelessWidget {
  const _SidebarTile({
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeBg = isDark ? const Color(0x1AFFFFFF) : const Color(0x0A111214);
    final activeText = isDark ? KcColors.textPrimaryDark : KcColors.textPrimaryLight;
    final inactiveText = isDark ? KcColors.textSecondaryDark : KcColors.textSecondaryLight;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: selected ? activeBg : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                // Minimal Gold Active Line Indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 3,
                  height: 16,
                  decoration: BoxDecoration(
                    color: selected ? KcColors.goldAccent : Colors.transparent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: selected ? 8 : 4),
                Icon(
                  selected ? item.selectedIcon : item.icon,
                  size: 18,
                  color: selected ? activeText : inactiveText,
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.label,
                      style: GoogleFonts.plusJakartaSans(
                        color: selected ? activeText : inactiveText,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 13,
                        letterSpacing: -0.1,
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
