import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/feedback/kc_skeleton_loader.dart';

import '../../providers/accounting_providers.dart';

class CashFlowPage extends ConsumerWidget {
  const CashFlowPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cfAsync = ref.watch(cashFlowProvider);

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
              Text('Cash Flow Statement', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 20),

          cfAsync.when(
            loading: () => const KcSkeletonLoader(height: 400),
            error: (err, st) => Text('Error: $err'),
            data: (cf) {
              final netOperating = cf['netOperating'] ?? 0.0;
              final netInvesting = cf['netInvesting'] ?? 0.0;
              final netFinancing = cf['netFinancing'] ?? 0.0;
              final netCashFlow = cf['netCashFlow'] ?? 0.0;

              return KcCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('OPERATING ACTIVITIES', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: const Color(0xFF059669))),
                    const SizedBox(height: 12),
                    _buildRow('Cash Receipts from Customers & Loan Interest', KcFormatters.inr(cf['operatingIn'] ?? 0.0)),
                    _buildRow('Cash Payments for Operating Expenses', KcFormatters.inr(cf['operatingOut'] ?? 0.0)),
                    const Divider(height: 20),
                    _buildRow('Net Cash Flow from Operating Activities', KcFormatters.inr(netOperating), isBold: true, fontSize: 15),
                    const SizedBox(height: 24),

                    Text('INVESTING ACTIVITIES', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: const Color(0xFF2563EB))),
                    const SizedBox(height: 12),
                    _buildRow('Purchases of Jewellery Bullion Inventory', KcFormatters.inr(cf['investingOut'] ?? 0.0)),
                    const Divider(height: 20),
                    _buildRow('Net Cash Flow from Investing Activities', KcFormatters.inr(netInvesting), isBold: true, fontSize: 15),
                    const SizedBox(height: 24),

                    Text('FINANCING ACTIVITIES', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: const Color(0xFF7C3AED))),
                    const SizedBox(height: 12),
                    _buildRow('Gold Loan Principal Disbursements (Net Outflow)', KcFormatters.inr(cf['financingOut'] ?? 0.0)),
                    const Divider(height: 20),
                    _buildRow('Net Cash Flow from Financing Activities', KcFormatters.inr(netFinancing), isBold: true, fontSize: 15),
                    const Divider(height: 28, thickness: 2),

                    Builder(
                      builder: (context) {
                        final isDark = Theme.of(context).brightness == Brightness.dark;
                        final isPositive = netCashFlow >= 0;
                        final bgColor = isPositive
                            ? (isDark ? const Color(0xFF064E3B).withValues(alpha: 0.25) : const Color(0xFFECFDF5))
                            : (isDark ? const Color(0xFF7F1D1D).withValues(alpha: 0.25) : const Color(0xFFFEF2F2));
                        final labelColor = isDark ? Colors.white : const Color(0xFF0F172A);
                        final valColor = isPositive
                            ? (isDark ? const Color(0xFF34D399) : const Color(0xFF059669))
                            : (isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626));
                        final borderColor = isPositive
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
                              Text('NET INCREASE / DECREASE IN CASH BALANCES', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: labelColor)),
                              Text(KcFormatters.inr(netCashFlow), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: valColor)),
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
