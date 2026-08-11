import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/feedback/kc_empty_state.dart';
import '../../../../shared/widgets/feedback/kc_error_state.dart';
import '../../providers/customer_portal_providers.dart';

class CustomerLoansPage extends ConsumerWidget {
  const CustomerLoansPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loansAsync = ref.watch(customerLoansProvider);

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(context.pageGutter),
        children: [
          Text(
            'My Pledge Loans',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'View active and past gold pledge contracts, interest rates & repayment schedules',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),

          loansAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, st) => KcErrorState(message: err.toString()),
            data: (loans) {
              if (loans.isEmpty) {
                return const KcEmptyState(
                  title: 'No Pledge Loans Found',
                  subtitle: 'You do not have any active or past pledge contracts on file.',
                  icon: Icons.account_balance_outlined,
                );
              }

              return Column(
                children: loans.map((loan) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: KcCard(
                      padding: const EdgeInsets.all(20),
                      child: InkWell(
                        onTap: () => context.go('/customer/loans/${loan.id}'),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.account_balance_rounded, color: Color(0xFF7C3AED), size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Text('Loan #${loan.id}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: loan.status.color.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    loan.status.label.toUpperCase(),
                                    style: TextStyle(color: loan.status.color, fontWeight: FontWeight.w800, fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Principal Amount', style: Theme.of(context).textTheme.bodySmall),
                                      Text(KcFormatters.currency(loan.principalAmount), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Interest Rate', style: Theme.of(context).textTheme.bodySmall),
                                      Text('${loan.interestRatePercentage}% p.a.', style: const TextStyle(fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Next Due Date', style: Theme.of(context).textTheme.bodySmall),
                                      Text(KcFormatters.date(loan.nextDueDate), style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2563EB))),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Divider(),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Collateral: ${loan.collateralOrnaments.length} Ornaments (${loan.collateralNetWeightGrams}g Net)',
                                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                ),
                                const Row(
                                  children: [
                                    Text('View Contract Details', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF7C3AED))),
                                    SizedBox(width: 4),
                                    Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF7C3AED)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
