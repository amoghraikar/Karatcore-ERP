import 'package:flutter/material.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/feedback/kc_toast.dart';
import '../../loans/models/loan_model.dart';

class CustomerDigitalReceiptDialog extends StatelessWidget {
  const CustomerDigitalReceiptDialog({
    super.key,
    required this.payment,
    required this.customerName,
  });

  final LoanPaymentModel payment;
  final String customerName;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: EdgeInsets.zero,
      content: SingleChildScrollView(
        child: Container(
          width: 480,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C3AED),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('KARATCORE ERP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10)),
                      ),
                      const SizedBox(height: 4),
                      const Text('Verma Jewellery & Gold Loan', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                      const Text('M.G. Road Branch, Mumbai • BIS Reg: BIS-MH-4002', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF059669).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Receipt Number:', style: Theme.of(context).textTheme.bodySmall),
                  Text('#${payment.receiptNumber}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Customer Name:', style: Theme.of(context).textTheme.bodySmall),
                  Text(customerName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Payment Date:', style: Theme.of(context).textTheme.bodySmall),
                  Text(KcFormatters.dateTime(payment.paymentDate), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Associated Loan:', style: Theme.of(context).textTheme.bodySmall),
                  Text('Loan #${payment.loanId}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF2563EB))),
                ],
              ),
              const SizedBox(height: 16),

              // Amount Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF059669)),
                ),
                child: Column(
                  children: [
                    const Text('Total Amount Paid', style: TextStyle(fontSize: 12, color: Color(0xFF064E3B), fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(
                      KcFormatters.currency(payment.amount),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF064E3B)),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Principal: ${KcFormatters.currency(payment.principalComponent)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF064E3B))),
                        const SizedBox(width: 16),
                        Text('Interest: ${KcFormatters.currency(payment.interestComponent)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF064E3B))),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Payment Method:', style: Theme.of(context).textTheme.bodySmall),
                  Text(payment.method.label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recorded By Counter:', style: Theme.of(context).textTheme.bodySmall),
                  Text(payment.recordedBy, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        OutlinedButton.icon(
          onPressed: () {
            KcToast.info(context, 'Receipt PDF generated for #${payment.receiptNumber}.', title: 'Print / Download');
          },
          icon: const Icon(Icons.print_rounded, size: 16),
          label: const Text('Print / Download'),
        ),
      ],
    );
  }
}
