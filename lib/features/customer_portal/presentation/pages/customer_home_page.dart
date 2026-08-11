import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/color_tokens.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/feedback/kc_toast.dart';
import '../../providers/customer_portal_providers.dart';

class CustomerHomePage extends ConsumerWidget {
  const CustomerHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(currentCustomerSessionProvider);
    final loansAsync = ref.watch(customerLoansProvider);
    final jewelleryAsync = ref.watch(customerJewelleryProvider);

    return ListView(
      padding: EdgeInsets.all(context.pageGutter),
      children: [
        // Personalized Greeting Header
        KcCard(
          padding: const EdgeInsets.all(20),
          color: const Color(0xFF1E1B4B),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFF7C3AED),
                    child: Text(
                      session.customerName.substring(0, 1),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
                        ),
                        Text(
                          session.customerName,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF059669).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF059669)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_user_rounded, color: Color(0xFF10B981), size: 14),
                        SizedBox(width: 4),
                        Text('KYC VERIFIED', style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Financial Summary & Pledged Vault Assets',
                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Prominent Factual Trust Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF059669).withValues(alpha: 0.3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.shield_outlined, color: Color(0xFF059669), size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'KYC Verified • Digital Receipts Encrypted • Account Active',
                  style: TextStyle(color: Color(0xFF064E3B), fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Financial Summary KPI Cards
        loansAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, st) => Text('Error: $err'),
          data: (loans) {
            final activeLoans = loans.where((l) => l.status.name != 'closed' && l.status.name != 'cancelled').toList();
            final totalOutstanding = activeLoans.fold<double>(0, (sum, l) => sum + l.principalAmount + l.accruedInterest);
            final nextLoan = activeLoans.isNotEmpty ? activeLoans.first : null;

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _CustomerKpiCard(
                        title: 'Active Loans',
                        value: '${activeLoans.length}',
                        subtitle: activeLoans.isEmpty ? 'No active loan' : 'Pledge contracts',
                        icon: Icons.account_balance_outlined,
                        accentColor: const Color(0xFF2563EB),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _CustomerKpiCard(
                        title: 'Total Due Amount',
                        value: KcFormatters.currency(totalOutstanding),
                        subtitle: 'Principal + Accrued',
                        icon: Icons.monetization_on_outlined,
                        accentColor: const Color(0xFFD97706),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _CustomerKpiCard(
                        title: 'Next Due Date',
                        value: nextLoan != null ? KcFormatters.date(nextLoan.nextDueDate) : 'N/A',
                        subtitle: nextLoan != null ? 'Loan #${nextLoan.id}' : 'No payment due',
                        icon: Icons.event_available_outlined,
                        accentColor: const Color(0xFF7C3AED),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: jewelleryAsync.when(
                        data: (items) => _CustomerKpiCard(
                          title: 'Pledged Jewellery',
                          value: '${items.length} Items',
                          subtitle: 'Vault Storage',
                          icon: Icons.diamond_outlined,
                          accentColor: const Color(0xFF059669),
                        ),
                        loading: () => const _CustomerKpiCard(title: 'Pledged Jewellery', value: '...', subtitle: 'Loading', icon: Icons.diamond_outlined, accentColor: Color(0xFF059669)),
                        error: (_, __) => const _CustomerKpiCard(title: 'Pledged Jewellery', value: '0 Items', subtitle: 'Error', icon: Icons.diamond_outlined, accentColor: Color(0xFF059669)),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),

        // Quick Actions Grid
        Text('Quick Actions', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: context.isDesktop ? 6 : 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: [
            _QuickActionButton(
              icon: Icons.account_balance_rounded,
              label: 'My Loans',
              onTap: () => context.go('/customer/loans'),
            ),
            _QuickActionButton(
              icon: Icons.diamond_rounded,
              label: 'Jewellery',
              onTap: () => context.go('/customer/jewellery'),
            ),
            _QuickActionButton(
              icon: Icons.payments_rounded,
              label: 'Payments',
              onTap: () => context.go('/customer/payments'),
            ),
            _QuickActionButton(
              icon: Icons.receipt_long_rounded,
              label: 'Receipts',
              onTap: () => context.go('/customer/payments'),
            ),
            _QuickActionButton(
              icon: Icons.folder_rounded,
              label: 'Documents',
              onTap: () => context.go('/customer/documents'),
            ),
            _QuickActionButton(
              icon: Icons.support_agent_rounded,
              label: 'Contact Shop',
              onTap: () {
                KcToast.info(context, 'Contact store counter at +91 98200 12345 or visit shop branch.', title: 'Store Support');
              },
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Active Loans Overview Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Active Pledge Loans', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            TextButton(
              onPressed: () => context.go('/customer/loans'),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        loansAsync.when(
          loading: () => const SizedBox(),
          error: (_, __) => const SizedBox(),
          data: (loans) {
            if (loans.isEmpty) {
              return const KcCard(
                padding: EdgeInsets.all(24),
                child: Center(child: Text('No active pledge loans associated with your account.')),
              );
            }
            return Column(
              children: loans.take(2).map((loan) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: KcCard(
                    padding: const EdgeInsets.all(16),
                    child: InkWell(
                      onTap: () => context.go('/customer/loans/${loan.id}'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Loan #${loan.id}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: loan.status.color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  loan.status.label.toUpperCase(),
                                  style: TextStyle(color: loan.status.color, fontWeight: FontWeight.w800, fontSize: 10),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Principal Amount', style: Theme.of(context).textTheme.bodySmall),
                                    Text(KcFormatters.currency(loan.principalAmount), style: const TextStyle(fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Next Payment Due', style: Theme.of(context).textTheme.bodySmall),
                                    Text(KcFormatters.date(loan.nextDueDate), style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2563EB))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _CustomerKpiCard extends StatelessWidget {
  const _CustomerKpiCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return KcCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
              Icon(icon, size: 18, color: accentColor),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
          ),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: KcColors.slate400)),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF7C3AED), size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
