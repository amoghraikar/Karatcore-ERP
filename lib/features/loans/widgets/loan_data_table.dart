import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/feedback/kc_status_badge.dart';
import '../models/loan_model.dart';
import 'loan_status_chip.dart';
import 'receipt_preview_dialog.dart';

class LoanDataTable extends ConsumerWidget {
  const LoanDataTable({
    super.key,
    required this.loans,
  });

  final List<LoanModel> loans;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    if (!context.isDesktop) {
      return Column(
        children: loans.map((l) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: KcCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.account_balance_rounded, color: scheme.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.id, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                            const SizedBox(height: 2),
                            Text('${l.customerName} (${l.customerId})', style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                          ],
                        ),
                      ),
                      LoanStatusChip(status: l.status),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      KcStatusBadge(label: 'Principal: ${KcFormatters.inr(l.principalAmount)}', statusColor: scheme.primary),
                      KcStatusBadge(label: 'Out: ${KcFormatters.inr(l.outstandingPrincipal)}', statusColor: const Color(0xFFDC2626)),
                      KcStatusBadge(label: 'Interest: ${l.interestRatePercentage}%', statusColor: scheme.onSurfaceVariant),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Due: ${KcFormatters.date(l.nextDueDate)}', style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                      OutlinedButton(
                        onPressed: () => context.go('/loans/${l.id}'),
                        child: const Text('View Details'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    }

    return KcCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
              border: Border(bottom: BorderSide(color: scheme.outline.withValues(alpha: 0.3))),
            ),
            child: const Row(
              children: [
                Expanded(flex: 2, child: Text('Loan Account', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
                Expanded(flex: 3, child: Text('Customer & KYC', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
                Expanded(flex: 2, child: Text('Principal', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
                Expanded(flex: 2, child: Text('Outstanding', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
                Expanded(flex: 2, child: Text('Interest Due', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
                Expanded(flex: 2, child: Text('Status & Risk', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
                Expanded(flex: 2, child: Text('Next Due', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
                SizedBox(width: 140, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13), textAlign: TextAlign.center)),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: loans.length,
            separatorBuilder: (context, index) => Divider(height: 1, color: scheme.outline.withValues(alpha: 0.15)),
            itemBuilder: (context, index) {
              final l = loans[index];

              return InkWell(
                onTap: () => context.go('/loans/${l.id}'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.id, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                            const SizedBox(height: 2),
                            Text('Pledge: ${l.pledgeId}', style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.customerName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13), overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text('${l.customerId} • ', style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant), overflow: TextOverflow.ellipsis),
                                ),
                                KcStatusBadge(
                                  label: l.customerKycStatus,
                                  statusColor: l.customerKycStatus == 'Verified' ? const Color(0xFF059669) : const Color(0xFFD97706),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(KcFormatters.inr(l.principalAmount), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                            const SizedBox(height: 2),
                            Text('${l.interestRatePercentage}% p.a.', style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(KcFormatters.inr(l.outstandingPrincipal), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFFDC2626))),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(KcFormatters.inr(l.accruedInterest), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFFD97706))),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LoanStatusChip(status: l.status),
                            const SizedBox(height: 4),
                            LoanRiskChip(risk: l.riskStatus),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(KcFormatters.date(l.nextDueDate), style: const TextStyle(fontSize: 12)),
                      ),
                      SizedBox(
                        width: 140,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.receipt_long_rounded, size: 18),
                              tooltip: 'View Receipt',
                              onPressed: () {
                                showReceiptPreviewDialog(
                                  context: context,
                                  receiptTitle: 'Pledge & Sanction Receipt',
                                  receiptNumber: 'KC-RCP-${l.id.replaceAll('KC-LN-', '')}',
                                  loan: l,
                                  customerName: l.customerName,
                                  amount: l.principalAmount,
                                  paymentMethod: l.disbursementMethod.label,
                                  date: l.pledgeDate,
                                  staffName: l.loanOfficer,
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right_rounded, size: 20),
                              tooltip: 'View Details',
                              onPressed: () => context.go('/loans/${l.id}'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
