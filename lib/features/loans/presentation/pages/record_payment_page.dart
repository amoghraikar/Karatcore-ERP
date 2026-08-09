import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/buttons/kc_outlined_button.dart';
import '../../../../shared/widgets/buttons/kc_primary_button.dart';
import '../../../../shared/widgets/cards/kc_card.dart';

import '../../../../shared/widgets/inputs/kc_text_field.dart';
import '../../models/loan_model.dart';
import '../../providers/loan_providers.dart';
import '../../widgets/receipt_preview_dialog.dart';

class RecordPaymentPage extends ConsumerStatefulWidget {
  const RecordPaymentPage({super.key, this.id});

  final String? id;

  @override
  ConsumerState<RecordPaymentPage> createState() => _RecordPaymentPageState();
}

class _RecordPaymentPageState extends ConsumerState<RecordPaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController(text: '5000.00');
  final _notesController = TextEditingController(text: 'Regular interest and partial principal repayment.');

  DisbursementMethod _method = DisbursementMethod.upi;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _getTargetId() {
    if (widget.id != null && widget.id!.isNotEmpty) return widget.id!;
    final path = GoRouterState.of(context).uri.path;
    final parts = path.split('/');
    if (parts.length > 2 && parts[2].isNotEmpty) {
      return parts[2];
    }
    return 'KC-LN-9481';
  }

  @override
  Widget build(BuildContext context) {
    final loanId = _getTargetId();
    final loanAsync = ref.watch(loanDetailProvider(loanId));
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: loanAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Text('Error: $err'),
        data: (loan) {
          if (loan == null) return const Text('Loan Not Found');

          final amount = double.tryParse(_amountController.text) ?? 0.0;
          final calc = ref.watch(loanCalculationServiceProvider);
          final alloc = calc.calculatePaymentAllocation(
            totalPayment: amount,
            outstandingInterest: loan.accruedInterest,
            outstandingPrincipal: loan.outstandingPrincipal,
          );

          return ListView(
            padding: EdgeInsets.all(context.pageGutter),
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => context.go('/loans/${loan.id}'),
                  ),
                  const SizedBox(width: 8),
                  Text('Record Payment — ${loan.id}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 20),

              KcCard(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Customer: ${loan.customerName} (${loan.customerId})', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text('Outstanding Principal: ${KcFormatters.inr(loan.outstandingPrincipal)} • Accrued Interest: ${KcFormatters.inr(loan.accruedInterest)}', style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                      const Divider(height: 24),

                      KcTextField(
                        controller: _amountController,
                        label: 'Payment Amount (₹) *',
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 16),

                      const Text('Payment Method *', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<DisbursementMethod>(
                        initialValue: _method,
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                        onChanged: (val) => setState(() => _method = val!),
                        items: DisbursementMethod.values.map((m) => DropdownMenuItem(value: m, child: Text(m.label))).toList(),
                      ),
                      const SizedBox(height: 16),

                      KcTextField(
                        controller: _notesController,
                        label: 'Payment Notes / Verification Code',
                        maxLines: 2,
                      ),
                      const SizedBox(height: 20),

                      // Allocation Preview
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: scheme.surfaceContainerHighest.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          children: [
                            const Text('PAYMENT ALLOCATION PREVIEW', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey)),
                            const SizedBox(height: 10),
                            _buildRow('Interest Component', KcFormatters.inr(alloc['interestComponent'] ?? 0.0)),
                            _buildRow('Principal Component', KcFormatters.inr(alloc['principalComponent'] ?? 0.0)),
                            const Divider(height: 16),
                            _buildRow('Updated Outstanding Principal', KcFormatters.inr(loan.outstandingPrincipal - (alloc['principalComponent'] ?? 0.0))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          KcOutlinedButton(label: 'Cancel', onPressed: () => context.go('/loans/${loan.id}')),
                          const Spacer(),
                          KcPrimaryButton(
                            label: 'Process & Generate Receipt',
                            icon: Icons.check_circle_rounded,
                            isLoading: _isSubmitting,
                            onPressed: () async {
                              final currentContext = context;
                              setState(() => _isSubmitting = true);
                              await ref.read(loanListProvider.notifier).recordPayment(
                                    loanId: loan.id,
                                    amount: amount,
                                    method: _method,
                                    recordedBy: 'Teller Staff',
                                    notes: _notesController.text.trim(),
                                  );

                              if (!mounted || !currentContext.mounted) return;
                              setState(() => _isSubmitting = false);
                              showReceiptPreviewDialog(
                                context: currentContext,
                                receiptTitle: 'Payment Receipt',
                                receiptNumber: 'KC-RCP-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
                                loan: loan,
                                customerName: loan.customerName,
                                amount: amount,
                                paymentMethod: _method.label,
                                date: DateTime.now(),
                                staffName: 'Teller Staff',
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRow(String title, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13)),
          Text(val, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ),
    );
  }
}
