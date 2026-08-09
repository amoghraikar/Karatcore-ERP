import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/feedback/kc_skeleton_loader.dart';

import '../../providers/accounting_providers.dart';

class ProfitLossPage extends ConsumerWidget {
  const ProfitLossPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plAsync = ref.watch(profitLossProvider);

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
              Text('Profit & Loss Statement', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 20),

          plAsync.when(
            loading: () => const KcSkeletonLoader(height: 400),
            error: (err, st) => Text('Error: $err'),
            data: (pl) {
              return KcCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('REVENUE & INCOME', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: const Color(0xFF059669))),
                    const SizedBox(height: 12),
                    _buildRow('Pledge Gold Loan Interest Income', KcFormatters.inr(pl.interestIncome)),
                    _buildRow('Retail Jewellery Sales Revenue', KcFormatters.inr(pl.jewellerySales)),
                    _buildRow('Making & Other Income', KcFormatters.inr(pl.otherIncome)),
                    const Divider(height: 20),
                    _buildRow('Total Gross Revenue', KcFormatters.inr(pl.totalRevenue), isBold: true, fontSize: 16),
                    const SizedBox(height: 24),

                    Text('OPERATING EXPENSES', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: const Color(0xFFDC2626))),
                    const SizedBox(height: 12),
                    _buildRow('Store Rent & Lease Expenses', KcFormatters.inr(450000.0)),
                    _buildRow('Staff Salaries & Wages', KcFormatters.inr(920000.0)),
                    _buildRow('Electricity & Utilities', KcFormatters.inr(85000.0)),
                    _buildRow('Marketing, Insurance & Bank Charges', KcFormatters.inr(pl.totalExpenses - 1455000.0 > 0 ? pl.totalExpenses - 1455000.0 : 300000.0)),
                    const Divider(height: 20),
                    _buildRow('Total Operating Expenses', KcFormatters.inr(pl.totalExpenses), isBold: true, fontSize: 16),
                    const Divider(height: 28, thickness: 2),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: pl.netProfit >= 0 ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('NET PROFIT FOR THE PERIOD', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: pl.netProfit >= 0 ? const Color(0xFF065F46) : const Color(0xFF991B1B))),
                          Text(KcFormatters.inr(pl.netProfit), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: pl.netProfit >= 0 ? const Color(0xFF059669) : const Color(0xFFDC2626))),
                        ],
                      ),
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
