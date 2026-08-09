import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/buttons/kc_outlined_button.dart';
import '../../../../shared/widgets/buttons/kc_primary_button.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/feedback/kc_empty_state.dart';
import '../../../../shared/widgets/feedback/kc_skeleton_loader.dart';
import '../../../../shared/widgets/inputs/kc_text_field.dart';

import '../../models/accounting_model.dart';
import '../../providers/accounting_providers.dart';

class ChartOfAccountsPage extends ConsumerStatefulWidget {
  const ChartOfAccountsPage({super.key});

  @override
  ConsumerState<ChartOfAccountsPage> createState() => _ChartOfAccountsPageState();
}

class _ChartOfAccountsPageState extends ConsumerState<ChartOfAccountsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddAccountDialog() {
    final nameController = TextEditingController();
    final balanceController = TextEditingController(text: '0.0');
    AccountType selectedType = AccountType.asset;
    AccountCategory selectedCategory = AccountCategory.cash;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Add Chart of Accounts Entry', style: TextStyle(fontWeight: FontWeight.w800)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              KcTextField(controller: nameController, label: 'Account Name *'),
              const SizedBox(height: 12),
              DropdownButtonFormField<AccountType>(
                initialValue: selectedType,
                decoration: const InputDecoration(labelText: 'Account Type *', border: OutlineInputBorder()),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      selectedType = val;
                      selectedCategory = AccountCategory.values.firstWhere((c) => c.type == val);
                    });
                  }
                },
                items: AccountType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label))).toList(),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<AccountCategory>(
                initialValue: selectedCategory,
                decoration: const InputDecoration(labelText: 'Account Category *', border: OutlineInputBorder()),
                onChanged: (val) => setState(() => selectedCategory = val!),
                items: AccountCategory.values.where((c) => c.type == selectedType).map((c) => DropdownMenuItem(value: c, child: Text(c.label))).toList(),
              ),
              const SizedBox(height: 12),
              KcTextField(controller: balanceController, label: 'Opening Balance (₹)', keyboardType: TextInputType.number),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty) return;
                final now = DateTime.now();
                final accId = 'ACC-${now.millisecondsSinceEpoch.toString().substring(7)}';
                final openBal = double.tryParse(balanceController.text) ?? 0.0;

                final newAcc = AccountModel(
                  id: accId,
                  name: nameController.text.trim(),
                  type: selectedType,
                  category: selectedCategory,
                  openingBalance: openBal,
                  currentBalance: openBal,
                  createdAt: now,
                );

                await ref.read(accountingRepositoryProvider).createAccount(newAcc);
                ref.invalidate(chartOfAccountsProvider);
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
              child: const Text('Save Account'),
            ),
          ],
        ),
      ),
    );
  }

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
                onPressed: () => context.go(AppRoutes.accounting),
              ),
              const SizedBox(width: 8),
              Text('Chart of Accounts', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
              const Spacer(),
              KcPrimaryButton(label: 'Add Account', icon: Icons.add_rounded, onPressed: _showAddAccountDialog),
            ],
          ),
          const SizedBox(height: 20),

          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: AccountType.values.map((t) => Tab(text: t.label)).toList(),
          ),
          const SizedBox(height: 16),

          SizedBox(
            height: 600,
            child: TabBarView(
              controller: _tabController,
              children: AccountType.values.map((type) => _buildAccountListForType(type)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountListForType(AccountType type) {
    final accountsAsync = ref.watch(chartOfAccountsProvider(type));

    return accountsAsync.when(
      loading: () => const KcSkeletonLoader(height: 300),
      error: (err, st) => Text('Error: $err'),
      data: (accounts) {
        if (accounts.isEmpty) {
          return KcEmptyState(
            title: 'No ${type.label} Accounts',
            subtitle: 'No accounts registered under ${type.label}.',
            action: KcPrimaryButton(label: 'Add Account', onPressed: _showAddAccountDialog),
          );
        }

        return ListView.builder(
          itemCount: accounts.length,
          itemBuilder: (context, index) {
            final acc = accounts[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: KcCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: type.color.withValues(alpha: 0.15),
                      child: Icon(Icons.account_balance_wallet_rounded, color: type.color, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(acc.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                          const SizedBox(height: 2),
                          Text('${acc.id} • Category: ${acc.category.label}', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(KcFormatters.inr(acc.currentBalance), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                        const SizedBox(height: 2),
                        Text('Opening: ${KcFormatters.inr(acc.openingBalance)}', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      ],
                    ),
                    const SizedBox(width: 16),
                    KcOutlinedButton(
                      label: 'View Ledger',
                      onPressed: () => context.go('/accounting/accounts/${acc.id}'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
