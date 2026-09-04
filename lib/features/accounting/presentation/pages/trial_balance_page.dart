import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/feedback/kc_skeleton_loader.dart';
import '../../../../shared/widgets/feedback/kc_status_badge.dart';

import '../../models/accounting_model.dart';
import '../../providers/accounting_providers.dart';

class TrialBalancePage extends ConsumerWidget {
  const TrialBalancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tbAsync = ref.watch(trialBalanceProvider);
    final accountsAsync = ref.watch(chartOfAccountsProvider(null));
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
              Text('Trial Balance Report', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 20),

          tbAsync.when(
            loading: () => const KcSkeletonLoader(height: 100),
            error: (err, st) => Text('Error: $err'),
            data: (tb) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              final isBalanced = tb.isBalanced;
              final bgColor = isBalanced
                  ? (isDark ? const Color(0xFF064E3B).withValues(alpha: 0.25) : const Color(0xFFECFDF5))
                  : (isDark ? const Color(0xFF7F1D1D).withValues(alpha: 0.25) : const Color(0xFFFEF2F2));
              final borderColor = isBalanced
                  ? (isDark ? const Color(0xFF059669).withValues(alpha: 0.5) : const Color(0xFF10B981))
                  : (isDark ? const Color(0xFFDC2626).withValues(alpha: 0.5) : const Color(0xFFEF4444));
              final titleColor = isBalanced
                  ? (isDark ? const Color(0xFF34D399) : const Color(0xFF065F46))
                  : (isDark ? const Color(0xFFF87171) : const Color(0xFF991B1B));
              final subtitleColor = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF374151);

              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    Icon(isBalanced ? Icons.check_circle_rounded : Icons.warning_rounded, color: isBalanced ? const Color(0xFF059669) : const Color(0xFFDC2626), size: 36),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isBalanced ? 'TRIAL BALANCE IS BALANCED' : 'TRIAL BALANCE UNBALANCED WARNING',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: titleColor),
                          ),
                          const SizedBox(height: 2),
                          Text('Total Debit: ${KcFormatters.inr(tb.totalDebit)} • Total Credit: ${KcFormatters.inr(tb.totalCredit)} • Difference: ${KcFormatters.inr(tb.difference)}', style: TextStyle(fontSize: 12, color: subtitleColor)),
                        ],
                      ),
                    ),
                    KcStatusBadge(
                      label: isBalanced ? 'Balanced' : 'Unbalanced',
                      statusColor: isBalanced ? const Color(0xFF059669) : const Color(0xFFDC2626),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Accounts Trial Balance Table
          accountsAsync.when(
            loading: () => const KcSkeletonLoader(height: 400),
            error: (err, st) => Text('Error: $err'),
            data: (accounts) {
              return KcCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
                      child: const Row(
                        children: [
                          Expanded(flex: 2, child: Text('Account ID', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
                          Expanded(flex: 4, child: Text('Account Name & Type', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
                          Expanded(flex: 3, child: Text('Debit Balance (₹)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13), textAlign: TextAlign.right)),
                          Expanded(flex: 3, child: Text('Credit Balance (₹)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13), textAlign: TextAlign.right)),
                        ],
                      ),
                    ),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: accounts.length,
                      separatorBuilder: (context, index) => Divider(height: 1, color: scheme.outline.withValues(alpha: 0.15)),
                      itemBuilder: (context, index) {
                        final a = accounts[index];
                        final isDebitType = a.type == AccountType.asset || a.type == AccountType.expense;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          child: Row(
                            children: [
                              Expanded(flex: 2, child: Text(a.id, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
                              Expanded(flex: 4, child: Text('${a.name} (${a.type.label})', style: const TextStyle(fontSize: 13))),
                              Expanded(flex: 3, child: Text(isDebitType ? KcFormatters.inr(a.currentBalance) : '—', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13), textAlign: TextAlign.right)),
                              Expanded(flex: 3, child: Text(!isDebitType ? KcFormatters.inr(a.currentBalance) : '—', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13), textAlign: TextAlign.right)),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
