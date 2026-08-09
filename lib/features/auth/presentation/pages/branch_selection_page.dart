import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/color_tokens.dart';
import '../../../../core/routing/routes.dart';
import '../../../../shared/widgets/buttons/kc_primary_button.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../models/branch_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth_split_layout.dart';

class BranchSelectionPage extends ConsumerStatefulWidget {
  const BranchSelectionPage({super.key});

  @override
  ConsumerState<BranchSelectionPage> createState() => _BranchSelectionPageState();
}

class _BranchSelectionPageState extends ConsumerState<BranchSelectionPage> {
  BranchModel _selected = BranchModel.mockBranches[0];

  void _onConfirmBranch() {
    ref.read(authStateProvider.notifier).selectBranch(_selected);
    context.go(AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final authState = ref.watch(authStateProvider);
    final user = authState.session;

    return AuthSplitLayout(
      headline: 'Select Operational Store Branch',
      subheadline: 'Multi-branch vault stock, loan accounting, and sales registers are isolated per store location.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: KcColors.gold500.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.store_rounded, color: KcColors.gold500, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, ${user?.name ?? "User"}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text(
                      'Role: ${user?.role.label ?? "Owner"} (${user?.role.description})',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Select Branch Location',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Select the jewellery showroom or vault location you are accessing today.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 20),

          // Branch List Cards
          ...BranchModel.mockBranches.map((branch) {
            final isSelected = _selected.id == branch.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: KcCard(
                padding: const EdgeInsets.all(16),
                border: Border.all(
                  color: isSelected ? scheme.primary : scheme.outlineVariant.withValues(alpha: 0.5),
                  width: isSelected ? 2 : 1,
                ),
                color: isSelected ? scheme.primary.withValues(alpha: 0.05) : null,
                onTap: () => setState(() => _selected = branch),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
                      color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                branch.name,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              if (branch.isMainBranch) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: KcColors.gold500.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'HEADQUARTERS',
                                    style: TextStyle(
                                      color: KcColors.gold500,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${branch.location}, ${branch.city}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.circle, size: 8, color: KcColors.signalGreen),
                              const SizedBox(width: 4),
                              Text(
                                branch.status,
                                style: const TextStyle(fontSize: 11, color: KcColors.signalGreen, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Last accessed: ${branch.lastAccessed}',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 16),
          KcPrimaryButton(
            label: 'Enter Store ERP (${_selected.name})',
            fullWidth: true,
            icon: Icons.arrow_forward_rounded,
            onPressed: _onConfirmBranch,
          ),
        ],
      ),
    );
  }
}
