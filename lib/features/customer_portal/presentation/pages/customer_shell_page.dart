import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/models/customer_session_model.dart';
import '../../../../shared/widgets/navigation/language_selector.dart';
import '../../providers/customer_portal_providers.dart';


class CustomerShellPage extends ConsumerWidget {
  const CustomerShellPage({super.key, required this.child});

  final Widget child;

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/customer/loans')) return 1;
    if (location.startsWith('/customer/jewellery')) return 2;
    if (location.startsWith('/customer/payments')) return 3;
    if (location.startsWith('/customer/documents')) return 4;
    if (location.startsWith('/customer/notifications')) return 5;
    if (location.startsWith('/customer/profile')) return 6;
    return 0; // /customer (Home)
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/customer');
        break;
      case 1:
        context.go('/customer/loans');
        break;
      case 2:
        context.go('/customer/jewellery');
        break;
      case 3:
        context.go('/customer/payments');
        break;
      case 4:
        context.go('/customer/documents');
        break;
      case 5:
        context.go('/customer/notifications');
        break;
      case 6:
        context.go('/customer/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(currentCustomerSessionProvider);
    final selectedIndex = _calculateSelectedIndex(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'KARATCORE',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.1),
              ),
            ),
            const SizedBox(width: 8),
            const Text('Customer Portal', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          ],
        ),
        actions: [
          // Customer Account Switcher for testing Data Isolation
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: session.customerId,
                icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                style: TextStyle(color: scheme.onSurface, fontWeight: FontWeight.w700, fontSize: 12),
                items: const [
                  DropdownMenuItem(
                    value: 'KC-CUS-000101',
                    child: Text('Demo: Rahul Sharma (Customer A)'),
                  ),
                  DropdownMenuItem(
                    value: 'CUST-002',
                    child: Text('Demo: Sunita Devi (Customer B)'),
                  ),
                ],
                onChanged: (val) {
                  if (val == 'KC-CUS-000101') {
                    ref.read(currentCustomerSessionProvider.notifier).state = CustomerSession.demoCustomerA;
                  } else if (val == 'CUST-002') {
                    ref.read(currentCustomerSessionProvider.notifier).state = CustomerSession.demoCustomerB;
                  }
                },
              ),
            ),
          ),
          const LanguageSelector(),
          IconButton(
            icon: const Icon(Icons.storefront_outlined),
            tooltip: 'Switch to Owner ERP View',
            onPressed: () => context.go('/dashboard'),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1024),
          child: child,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (idx) => _onItemTapped(idx, context),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_outlined),
            selectedIcon: Icon(Icons.account_balance_rounded),
            label: 'Loans',
          ),
          NavigationDestination(
            icon: Icon(Icons.diamond_outlined),
            selectedIcon: Icon(Icons.diamond_rounded),
            label: 'Jewellery',
          ),
          NavigationDestination(
            icon: Icon(Icons.payments_outlined),
            selectedIcon: Icon(Icons.payments_rounded),
            label: 'Payments',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_open_outlined),
            selectedIcon: Icon(Icons.folder_rounded),
            label: 'Documents',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications_rounded),
            label: 'Alerts',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
