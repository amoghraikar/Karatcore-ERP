import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/color_tokens.dart';
import '../../../core/routing/routes.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? KcColors.surfaceDark : KcColors.surfaceLight;
    final borderColor = isDark ? KcColors.borderDark : KcColors.borderLight;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'QUICK SHORTCUTS',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
              color: KcColors.goldAccent,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              _ShortcutChip(
                icon: Icons.person_add_alt_1_outlined,
                label: 'Onboard Customer',
                onTap: () => context.go(AppRoutes.customerCreate),
              ),
              _ShortcutChip(
                icon: Icons.add_circle_outline_rounded,
                label: 'Issue Gold Loan',
                onTap: () => context.go(AppRoutes.loanCreate),
              ),
              _ShortcutChip(
                icon: Icons.verified_user_outlined,
                label: 'Verify KYC',
                onTap: () => context.go(AppRoutes.kyc),
              ),
              _ShortcutChip(
                icon: Icons.diamond_outlined,
                label: 'Add Ornament',
                onTap: () => context.go(AppRoutes.ornamentCreate),
              ),
              _ShortcutChip(
                icon: Icons.bar_chart_rounded,
                label: 'Monthly Reports',
                onTap: () => context.go(AppRoutes.reports),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShortcutChip extends StatelessWidget {
  const _ShortcutChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? KcColors.borderDark : KcColors.borderLight;
    final textColor = isDark ? KcColors.textPrimaryDark : KcColors.textPrimaryLight;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0x0AFFFFFF) : const Color(0x08111214),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: 1.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: KcColors.goldAccent),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
