import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/icon_tokens.dart';
import '../../../core/routing/routes.dart';
import '../../../shared/widgets/buttons/kc_outlined_button.dart';
import '../../../shared/widgets/buttons/kc_primary_button.dart';
import '../../../shared/widgets/cards/kc_card.dart';
import '../../../shared/widgets/dialogs/kc_snackbars.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return KcCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              KcPrimaryButton(
                label: 'New Customer',
                icon: KcIcons.add,
                onPressed: () {
                  context.go(AppRoutes.customers);
                  KcSnackbars.success(context, 'Navigated to Customer Registration');
                },
              ),
              KcPrimaryButton(
                label: 'New Gold Loan',
                icon: KcIcons.loans,
                onPressed: () {
                  context.go(AppRoutes.loans);
                  KcSnackbars.success(context, 'Navigated to Gold Loan Processing');
                },
              ),
              KcOutlinedButton(
                label: 'Verify KYC',
                icon: KcIcons.kyc,
                onPressed: () {
                  context.go(AppRoutes.kyc);
                },
              ),
              KcOutlinedButton(
                label: 'Add Ornament',
                icon: KcIcons.ornaments,
                onPressed: () {
                  context.go(AppRoutes.ornamentCreate);
                },
              ),
              KcOutlinedButton(
                label: 'Create Report',
                icon: KcIcons.reports,
                onPressed: () {
                  context.go(AppRoutes.reports);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
