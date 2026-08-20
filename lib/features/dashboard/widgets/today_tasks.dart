import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/color_tokens.dart';
import '../../../core/routing/routes.dart';
import '../../../shared/widgets/buttons/karat_badge.dart';
import '../../customers/models/customer_model.dart';
import '../../customers/providers/customer_providers.dart';
import '../../loans/models/loan_model.dart';
import '../../loans/providers/loan_providers.dart';

class TodayTasksWidget extends ConsumerWidget {
  const TodayTasksWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loans = ref.watch(loanListProvider).valueOrNull ?? [];
    final customers = ref.watch(customerListProvider).valueOrNull ?? [];

    final cardBg = isDark ? KcColors.surfaceDark : KcColors.surfaceLight;
    final borderColor = isDark ? KcColors.borderDark : KcColors.borderLight;

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    final loansDueToday = loans.where((l) {
      return (l.status == LoanStatus.active) &&
          l.nextDueDate.isAfter(todayStart) &&
          l.nextDueDate.isBefore(todayEnd);
    }).toList();

    final overdueLoans = loans.where((l) => l.status == LoanStatus.overdue).toList();
    final pendingKyc = customers.where((c) => c.kycStatus == CustomerKycStatus.pending).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "TODAY'S ATTENTION",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: KcColors.goldAccent,
                ),
              ),
              const Spacer(),
              KaratBadge(
                label: '${loansDueToday.length + overdueLoans.length + pendingKyc.length} ACTION ITEMS',
                variant: overdueLoans.isNotEmpty ? KaratBadgeVariant.danger : KaratBadgeVariant.gold,
                showDot: true,
              ),
            ],
          ),
          const SizedBox(height: 20),

          _AttentionRow(
            title: 'Loans Due Today',
            countStr: '${loansDueToday.length}',
            subtitle: loansDueToday.isNotEmpty ? 'Interest receipts due today' : 'No receipts due today',
            badgeVariant: loansDueToday.isNotEmpty ? KaratBadgeVariant.warning : KaratBadgeVariant.neutral,
            onTap: () => context.go(AppRoutes.loans),
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: borderColor),
          const SizedBox(height: 12),

          _AttentionRow(
            title: 'Overdue Loan Accounts',
            countStr: '${overdueLoans.length}',
            subtitle: overdueLoans.isNotEmpty ? 'Requires owner follow-up & penalty notice' : 'All loan accounts in good standing',
            badgeVariant: overdueLoans.isNotEmpty ? KaratBadgeVariant.danger : KaratBadgeVariant.success,
            onTap: () => context.go(AppRoutes.loans),
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: borderColor),
          const SizedBox(height: 12),

          _AttentionRow(
            title: 'Pending KYC Submissions',
            countStr: '${pendingKyc.length}',
            subtitle: pendingKyc.isNotEmpty ? 'Aadhaar & PAN verification required' : 'All customer profiles verified',
            badgeVariant: pendingKyc.isNotEmpty ? KaratBadgeVariant.gold : KaratBadgeVariant.success,
            onTap: () => context.go(AppRoutes.kyc),
          ),
        ],
      ),
    );
  }
}

class _AttentionRow extends StatelessWidget {
  const _AttentionRow({
    required this.title,
    required this.countStr,
    required this.subtitle,
    required this.badgeVariant,
    required this.onTap,
  });

  final String title;
  final String countStr;
  final String subtitle;
  final KaratBadgeVariant badgeVariant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark ? KcColors.textPrimaryDark : KcColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: isDark ? KcColors.textSecondaryDark : KcColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            KaratBadge(
              label: countStr,
              variant: badgeVariant,
            ),
          ],
        ),
      ),
    );
  }
}
