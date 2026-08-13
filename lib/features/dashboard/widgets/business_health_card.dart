import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/color_tokens.dart';
import '../../../shared/widgets/cards/kc_card.dart';
import '../providers/dashboard_provider.dart';

class BusinessHealthCard extends ConsumerWidget {
  const BusinessHealthCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final health = ref.watch(storeBusinessHealthProvider);

    return KcCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Store Business Health Index',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Based on LTV Safety, Reserve Liquidity & Hallmark Compliance',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: KcColors.signalGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${health.overallScore} / 100',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: KcColors.signalGreen,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _HealthMetricProgress(
            label: 'LTV Safety Reserve Ratio (Collateral Protection)',
            value: health.ltvSafetyRatio,
            percentageStr: health.ltvSafetyLabel,
            color: KcColors.signalGreen,
          ),
          const SizedBox(height: 14),
          _HealthMetricProgress(
            label: 'Gold Bullion Reserve Liquidity',
            value: health.reserveLiquidityRatio,
            percentageStr: health.reserveLiquidityLabel,
            color: KcColors.signalOrange,
          ),
          const SizedBox(height: 14),
          _HealthMetricProgress(
            label: 'BIS Hallmark Compliance Score',
            value: health.complianceScore,
            percentageStr: health.complianceLabel,
            color: KcColors.signalGreen,
          ),
        ],
      ),
    );
  }
}

class _HealthMetricProgress extends StatelessWidget {
  const _HealthMetricProgress({
    required this.label,
    required this.value,
    required this.percentageStr,
    required this.color,
  });

  final String label;
  final double value;
  final String percentageStr;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const Spacer(),
            Text(
              percentageStr,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: value,
          minHeight: 6,
          backgroundColor: scheme.surfaceContainerHighest,
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ],
    );
  }
}
