import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/feedback/customer_access_restricted_page.dart';
import '../../providers/customer_portal_providers.dart';

class CustomerLoanDetailPage extends ConsumerWidget {
  const CustomerLoanDetailPage({super.key, required this.loanId});

  final String loanId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loanAsync = ref.watch(customerLoanDetailProvider(loanId));
    final scheme = Theme.of(context).colorScheme;

    return loanAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, st) => CustomerAccessRestrictedPage(
        message: err.toString().replaceAll('Exception: ', ''),
      ),
      data: (loan) {
        final totalOutstanding = loan.principalAmount + loan.accruedInterest;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.go('/customer/loans'),
            ),
            title: Text('Loan Contract #${loan.id}'),
          ),
          body: ListView(
            padding: EdgeInsets.all(context.pageGutter),
            children: [
              // Contract Status Header Card
              KcCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Loan Contract #${loan.id}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
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
                              Text('Total Outstanding', style: Theme.of(context).textTheme.bodySmall),
                              Text(KcFormatters.currency(totalOutstanding), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFFD97706))),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Next Due Date', style: Theme.of(context).textTheme.bodySmall),
                              Text(KcFormatters.date(loan.nextDueDate), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF2563EB))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Financial Details Breakdown
              KcCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Financial Summary', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 14),
                    _detailRow('Pledge Disbursed Date', KcFormatters.date(loan.pledgeDate)),
                    const Divider(),
                    _detailRow('Contract Maturity Date', KcFormatters.date(loan.maturityDate)),
                    const Divider(),
                    _detailRow('Disbursed Principal', KcFormatters.currency(loan.principalAmount)),
                    const Divider(),
                    _detailRow('Annual Interest Rate', '${loan.interestRatePercentage}% p.a.'),
                    const Divider(),
                    _detailRow('Accrued Interest', KcFormatters.currency(loan.accruedInterest)),
                    const Divider(),
                    _detailRow('Processing Fee', KcFormatters.currency(loan.processingFee)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Pledged Ornaments Collateral View (No internal valuation/costs exposed!)
              KcCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pledged Collateral Ornaments (${loan.collateralOrnaments.length} Items)', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 4),
                    const Text('Gold & Silver ornaments stored securely in vault storage.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 16),
                    ...loan.collateralOrnaments.map((o) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.diamond_outlined, color: Color(0xFF059669), size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${o.name} (${o.metalType.label})', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                                    Text('Purity: ${o.purity.label} • Gross Weight: ${o.weight.grossWeight}g • Net Weight: ${o.weight.netMetalWeight}g', style: const TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Payment History Timeline
              KcCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Payment History', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 12),
                    if (loan.payments.isEmpty)
                      const Text('No repayments recorded on this loan yet.', style: TextStyle(fontSize: 13, color: Colors.grey))
                    else
                      ...loan.payments.map((p) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.receipt_long_rounded, color: Color(0xFF059669)),
                          title: Text('Receipt #${p.receiptNumber} (${KcFormatters.currency(p.amount)})', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                          subtitle: Text('Paid on ${KcFormatters.date(p.paymentDate)} via ${p.method.label}'),
                        );
                      }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ),
    );
  }
}
