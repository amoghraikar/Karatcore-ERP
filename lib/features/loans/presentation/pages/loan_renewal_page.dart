import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/buttons/kc_outlined_button.dart';
import '../../../../shared/widgets/buttons/kc_primary_button.dart';
import '../../../../shared/widgets/cards/kc_card.dart';

import '../../../../shared/widgets/inputs/kc_text_field.dart';
import '../../providers/loan_providers.dart';

class LoanRenewalPage extends ConsumerStatefulWidget {
  const LoanRenewalPage({super.key, this.id});

  final String? id;

  @override
  ConsumerState<LoanRenewalPage> createState() => _LoanRenewalPageState();
}

class _LoanRenewalPageState extends ConsumerState<LoanRenewalPage> {
  final _newRateController = TextEditingController(text: '11.5');
  final _extendedMonthsController = TextEditingController(text: '12');
  bool _isSubmitting = false;

  @override
  void dispose() {
    _newRateController.dispose();
    _extendedMonthsController.dispose();
    super.dispose();
  }

  String _getTargetId() {
    if (widget.id != null && widget.id!.isNotEmpty) return widget.id!;
    final path = GoRouterState.of(context).uri.path;
    final parts = path.split('/');
    if (parts.length > 2 && parts[2].isNotEmpty) {
      return parts[2];
    }
    return 'KC-LN-9481';
  }

  @override
  Widget build(BuildContext context) {
    final loanId = _getTargetId();
    final loanAsync = ref.watch(loanDetailProvider(loanId));

    return Scaffold(
      body: loanAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Text('Error: $err'),
        data: (loan) {
          if (loan == null) return const Text('Loan Not Found');

          return ListView(
            padding: EdgeInsets.all(context.pageGutter),
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => context.go('/loans/${loan.id}'),
                  ),
                  const SizedBox(width: 8),
                  Text('Loan Renewal & Term Extension — ${loan.id}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 20),

              KcCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Current Loan Principal: ${KcFormatters.inr(loan.principalAmount)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    Text('Current Maturity Date: ${KcFormatters.date(loan.maturityDate)}', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
                    const SizedBox(height: 16),

                    KcTextField(
                      controller: _newRateController,
                      label: 'New Interest Rate (% p.a.) *',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),

                    KcTextField(
                      controller: _extendedMonthsController,
                      label: 'Extension Duration (Months) *',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),

                    Row(
                      children: [
                        KcOutlinedButton(label: 'Cancel', onPressed: () => context.go('/loans/${loan.id}')),
                        const Spacer(),
                        KcPrimaryButton(
                          label: 'Approve & Extend Loan',
                          icon: Icons.update_rounded,
                          isLoading: _isSubmitting,
                          onPressed: () async {
                            final router = GoRouter.of(context);
                            setState(() => _isSubmitting = true);
                            final rate = double.tryParse(_newRateController.text) ?? loan.interestRatePercentage;
                            final months = int.tryParse(_extendedMonthsController.text) ?? 12;

                            await ref.read(loanRepositoryProvider).renewLoan(
                                  loanId: loan.id,
                                  newPrincipal: loan.principalAmount,
                                  newRate: rate,
                                  extendedMonths: months,
                                  officerName: 'Loan Officer',
                                );

                            ref.invalidate(loanListProvider);
                            ref.invalidate(loanDetailProvider(loan.id));

                            if (!mounted) return;
                            setState(() => _isSubmitting = false);
                            router.go('/loans/${loan.id}');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
