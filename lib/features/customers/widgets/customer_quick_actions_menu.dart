import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/routes.dart';
import '../models/customer_model.dart';
import '../providers/customer_providers.dart';
import 'customer_status_dialogs.dart';

class CustomerQuickActionsMenu extends ConsumerWidget {
  const CustomerQuickActionsMenu({
    super.key,
    required this.customer,
    this.iconOnly = true,
  });

  final CustomerModel customer;
  final bool iconOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: iconOnly
          ? const Icon(Icons.more_vert_rounded, size: 20)
          : const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.flash_on_rounded, size: 16),
                SizedBox(width: 6),
                Text('Quick Actions'),
                Icon(Icons.arrow_drop_down_rounded, size: 18),
              ],
            ),
      tooltip: 'Customer Actions',
      onSelected: (action) async {
        switch (action) {
          case 'view':
            context.go('/customers/${customer.id}');
            break;
          case 'edit':
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Editing profile for ${customer.fullName}')),
            );
            context.go('/customers/${customer.id}');
            break;
          case 'new_loan':
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Opening Gold Loan flow for ${customer.fullName}')),
            );
            context.go(AppRoutes.loans);
            break;
          case 'add_ornament':
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Opening Ornament Deposit flow for ${customer.fullName}')),
            );
            context.go(AppRoutes.ornaments);
            break;
          case 'record_payment':
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Opening Receipt payment entry for ${customer.fullName}')),
            );
            context.go('/customers/${customer.id}');
            break;
          case 'archive':
            final confirmed = await showCustomerArchiveDialog(context, customer);
            if (confirmed == true) {
              await ref.read(customerListProvider.notifier).archiveCustomer(customer.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Customer ${customer.fullName} archived.')),
                );
              }
            }
            break;
          case 'restore':
            final confirmed = await showCustomerRestoreDialog(context, customer);
            if (confirmed == true) {
              await ref.read(customerListProvider.notifier).restoreCustomer(customer.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Customer ${customer.fullName} restored to active.')),
                );
              }
            }
            break;
          case 'block':
            final confirmed = await showCustomerBlockDialog(context, customer);
            if (confirmed == true) {
              await ref.read(customerListProvider.notifier).updateStatus(customer.id, CustomerStatus.blocked);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Customer ${customer.fullName} is now BLOCKED.')),
                );
              }
            }
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'view',
          child: Row(
            children: [
              Icon(Icons.visibility_outlined, size: 18, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 10),
              const Text('View Full Profile'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(width: 10),
              const Text('Edit Profile'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'new_loan',
          child: Row(
            children: [
              Icon(Icons.add_card_rounded, size: 18, color: Color(0xFF059669)),
              SizedBox(width: 10),
              Text('Create New Gold Loan'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'add_ornament',
          child: Row(
            children: [
              Icon(Icons.diamond_outlined, size: 18, color: Color(0xFFD97706)),
              SizedBox(width: 10),
              Text('Add Ornament'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'record_payment',
          child: Row(
            children: [
              Icon(Icons.receipt_rounded, size: 18, color: Color(0xFF2563EB)),
              SizedBox(width: 10),
              Text('Record Payment'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        if (customer.customerStatus == CustomerStatus.archived)
          const PopupMenuItem(
            value: 'restore',
            child: Row(
              children: [
                Icon(Icons.unarchive_rounded, size: 18, color: Color(0xFF059669)),
                SizedBox(width: 10),
                Text('Restore Customer'),
              ],
            ),
          )
        else ...[
          const PopupMenuItem(
            value: 'archive',
            child: Row(
              children: [
                Icon(Icons.archive_outlined, size: 18, color: Color(0xFF4B5563)),
                SizedBox(width: 10),
                Text('Archive Customer'),
              ],
            ),
          ),
          if (customer.customerStatus != CustomerStatus.blocked)
            const PopupMenuItem(
              value: 'block',
              child: Row(
                children: [
                  Icon(Icons.block_rounded, size: 18, color: Color(0xFFDC2626)),
                  SizedBox(width: 10),
                  Text('Block Customer Account'),
                ],
              ),
            ),
        ],
      ],
    );
  }
}
