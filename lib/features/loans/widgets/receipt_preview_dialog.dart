import 'package:flutter/material.dart';
import '../../../../core/utils/file_downloader.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/buttons/kc_outlined_button.dart';
import '../models/loan_model.dart';

class ReceiptPreviewDialog extends StatelessWidget {
  const ReceiptPreviewDialog({
    super.key,
    required this.receiptTitle,
    required this.receiptNumber,
    required this.loan,
    required this.customerName,
    required this.amount,
    required this.paymentMethod,
    required this.date,
    required this.staffName,
    this.collateralSummary = 'Gold/Silver Pledged Ornaments',
  });

  final String receiptTitle; // e.g. Pledge Receipt, Payment Receipt, Settlement Receipt, Release Receipt
  final String receiptNumber; // e.g. KC-RCP-000245
  final LoanModel loan;
  final String customerName;
  final double amount;
  final String paymentMethod;
  final DateTime date;
  final String staffName;
  final String collateralSummary;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(receiptTitle, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text('Receipt #: $receiptNumber', style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                  ],
                ),
                IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.of(context).pop()),
              ],
            ),
            const Divider(height: 24),

            // Thermal Slip Container
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  // Branding Header
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.savings_rounded, color: Color(0xFFD97706), size: 24),
                      SizedBox(width: 8),
                      Text('KARATCORE ERP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.black)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text('Secured Gold & Silver Loan Management', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.black26),
                  const SizedBox(height: 10),

                  _buildReceiptRow('Receipt Date', KcFormatters.dateTime(date)),
                  _buildReceiptRow('Loan Account', loan.id),
                  _buildReceiptRow('Customer Name', customerName),
                  _buildReceiptRow('Customer ID', loan.customerId),
                  _buildReceiptRow('Collateral', collateralSummary),
                  _buildReceiptRow('Payment Method', paymentMethod),
                  const SizedBox(height: 10),
                  const Divider(color: Colors.black26),
                  const SizedBox(height: 10),

                  _buildReceiptRow('Amount Processed', KcFormatters.inr(amount), isBold: true, fontSize: 16),
                  _buildReceiptRow('Outstanding Principal', KcFormatters.inr(loan.outstandingPrincipal)),
                  _buildReceiptRow('Accrued Interest', KcFormatters.inr(loan.accruedInterest)),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.black26),
                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Issued By: $staffName', style: const TextStyle(fontSize: 11, color: Colors.black87)),
                      const Icon(Icons.verified_user_rounded, size: 16, color: Color(0xFF059669)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                KcOutlinedButton(
                  label: 'Print',
                  icon: Icons.print_rounded,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Receipt sent to thermal receipt printer.')));
                  },
                ),
                const SizedBox(width: 8),
                KcOutlinedButton(
                  label: 'Download PDF',
                  icon: Icons.picture_as_pdf_rounded,
                  onPressed: () async {
                    await FileDownloader.downloadReceiptPdf(
                      receiptNumber: receiptNumber,
                      customerName: customerName,
                      loanId: loan.id,
                      amount: amount,
                      paymentMethod: paymentMethod,
                      date: date,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Downloaded $receiptNumber.pdf')));
                    }
                  },
                ),
                const Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: scheme.primary, foregroundColor: scheme.onPrimary),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isBold = false, double fontSize = 12}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.black87)),
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

void showReceiptPreviewDialog({
  required BuildContext context,
  required String receiptTitle,
  required String receiptNumber,
  required LoanModel loan,
  required String customerName,
  required double amount,
  required String paymentMethod,
  required DateTime date,
  required String staffName,
  String collateralSummary = 'Pledged Collateral Asset',
}) {
  showDialog(
    context: context,
    builder: (context) => ReceiptPreviewDialog(
      receiptTitle: receiptTitle,
      receiptNumber: receiptNumber,
      loan: loan,
      customerName: customerName,
      amount: amount,
      paymentMethod: paymentMethod,
      date: date,
      staffName: staffName,
      collateralSummary: collateralSummary,
    ),
  );
}
