import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final dateStr = DateFormat('EEEE · d MMMM yyyy').format(now);
    final authState = ref.watch(authStateProvider);
    final user = authState.session;
    final userName = user?.name ?? 'AMOGH';

    final primaryTextColor = isDark ? KcColors.textPrimaryDark : KcColors.textPrimaryLight;
    final secondaryTextColor = isDark ? KcColors.textSecondaryDark : KcColors.textSecondaryLight;
    final borderColor = isDark ? KcColors.borderDark : KcColors.borderLight;

    final hour = now.hour;
    String greeting;
    if (hour < 12) {
      greeting = 'GOOD MORNING';
    } else if (hour < 17) {
      greeting = 'GOOD AFTERNOON';
    } else {
      greeting = 'GOOD EVENING';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Live Bullion Ticker Ribbon
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              const _RatePill(label: '24K GOLD', price: '₹7,450/g', change: '+0.4%'),
              const SizedBox(width: 10),
              const _RatePill(label: '22K GOLD', price: '₹6,830/g', change: '+0.3%'),
              const SizedBox(width: 10),
              const _RatePill(label: '999 SILVER', price: '₹88/g', change: '+0.1%'),
              const SizedBox(width: 16),
              Container(
                height: 14,
                width: 1,
                color: borderColor,
              ),
              const SizedBox(width: 16),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: KcColors.goldAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'JEWELLERY ERP',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: isDark ? KcColors.textMutedDark : KcColors.textMutedLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // Editorial Display Greeting Headline
        RichText(
          text: TextSpan(
            style: GoogleFonts.plusJakartaSans(
              color: primaryTextColor,
              fontSize: 40,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.2,
              height: 1.05,
            ),
            children: [
              TextSpan(text: '$greeting, '),
              TextSpan(
                text: '${userName.toUpperCase()}.',
                style: const TextStyle(color: KcColors.goldAccent),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              'Run your jewellery business with clarity.',
              style: GoogleFonts.plusJakartaSans(
                color: secondaryTextColor,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '·',
              style: TextStyle(color: secondaryTextColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 12),
            Text(
              dateStr,
              style: GoogleFonts.plusJakartaSans(
                color: secondaryTextColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Clean Editorial Action Pills
        Wrap(
          spacing: 12,
          runSpacing: 10,
          children: [
            _EditorialActionButton(
              label: '+ New Customer',
              isPrimary: true,
              onPressed: () => context.go(AppRoutes.customerCreate),
            ),
            _EditorialActionButton(
              label: '+ New Pledge',
              isPrimary: false,
              onPressed: () => context.go(AppRoutes.loanCreate),
            ),
            _EditorialActionButton(
              label: 'View Accounting Ledger',
              isPrimary: false,
              onPressed: () => context.go(AppRoutes.accounting),
            ),
          ],
        ),
      ],
    );
  }
}

class _EditorialActionButton extends StatelessWidget {
  const _EditorialActionButton({
    required this.label,
    required this.isPrimary,
    required this.onPressed,
  });

  final String label;
  final bool isPrimary;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryBg = isDark ? KcColors.textPrimaryDark : KcColors.textPrimaryLight;
    final primaryFg = isDark ? KcColors.bgDark : KcColors.surfaceLight;
    final borderColor = isDark ? KcColors.borderDark : KcColors.borderLight;
    final secondaryFg = isDark ? KcColors.textPrimaryDark : KcColors.textPrimaryLight;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: isPrimary ? primaryBg : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isPrimary ? null : Border.all(color: borderColor, width: 1.0),
          ),
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.1,
              color: isPrimary ? primaryFg : secondaryFg,
            ),
          ),
        ),
      ),
    );
  }
}

class _RatePill extends StatelessWidget {
  const _RatePill({
    required this.label,
    required this.price,
    required this.change,
  });

  final String label;
  final String price;
  final String change;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0x0AFFFFFF) : const Color(0x08111214),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isDark ? KcColors.borderDark : KcColors.borderLight,
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: isDark ? KcColors.textSecondaryDark : KcColors.textSecondaryLight,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            price,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? KcColors.textPrimaryDark : KcColors.textPrimaryLight,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            change,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: KcColors.success,
            ),
          ),
        ],
      ),
    );
  }
}