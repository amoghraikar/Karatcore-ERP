import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/models/customer_session_model.dart';
import '../../../customers/providers/customer_providers.dart';
import '../../../../core/localization/app_localizations.dart';
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
    final customersListAsync = ref.watch(customerListProvider);
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
          // Live Customer Account Switcher for multi-customer ERP
          customersListAsync.maybeWhen(
            data: (customers) {
              if (customers.isEmpty) {
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    'No Registered Customers',
                    style: TextStyle(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                );
              }
              final validValue = customers.any((c) => c.id == session.customerId) ? session.customerId : customers.first.id;
              return Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: validValue,
                    icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                    style: TextStyle(color: scheme.onSurface, fontWeight: FontWeight.w700, fontSize: 12),
                    items: customers.map((c) {
                      return DropdownMenuItem(
                        value: c.id,
                        child: Text('${c.name} (${c.id})'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        final chosen = customers.firstWhere((c) => c.id == val);
                        ref.read(currentCustomerSessionProvider.notifier).state = CustomerSession(
                          customerId: chosen.id,
                          customerName: chosen.name,
                          mobile: chosen.phone,
                          authenticated: true,
                          sessionCreatedAt: DateTime.now(),
                          lastActiveAt: DateTime.now(),
                        );
                      }
                    },
                  ),
                ),
              );
            },
            orElse: () => const SizedBox.shrink(),
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
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: context.tr('dashboard'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.account_balance_outlined),
            selectedIcon: const Icon(Icons.account_balance_rounded),
            label: context.tr('loans'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.diamond_outlined),
            selectedIcon: const Icon(Icons.diamond_rounded),
            label: context.tr('ornaments'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.payments_outlined),
            selectedIcon: const Icon(Icons.payments_rounded),
            label: context.tr('payments'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.folder_open_outlined),
            selectedIcon: const Icon(Icons.folder_rounded),
            label: context.tr('quality_certificates'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.notifications_outlined),
            selectedIcon: const Icon(Icons.notifications_rounded),
            label: context.tr('notifications'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline_rounded),
            selectedIcon: const Icon(Icons.person_rounded),
            label: context.tr('profile'),
          ),
        ],
      ),
    );
  }
}
