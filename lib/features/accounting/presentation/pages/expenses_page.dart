import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/buttons/kc_primary_button.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/feedback/kc_empty_state.dart';
import '../../../../shared/widgets/feedback/kc_skeleton_loader.dart';
import '../../../../shared/widgets/feedback/kc_status_badge.dart';
import '../../../../shared/widgets/inputs/kc_text_field.dart';

import '../../models/accounting_model.dart';
import '../../providers/accounting_providers.dart';

class ExpensesPage extends ConsumerStatefulWidget {
  const ExpensesPage({super.key});

  @override
  ConsumerState<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends ConsumerState<ExpensesPage> {
  void _showAddExpenseDialog() {
    final amountController = TextEditingController(text: '45000');
    final descController = TextEditingController(text: 'Monthly store rental payment for July 2026');
    final vendorController = TextEditingController(text: 'Commercial Realty Pvt Ltd');
    final refController = TextEditingController(text: 'INV-RENT-007');
    AccountCategory category = AccountCategory.rent;
    String method = 'HDFC Bank NetBanking';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Record Business Expense Entry', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<AccountCategory>(
              initialValue: category,
              decoration: const InputDecoration(labelText: 'Expense Category *', border: OutlineInputBorder()),
              onChanged: (val) => category = val!,
              items: AccountCategory.values.where((c) => c.type == AccountType.expense).map((c) => DropdownMenuItem(value: c, child: Text(c.label))).toList(),
            ),
            const SizedBox(height: 12),
            KcTextField(controller: amountController, label: 'Expense Amount (₹) *', keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: method,
              decoration: const InputDecoration(labelText: 'Payment Method *', border: OutlineInputBorder()),
              onChanged: (val) => method = val!,
              items: const [
                DropdownMenuItem(value: 'HDFC Bank NetBanking', child: Text('HDFC Bank NetBanking')),
                DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                DropdownMenuItem(value: 'UPI / Card', child: Text('UPI / Card')),
              ],
            ),
            const SizedBox(height: 12),
            KcTextField(controller: vendorController, label: 'Vendor / Payee Name'),
            const SizedBox(height: 12),
            KcTextField(controller: refController, label: 'Vendor Invoice / Ref #'),
            const SizedBox(height: 12),
            KcTextField(controller: descController, label: 'Expense Description'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final amt = double.tryParse(amountController.text) ?? 0.0;
              if (amt <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Expense Amount must be > 0.')));
                return;
              }
              final now = DateTime.now();
              final currentNav = Navigator.of(ctx);

              final expense = ExpenseModel(
                id: 'EXP-${now.millisecondsSinceEpoch.toString().substring(6)}',
                date: now,
                category: category,
                amount: amt,
                paymentMethod: method,
                vendorName: vendorController.text.trim(),
                reference: refController.text.trim(),
                description: descController.text.trim(),
              );

              await ref.read(expenseListProvider.notifier).addExpense(expense);

              if (mounted) currentNav.pop();
            },
            child: const Text('Save Expense Entry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(expenseListProvider);
    final scheme = Theme.of(context).colorScheme;

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
              Text('Expense Management', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
              const Spacer(),
              KcPrimaryButton(label: 'Record Expense', icon: Icons.add_rounded, onPressed: _showAddExpenseDialog),
            ],
          ),
          const SizedBox(height: 20),

          expensesAsync.when(
            loading: () => const KcSkeletonLoader(height: 400),
            error: (err, st) => Text('Error: $err'),
            data: (expenses) {
              if (expenses.isEmpty) {
                return KcEmptyState(
                  title: 'No Expense Entries',
                  subtitle: 'No business operational expenses logged.',
                  action: KcPrimaryButton(label: 'Record Expense', onPressed: _showAddExpenseDialog),
                );
              }

              return KcCard(
                padding: EdgeInsets.zero,
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: expenses.length,
                  separatorBuilder: (context, index) => Divider(height: 1, color: scheme.outline.withValues(alpha: 0.15)),
                  itemBuilder: (context, index) {
                    final exp = expenses[index];

                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFFEF2F2),
                        child: Icon(Icons.trending_down_rounded, color: Color(0xFFDC2626), size: 20),
                      ),
                      title: Text('${exp.category.label} — ${KcFormatters.inr(exp.amount)}', style: const TextStyle(fontWeight: FontWeight.w800)),
                      subtitle: Text('${exp.description}\nVendor: ${exp.vendorName} • Ref: ${exp.reference} • ${KcFormatters.date(exp.date)}'),
                      trailing: KcStatusBadge(label: exp.status, statusColor: const Color(0xFFDC2626)),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
