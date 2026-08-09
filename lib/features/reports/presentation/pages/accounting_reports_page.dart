import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/routes.dart';
import '../../../../shared/widgets/cards/kc_card.dart';

import '../../widgets/report_date_filter.dart';

class AccountingReportsPage extends ConsumerWidget {
  const AccountingReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(context.pageGutter),
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => context.go(AppRoutes.reports),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Accounting & Bookkeeping Reports Integration', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text('Direct integration to authoritative double-entry accounting ledgers & statements', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          const ReportDateFilter(),
          const SizedBox(height: 20),

          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 900 ? 3 : 1,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2.5,
            children: [
              _buildCard(context, 'Trial Balance Report', 'Verify debit and credit balance equality', Icons.scale_rounded, const Color(0xFF059669), () => context.go('/accounting/trial-balance')),
              _buildCard(context, 'Profit & Loss Statement', 'Revenue, operating expenses & net profit', Icons.trending_up_rounded, const Color(0xFF2563EB), () => context.go('/accounting/profit-loss')),
              _buildCard(context, 'Balance Sheet Statement', 'Assets, liabilities & equity balance equation', Icons.account_balance_rounded, const Color(0xFF7C3AED), () => context.go('/accounting/balance-sheet')),
              _buildCard(context, 'Cash Flow Statement', 'Operating, investing & financing cash movements', Icons.sync_alt_rounded, const Color(0xFFD97706), () => context.go('/accounting/cash-flow')),
              _buildCard(context, 'General Ledger Explorer', 'Account selector with full transaction history', Icons.history_rounded, const Color(0xFF0284C7), () => context.go('/accounting/ledger')),
              _buildCard(context, 'Cash Vault Book', 'Vault physical cash deposits & withdrawals', Icons.payments_rounded, const Color(0xFF10B981), () => context.go('/accounting/cash-book')),
              _buildCard(context, 'Bank Accounts Book', 'HDFC & SBI operating account movements', Icons.account_balance_wallet_rounded, const Color(0xFF6366F1), () => context.go('/accounting/bank-book')),
              _buildCard(context, 'Accounts Receivable', 'Customer due balances & loan interest aging', Icons.call_made_rounded, const Color(0xFFEC4899), () => context.go('/accounting/receivables')),
              _buildCard(context, 'Accounts Payable', 'Vendor & bullion supplier due invoices', Icons.call_received_rounded, const Color(0xFFF59E0B), () => context.go('/accounting/payables')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, String desc, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: KcCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(desc, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14),
          ],
        ),
      ),
    );
  }
}
