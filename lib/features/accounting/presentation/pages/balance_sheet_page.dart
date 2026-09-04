import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/feedback/kc_skeleton_loader.dart';
import '../../../../shared/widgets/feedback/kc_status_badge.dart';

import '../../providers/accounting_providers.dart';

class BalanceSheetPage extends ConsumerWidget {
  const BalanceSheetPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bsAsync = ref.watch(balanceSheetProvider);

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
              Text('Balance Sheet Statement', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 20),

          bsAsync.when(
            loading: () => const KcSkeletonLoader(height: 400),
            error: (err, st) => Text('Error: $err'),
            data: (bs) {
              return KcCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('STATEMENT OF FINANCIAL POSITION', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                        KcStatusBadge(
                          label: bs.isBalanced ? 'Balanced Equation' : 'Unbalanced Warning',
                          statusColor: bs.isBalanced ? const Color(0xFF059669) : const Color(0xFFDC2626),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    Text('ASSETS', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: const Color(0xFF2563EB))),
                    const SizedBox(height: 12),
                    _buildRow('Cash in Vault', KcFormatters.inr(850000.0)),
                    _buildRow('Bank Operating Accounts', KcFormatters.inr(6050000.0)),
                    _buildRow('Inventory — Gold & Silver Bullion', KcFormatters.inr(21550000.0)),
                    _buildRow('Loans Receivable — Gold Pledges', KcFormatters.inr(14250000.0)),
                    _buildRow('Accrued Interest & Other Receivables', KcFormatters.inr(860000.0)),
                    const Divider(height: 20),
                    _buildRow('TOTAL ASSETS', KcFormatters.inr(bs.totalAssets), isBold: true, fontSize: 16),
                    const SizedBox(height: 24),

                    Text('LIABILITIES', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: const Color(0xFFD97706))),
                    const SizedBox(height: 12),
                    _buildRow('Customer Security Deposits', KcFormatters.inr(950000.0)),
                    _buildRow('Trade Payables — Bullion Wholesalers', KcFormatters.inr(2100000.0)),
                    _buildRow('Statutory & Tax Liabilities', KcFormatters.inr(310000.0)),
                    const Divider(height: 20),
                    _buildRow('TOTAL LIABILITIES', KcFormatters.inr(bs.totalLiabilities), isBold: true, fontSize: 16),
                    const SizedBox(height: 24),

                    Text('EQUITY', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: const Color(0xFF7C3AED))),
                    const SizedBox(height: 12),
                    _buildRow('Owner Capital', KcFormatters.inr(30000000.0)),
                    _buildRow('Retained Earnings', KcFormatters.inr(10250000.0)),
                    const Divider(height: 20),
                    _buildRow('TOTAL EQUITY', KcFormatters.inr(bs.totalEquity), isBold: true, fontSize: 16),
                    const Divider(height: 28, thickness: 2),

                    Builder(
                      builder: (context) {
                        final isDark = Theme.of(context).brightness == Brightness.dark;
                        final isBalanced = bs.isBalanced;
                        final bgColor = isBalanced
                            ? (isDark ? const Color(0xFF064E3B).withValues(alpha: 0.25) : const Color(0xFFECFDF5))
                            : (isDark ? const Color(0xFF7F1D1D).withValues(alpha: 0.25) : const Color(0xFFFEF2F2));
                        final labelColor = isDark ? Colors.white : const Color(0xFF0F172A);
                        final valColor = isBalanced
                            ? (isDark ? const Color(0xFF34D399) : const Color(0xFF059669))
                            : (isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626));
                        final borderColor = isBalanced
                            ? (isDark ? const Color(0xFF059669).withValues(alpha: 0.5) : const Color(0xFF10B981))
                            : (isDark ? const Color(0xFFDC2626).withValues(alpha: 0.5) : const Color(0xFFEF4444));

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: borderColor),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('TOTAL LIABILITIES & EQUITY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: labelColor)),
                              Text(KcFormatters.inr(bs.totalLiabilities + bs.totalEquity), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: valColor)),
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

  Widget _buildRow(String title, String val, {bool isBold = false, double fontSize = 13}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 13)),
          Text(val, style: TextStyle(fontWeight: isBold ? FontWeight.w900 : FontWeight.w700, fontSize: fontSize)),
        ],
      ),
    );
  }
}
