import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/feedback/kc_empty_state.dart';
import '../../../../shared/widgets/feedback/kc_error_state.dart';
import '../../providers/customer_portal_providers.dart';
import '../../widgets/customer_digital_receipt_dialog.dart';

class CustomerPaymentsPage extends ConsumerWidget {
  const CustomerPaymentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(currentCustomerSessionProvider);
    final paymentsAsync = ref.watch(customerPaymentsProvider);

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(context.pageGutter),
        children: [
          Text(
            'My Payment History',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Digital payment receipts for loan interest and principal repayments',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),

          paymentsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, st) => KcErrorState(message: err.toString()),
            data: (payments) {
              if (payments.isEmpty) {
                return const KcEmptyState(
                  title: 'No Payment History Found',
                  subtitle: 'You do not have any recorded payment receipts on file.',
                  icon: Icons.receipt_long_outlined,
                );
              }

              return Column(
                children: payments.map((payment) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: KcCard(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF059669).withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.receipt_long_rounded, color: Color(0xFF059669), size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Receipt #${payment.receiptNumber}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                                    Text(KcFormatters.currency(payment.amount), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF059669))),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text('Loan #${payment.loanId} • Paid on ${KcFormatters.date(payment.paymentDate)}', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                                const SizedBox(height: 4),
                                Text('Principal: ${KcFormatters.currency(payment.principalComponent)} • Interest: ${KcFormatters.currency(payment.interestComponent)}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => CustomerDigitalReceiptDialog(payment: payment, customerName: session.customerName),
                              );
                            },
                            icon: const Icon(Icons.receipt_rounded, size: 14),
                            label: const Text('Receipt', style: TextStyle(fontSize: 11)),
                          ),
                        ],
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
