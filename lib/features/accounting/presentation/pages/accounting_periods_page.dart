import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/buttons/kc_outlined_button.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/feedback/kc_skeleton_loader.dart';
import '../../../../shared/widgets/feedback/kc_status_badge.dart';

import '../../models/accounting_model.dart';
import '../../providers/accounting_providers.dart';

class AccountingPeriodsPage extends ConsumerStatefulWidget {
  const AccountingPeriodsPage({super.key});

  @override
  ConsumerState<AccountingPeriodsPage> createState() => _AccountingPeriodsPageState();
}

class _AccountingPeriodsPageState extends ConsumerState<AccountingPeriodsPage> {
  void _showClosePeriodDialog(AccountingPeriodModel period) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Close Accounting Period — ${period.name}', style: const TextStyle(fontWeight: FontWeight.w800)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('WARNING: Closing an accounting period locks the financial ledger for that date range. No new manual journal entries or transaction edits will be permitted in this period.'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
            onPressed: () async {
              final currentNav = Navigator.of(ctx);
              await ref.read(accountingRepositoryProvider).closePeriod(period.id);
              ref.invalidate(accountingPeriodsProvider);
              if (mounted) currentNav.pop();
            },
            child: const Text('Confirm Period Closure'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final periodsAsync = ref.watch(accountingPeriodsProvider);
    final scheme = Theme.of(context).colorScheme;

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
              Text('Accounting Periods & Fiscal Locking', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 20),

          periodsAsync.when(
            loading: () => const KcSkeletonLoader(height: 300),
            error: (err, st) => Text('Error: $err'),
            data: (periods) {
              return KcCard(
                padding: EdgeInsets.zero,
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: periods.length,
                  separatorBuilder: (context, index) => Divider(height: 1, color: scheme.outline.withValues(alpha: 0.15)),
                  itemBuilder: (context, index) {
                    final p = periods[index];

                    return ListTile(
                      leading: Icon(p.isOpen ? Icons.lock_open_rounded : Icons.lock_rounded, color: p.isOpen ? const Color(0xFF059669) : const Color(0xFFDC2626)),
                      title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                      subtitle: Text('Start: ${KcFormatters.date(p.startDate)} • End: ${KcFormatters.date(p.endDate)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          KcStatusBadge(
                            label: p.status,
                            statusColor: p.isOpen ? const Color(0xFF059669) : const Color(0xFFDC2626),
                          ),
                          const SizedBox(width: 12),
                          if (p.isOpen)
                            KcOutlinedButton(
                              label: 'Close Period',
                              icon: Icons.lock_rounded,
                              onPressed: () => _showClosePeriodDialog(p),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
