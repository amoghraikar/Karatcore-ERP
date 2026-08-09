import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/buttons/kc_outlined_button.dart';
import '../../../../shared/widgets/buttons/kc_primary_button.dart';
import '../../../../shared/widgets/cards/kc_card.dart';

import '../../../../shared/widgets/feedback/kc_status_badge.dart';
import '../../../../shared/widgets/inputs/kc_text_field.dart';
import '../../providers/loan_providers.dart';
import '../../widgets/receipt_preview_dialog.dart';

class CollateralReleasePage extends ConsumerStatefulWidget {
  const CollateralReleasePage({super.key, this.id});

  final String? id;

  @override
  ConsumerState<CollateralReleasePage> createState() => _CollateralReleasePageState();
}

class _CollateralReleasePageState extends ConsumerState<CollateralReleasePage> {
  final _notesController = TextEditingController(text: 'Customer identity verified via Aadhaar photo check. All ornaments handed over.');
  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
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
                  Text('Collateral Release Authorization — ${loan.id}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 20),

              KcCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Customer: ${loan.customerName}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                            Text('ID: ${loan.customerId} • Loan Status: ${loan.status.label}', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
                          ],
                        ),
                        const KcStatusBadge(label: 'Identity Verified', statusColor: Color(0xFF059669), icon: Icons.verified_rounded),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Text('Ornaments Pledged (${loan.collateralOrnaments.length})', style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    ...loan.collateralOrnaments.map((orn) => ListTile(
                          leading: const Icon(Icons.diamond_rounded, color: Color(0xFFD97706)),
                          title: Text(orn.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text('Location: ${orn.location.fullLocationPath}'),
                        )),
                    const SizedBox(height: 16),

                    KcTextField(
                      controller: _notesController,
                      label: 'Release Authorization Notes',
                      maxLines: 2,
                    ),
                    const SizedBox(height: 24),

                    Row(
                      children: [
                        KcOutlinedButton(label: 'Cancel', onPressed: () => context.go('/loans/${loan.id}')),
                        const Spacer(),
                        KcPrimaryButton(
                          label: 'Release Collateral & Issue Receipt',
                          icon: Icons.key_rounded,
                          isLoading: _isSubmitting,
                          onPressed: () async {
                            final currentContext = context;
                            setState(() => _isSubmitting = true);
                            await ref.read(loanListProvider.notifier).releaseCollateral(
                                  loanId: loan.id,
                                  verifiedByStaff: 'Vault Officer',
                                  notes: _notesController.text.trim(),
                                );

                            if (!mounted || !currentContext.mounted) return;
                            setState(() => _isSubmitting = false);
                            showReceiptPreviewDialog(
                              context: currentContext,
                              receiptTitle: 'Collateral Release Receipt',
                              receiptNumber: 'KC-RCP-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
                              loan: loan,
                              customerName: loan.customerName,
                              amount: 0.0,
                              paymentMethod: 'Physical Release',
                              date: DateTime.now(),
                              staffName: 'Vault Officer',
                            );
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
