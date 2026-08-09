import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/routes.dart';
import '../../../../shared/widgets/cards/kc_card.dart';

class InventoryLocationsPage extends StatelessWidget {
  const InventoryLocationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(context.pageGutter),
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => context.go(AppRoutes.ornaments),
              ),
              const SizedBox(width: 8),
              Text('Vault Storage Hierarchy', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 20),
          KcCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Branch Vault Hierarchy (Branch → Storage → Locker → Tray)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                const ListTile(
                  leading: Icon(Icons.store_rounded, color: Colors.blue),
                  title: Text('Main Branch (Store 01)', style: TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text('Central Vault Safe • Locker #01 (Main Safe), Locker #02 (Display Vault)'),
                ),
                const Divider(),
                const ListTile(
                  leading: Icon(Icons.store_rounded, color: Colors.blue),
                  title: Text('North Extension Branch', style: TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text('Retail Holding Safe • Locker #03 (Loan Reserve)'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
