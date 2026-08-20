import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/color_tokens.dart';
import '../providers/dashboard_provider.dart';

class BusinessHealthCard extends ConsumerWidget {
  const BusinessHealthCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final health = ref.watch(storeBusinessHealthProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBg = isDark ? KcColors.surfaceDark : KcColors.surfaceLight;
    final borderColor = isDark ? KcColors.borderDark : KcColors.borderLight;
    final primaryTextColor = isDark ? KcColors.textPrimaryDark : KcColors.textPrimaryLight;
    final secondaryTextColor = isDark ? KcColors.textSecondaryDark : KcColors.textSecondaryLight;

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
                'STORE HEALTH & COMPLIANCE',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: KcColors.goldAccent,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: KcColors.successSubdued,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'HEALTHY SCORE: ${health.overallScore}/100',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: KcColors.success,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Text(
            'Risk & Reserve Liquidity Overview',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: primaryTextColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Loan-to-value safety ratio and vault liquidity status',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: secondaryTextColor,
            ),
          ),
          const SizedBox(height: 20),

          _HealthIndicatorRow(
            label: 'LTV Collateral Protection',
            valueLabel: health.ltvSafetyLabel,
            ratio: health.ltvSafetyRatio,
            color: KcColors.success,
          ),
          const SizedBox(height: 16),
          _HealthIndicatorRow(
            label: 'Reserve Liquidity Buffer',
            valueLabel: health.reserveLiquidityLabel,
            ratio: health.reserveLiquidityRatio,
            color: KcColors.goldAccent,
          ),
          const SizedBox(height: 16),
          _HealthIndicatorRow(
            label: 'Regulatory & KYC Compliance',
            valueLabel: health.complianceLabel,
            ratio: health.complianceScore,
            color: KcColors.success,
          ),
        ],
      ),
    );
  }
}

class _HealthIndicatorRow extends StatelessWidget {
  const _HealthIndicatorRow({
    required this.label,
    required this.valueLabel,
    required this.ratio,
    required this.color,
  });

  final String label;
  final String valueLabel;
  final double ratio;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? KcColors.textPrimaryDark : KcColors.textPrimaryLight,
              ),
            ),
            Text(
              valueLabel,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio.clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: isDark ? const Color(0x1FA0A0A0) : const Color(0x0F111214),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
