import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/buttons/kc_primary_button.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/feedback/kc_empty_state.dart';
import '../../../../shared/widgets/feedback/kc_skeleton_loader.dart';
import '../../../../shared/widgets/feedback/kc_status_badge.dart';

import '../../providers/accounting_providers.dart';

class JournalEntriesPage extends ConsumerWidget {
  const JournalEntriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journalAsync = ref.watch(journalEntriesProvider);
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
              Text('Journal Entries Directory', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
              const Spacer(),
              KcPrimaryButton(
                label: 'New Journal Entry',
                icon: Icons.edit_note_rounded,
                onPressed: () => context.go(AppRoutes.accountingJournalCreate),
              ),
            ],
          ),
          const SizedBox(height: 20),

          journalAsync.when(
            loading: () => const KcSkeletonLoader(height: 400),
            error: (err, st) => Text('Error: $err'),
            data: (journals) {
              if (journals.isEmpty) {
                return KcEmptyState(
                  title: 'No Journal Vouchers Logged',
                  subtitle: 'No manual journal entries created.',
                  action: KcPrimaryButton(
                    label: 'New Journal Entry',
                    onPressed: () => context.go(AppRoutes.accountingJournalCreate),
                  ),
                );
              }

              return KcCard(
                padding: EdgeInsets.zero,
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: journals.length,
                  separatorBuilder: (context, index) => Divider(height: 1, color: scheme.outline.withValues(alpha: 0.15)),
                  itemBuilder: (context, index) {
                    final j = journals[index];

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: scheme.primaryContainer,
                        child: Icon(Icons.edit_note_rounded, color: scheme.primary, size: 20),
                      ),
                      title: Text('${j.id} • ${j.reference}', style: const TextStyle(fontWeight: FontWeight.w800)),
                      subtitle: Text('${j.description}\nLines: ${j.lines.length} • Posted by: ${j.createdBy} • ${KcFormatters.dateTime(j.date)}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(KcFormatters.inr(j.totalDebit), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                          const SizedBox(height: 2),
                          KcStatusBadge(label: j.status, statusColor: const Color(0xFF059669)),
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
