import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/color_tokens.dart';
import '../../../core/routing/routes.dart';
import '../../../features/auth/providers/auth_provider.dart';

class WelcomeHeader extends ConsumerWidget {
  const WelcomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, d MMMM yyyy').format(now);
    final authState = ref.watch(authStateProvider);
    final user = authState.session;
    final userName = user?.name ?? 'Store Owner';
    final storeName = user?.storeName ?? user?.branch?.name ?? 'Main Market Branch';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? KcColors.obsidian900 : KcColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: KcColors.gold500.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Status & Gold Rate Ribbon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: KcColors.gold500.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: KcColors.gold500.withValues(alpha: 0.4)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome_rounded, size: 13, color: KcColors.gold400),
                    SizedBox(width: 6),
                    Text(
                      'LUXURY ERP SUITE',
                      style: TextStyle(
                        color: KcColors.gold300,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Live Bullion Rate Ticker
              const Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _RateBadge(label: '24K Gold', price: '₹7,450/g', change: '+0.4%'),
                      SizedBox(width: 8),
                      _RateBadge(label: '22K Gold', price: '₹6,830/g', change: '+0.3%'),
                      SizedBox(width: 8),
                      _RateBadge(label: '999 Silver', price: '₹88/g', change: '+0.1%'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: KcColors.emerald500.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: KcColors.emerald500.withValues(alpha: 0.35)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(radius: 3.5, backgroundColor: KcColors.emerald500),
                    SizedBox(width: 6),
                    Text(
                      'VAULT SECURE',
                      style: TextStyle(
                        color: KcColors.emerald500,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Welcome back, $userName',
            style: TextStyle(
              color: isDark ? KcColors.pureWhite : KcColors.slate900,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$storeName • $dateStr',
            style: TextStyle(
              color: isDark ? KcColors.slate400 : KcColors.slate600,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _HeaderActionButton(
                label: '+ Onboard Customer',
                icon: Icons.person_add_alt_1_rounded,
                onTap: () => context.go(AppRoutes.customerCreate),
              ),
              _HeaderActionButton(
                label: '+ New Gold Pledge Loan',
                icon: Icons.add_circle_outline_rounded,
                onTap: () => context.go(AppRoutes.loanCreate),
              ),
              _HeaderActionButton(
                label: 'View Vault Ledger',
                icon: Icons.account_balance_wallet_rounded,
                onTap: () => context.go(AppRoutes.accounting),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RateBadge extends StatelessWidget {
  const _RateBadge({
    required this.label,
    required this.price,
    required this.change,
  });

  final String label;
  final String price;
  final String change;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: KcColors.obsidian850,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: KcColors.obsidian800),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: KcColors.slate400)),
          const SizedBox(width: 5),
          Text(price, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: KcColors.pureWhite)),
          const SizedBox(width: 4),
          Text(change, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: KcColors.emerald500)),
        ],
      ),
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  const _HeaderActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: KcColors.obsidian850,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: KcColors.obsidian800),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: KcColors.gold400),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: KcColors.pureWhite,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}