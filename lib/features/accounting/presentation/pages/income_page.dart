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

class IncomePage extends ConsumerStatefulWidget {
  const IncomePage({super.key});

  @override
  ConsumerState<IncomePage> createState() => _IncomePageState();
}

class _IncomePageState extends ConsumerState<IncomePage> {
  void _showAddIncomeDialog() {
    final amountController = TextEditingController(text: '25000');
    final descController = TextEditingController(text: 'Retail gold bangle sale making charges income');
    final customerController = TextEditingController(text: 'Rahul Kumar Sharma');
    final refController = TextEditingController(text: 'INV-2026-880');
    AccountCategory category = AccountCategory.jewellerySales;
    String method = 'Cash';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Record Revenue Income Entry', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<AccountCategory>(
              initialValue: category,
              decoration: const InputDecoration(labelText: 'Income Category *', border: OutlineInputBorder()),
              onChanged: (val) => category = val!,
              items: AccountCategory.values.where((c) => c.type == AccountType.income).map((c) => DropdownMenuItem(value: c, child: Text(c.label))).toList(),
            ),
            const SizedBox(height: 12),
            KcTextField(controller: amountController, label: 'Income Amount (₹) *', keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: method,
              decoration: const InputDecoration(labelText: 'Payment Method *', border: OutlineInputBorder()),
              onChanged: (val) => method = val!,
              items: const [
                DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                DropdownMenuItem(value: 'UPI / Bank Transfer', child: Text('UPI / Bank Transfer')),
                DropdownMenuItem(value: 'POS Card', child: Text('POS Card')),
              ],
            ),
            const SizedBox(height: 12),
            KcTextField(controller: customerController, label: 'Customer Name / Entity'),
            const SizedBox(height: 12),
            KcTextField(controller: refController, label: 'Reference Bill / Receipt #'),
            const SizedBox(height: 12),
            KcTextField(controller: descController, label: 'Income Description'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final amt = double.tryParse(amountController.text) ?? 0.0;
              if (amt <= 0) return;
              final now = DateTime.now();
              final currentNav = Navigator.of(ctx);

              final income = IncomeModel(
                id: 'INC-${now.millisecondsSinceEpoch.toString().substring(6)}',
                date: now,
                category: category,
                amount: amt,
                paymentMethod: method,
                customerId: 'KC-CUS-000101',
                customerName: customerController.text.trim(),
                reference: refController.text.trim(),
                description: descController.text.trim(),
              );

              await ref.read(incomeListProvider.notifier).addIncome(income);

              if (mounted) currentNav.pop();
            },
            child: const Text('Save Income Entry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final incomeAsync = ref.watch(incomeListProvider);
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
              Text('Income Management', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
              const Spacer(),
              KcPrimaryButton(label: 'Record Income', icon: Icons.add_rounded, onPressed: _showAddIncomeDialog),
            ],
          ),
          const SizedBox(height: 20),

          incomeAsync.when(
            loading: () => const KcSkeletonLoader(height: 400),
            error: (err, st) => Text('Error: $err'),
            data: (incomeList) {
              if (incomeList.isEmpty) {
                return KcEmptyState(
                  title: 'No Income Entries',
                  subtitle: 'No revenue or income entries logged.',
                  action: KcPrimaryButton(label: 'Record Income', onPressed: _showAddIncomeDialog),
                );
              }

              return KcCard(
                padding: EdgeInsets.zero,
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: incomeList.length,
                  separatorBuilder: (context, index) => Divider(height: 1, color: scheme.outline.withValues(alpha: 0.15)),
                  itemBuilder: (context, index) {
                    final inc = incomeList[index];

                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFECFDF5),
                        child: Icon(Icons.trending_up_rounded, color: Color(0xFF059669), size: 20),
                      ),
                      title: Text('${inc.category.label} — ${KcFormatters.inr(inc.amount)}', style: const TextStyle(fontWeight: FontWeight.w800)),
                      subtitle: Text('${inc.description}\nCustomer: ${inc.customerName} • Ref: ${inc.reference} • ${KcFormatters.date(inc.date)}'),
                      trailing: KcStatusBadge(label: inc.status, statusColor: const Color(0xFF059669)),
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
