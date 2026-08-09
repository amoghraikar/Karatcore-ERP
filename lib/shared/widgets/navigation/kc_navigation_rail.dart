import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/color_tokens.dart';
import '../../../core/routing/routes.dart';
import '../../../features/auth/providers/permission_provider.dart';
import '../../components/kc_brand.dart';

class KcNavigationRail extends ConsumerWidget {
  const KcNavigationRail({super.key, required this.currentPath});
  final String currentPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentRole = ref.watch(currentRoleProvider);

    final flatItems = AppRoutes.allNavItems.where((i) => currentRole.canAccessRoute(i.path)).toList();
    final selectedIndex = flatItems.indexWhere((i) => currentPath.startsWith(i.path));

    return NavigationRail(
      selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
      onDestinationSelected: (idx) {
        if (idx >= 0 && idx < flatItems.length) {
          context.go(flatItems[idx].path);
        }
      },
      backgroundColor: isDark ? KcColors.carbon950 : KcColors.pureWhite,
      leading: const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: KcBrandMark(showWordmark: false, size: 36),
      ),
      indicatorColor: isDark ? KcColors.pureWhite : KcColors.pitchBlack,
      destinations: [
        for (final item in flatItems.take(7))
          NavigationRailDestination(
            icon: Icon(item.icon),
            selectedIcon: Icon(item.selectedIcon, color: isDark ? KcColors.pitchBlack : KcColors.pureWhite),
            label: Text(item.label),
          ),
      ],
    );
  }
}
