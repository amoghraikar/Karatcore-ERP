import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/routes.dart';
import 'kc_mobile_app_grid_sheet.dart';

class KcBottomNavigation extends ConsumerWidget {
  const KcBottomNavigation({super.key, required this.currentPath});
  final String currentPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int getSelectedIndex() {
      if (currentPath.startsWith(AppRoutes.customers)) return 1;
      if (currentPath.startsWith(AppRoutes.loans)) return 2;
      if (currentPath.startsWith(AppRoutes.dashboard)) return 0;
      return 0;
    }

    final selectedIndex = getSelectedIndex();

    return NavigationBar(
      height: 64,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      selectedIndex: selectedIndex,
      onDestinationSelected: (idx) {
        if (idx == 0) {
          context.go(AppRoutes.dashboard);
        } else if (idx == 1) {
          context.go(AppRoutes.customers);
        } else if (idx == 2) {
          context.go(AppRoutes.loans);
        } else if (idx == 3) {
          KcMobileAppGridSheet.show(context);
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.people_outline_rounded),
          selectedIcon: Icon(Icons.people_rounded),
          label: 'Customers',
        ),
        NavigationDestination(
          icon: Icon(Icons.account_balance_outlined),
          selectedIcon: Icon(Icons.account_balance_rounded),
          label: 'Loans',
        ),
        NavigationDestination(
          icon: Icon(Icons.grid_view_rounded),
          selectedIcon: Icon(Icons.grid_view_rounded),
          label: 'All Apps',
        ),
      ],
    );
  }
}
