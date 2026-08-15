import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/feedback/kc_status_badge.dart';
import '../models/accounting_model.dart';
import '../providers/accounting_providers.dart';

class AccountingPeriodSelector extends ConsumerWidget {
  const AccountingPeriodSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final periodsAsync = ref.watch(accountingPeriodsProvider);
    final selectedPeriod = ref.watch(selectedAccountingPeriodProvider);
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.3)),
      ),
      child: periodsAsync.when(
        loading: () => const SizedBox(width: 140, child: Text('Loading...')),
        error: (err, st) => const Text('Current Period'),
        data: (periods) {
          if (periods.isEmpty) {
            return const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.date_range_rounded, size: 18),
                SizedBox(width: 8),
                Text('Current Financial Year'),
              ],
            );
          }

          final active = selectedPeriod ??
              periods.firstWhere(
                (p) => p.status == 'Open',
                orElse: () => periods.first,
              );

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.date_range_rounded, size: 18),
              const SizedBox(width: 8),
              DropdownButtonHideUnderline(
                child: DropdownButton<AccountingPeriodModel>(
                  value: periods.contains(active) ? active : (periods.isNotEmpty ? periods.first : null),
                  isDense: true,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                  onChanged: (p) {
                    if (p != null) {
                      ref.read(selectedAccountingPeriodProvider.notifier).state = p;
                    }
                  },
                  items: periods.map((p) {
                    return DropdownMenuItem(
                      value: p,
                      child: Text('${p.name} (${p.status})'),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(width: 8),
              KcStatusBadge(
                label: active.status,
                statusColor: active.status == 'Open' ? const Color(0xFF059669) : const Color(0xFFDC2626),
              ),
            ],
          );
        },
      ),
    );
  }
}
