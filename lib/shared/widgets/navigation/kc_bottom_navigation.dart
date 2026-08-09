import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/routes.dart';
import '../../../features/auth/providers/permission_provider.dart';

class KcBottomNavigation extends ConsumerWidget {
  const KcBottomNavigation({super.key, required this.currentPath});
  final String currentPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRole = ref.watch(currentRoleProvider);

    final mobileItems = AppRoutes.allNavItems.where((i) => currentRole.canAccessRoute(i.path)).take(5).toList();

    final selectedIndex = mobileItems.indexWhere((i) => currentPath.startsWith(i.path));

    return NavigationBar(
      selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
      onDestinationSelected: (idx) {
        if (idx >= 0 && idx < mobileItems.length) {
          context.go(mobileItems[idx].path);
        }
      },
      destinations: [
        for (final item in mobileItems)
          NavigationDestination(
            icon: Icon(item.icon),
            selectedIcon: Icon(item.selectedIcon),
            label: item.label,
          ),
      ],
    );
  }
}
