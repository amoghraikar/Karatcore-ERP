import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/color_tokens.dart';
import '../providers/dashboard_provider.dart';

class KpiSection extends ConsumerWidget {
  const KpiSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kpis = ref.watch(dashboardKpisProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryTextColor = isDark ? KcColors.textPrimaryDark : KcColors.textPrimaryLight;
    final secondaryTextColor = isDark ? KcColors.textSecondaryDark : KcColors.textSecondaryLight;
    final cardBg = isDark ? KcColors.surfaceDark : KcColors.surfaceLight;
    final borderColor = isDark ? KcColors.borderDark : KcColors.borderLight;

    final revenueKpi = kpis.firstWhere((k) => k.title.contains('Revenue'), orElse: () => kpis[0]);
    final loanKpi = kpis.firstWhere((k) => k.title.contains('Outstanding'), orElse: () => kpis[1]);
    final interestKpi = kpis.firstWhere((k) => k.title.contains('Interest'), orElse: () => kpis[2]);
    final customersKpi = kpis.firstWhere((k) => k.title.contains('Active Customers'), orElse: () => kpis[3]);

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
          // Section Sub-header Label
          Row(
            children: [
              Text(
                'TODAY',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: KcColors.goldAccent,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: KcColors.successSubdued,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '+12.4% vs yesterday',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: KcColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Hero Oversized Revenue Typography
          Text(
            revenueKpi.value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 48,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.4,
              height: 1.0,
              color: primaryTextColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Total Revenue Collected Today · ${revenueKpi.trend}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: secondaryTextColor,
            ),
          ),
          const SizedBox(height: 28),
          Divider(height: 1, color: borderColor),
          const SizedBox(height: 24),

          // Supporting Financial Metrics Row (Whitespace separated)
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 650) {
                return Column(
                  children: [
                    _MiniMetricItem(label: 'OUTSTANDING LOANS', value: loanKpi.value, subtext: loanKpi.trend),
                    const SizedBox(height: 16),
                    _MiniMetricItem(label: 'INTEREST COLLECTED', value: interestKpi.value, subtext: interestKpi.trend),
                    const SizedBox(height: 16),
                    _MiniMetricItem(label: 'REGISTERED CLIENTS', value: customersKpi.value, subtext: customersKpi.trend),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(
                    child: _MiniMetricItem(
                      label: 'OUTSTANDING LOANS',
                      value: loanKpi.value,
                      subtext: loanKpi.trend,
                    ),
                  ),
                  Container(height: 40, width: 1, color: borderColor),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 24),
                      child: _MiniMetricItem(
                        label: 'INTEREST COLLECTED',
                        value: interestKpi.value,
                        subtext: interestKpi.trend,
                      ),
                    ),
                  ),
                  Container(height: 40, width: 1, color: borderColor),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 24),
                      child: _MiniMetricItem(
                        label: 'REGISTERED CLIENTS',
                        value: customersKpi.value,
                        subtext: customersKpi.trend,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MiniMetricItem extends StatelessWidget {
  const _MiniMetricItem({
    required this.label,
    required this.value,
    required this.subtext,
  });

  final String label;
  final String value;
  final String subtext;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: isDark ? KcColors.textSecondaryDark : KcColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: isDark ? KcColors.textPrimaryDark : KcColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtext,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: isDark ? KcColors.textMutedDark : KcColors.textMutedLight,
          ),
        ),
      ],
    );
  }
}
