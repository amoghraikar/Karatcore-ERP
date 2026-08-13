import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/cards/kc_card.dart';
import '../../../shared/widgets/charts/kc_chart_wrapper.dart';
import '../providers/dashboard_provider.dart';

class AnalyticsSection extends ConsumerWidget {
  const AnalyticsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final revenueData = ref.watch(revenueChartDataProvider);
    final loanDonutData = ref.watch(loanDistributionChartProvider);
    final monthlyData = ref.watch(monthlyTransactionsChartProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (context.isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: KcCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Weekly Revenue Performance',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const Spacer(),
                          Builder(
                            builder: (context) {
                              final total = revenueData.fold(0.0, (sum, item) => sum + item.value);
                              return Text(
                                '${KcFormatters.inrCompact(total)} Total',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      KcChartWrapper.lineChart(
                        context: context,
                        data: revenueData,
                        height: 220,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: KcCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Loan Book Asset Split',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 16),
                      KcChartWrapper.donutChart(
                        context: context,
                        data: loanDonutData,
                        height: 220,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        else
          Column(
            children: [
              KcCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weekly Revenue Performance',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 16),
                    KcChartWrapper.lineChart(
                      context: context,
                      data: revenueData,
                      height: 200,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              KcCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Loan Book Asset Split',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 16),
                    KcChartWrapper.donutChart(
                      context: context,
                      data: loanDonutData,
                      height: 200,
                    ),
                  ],
                ),
              ),
            ],
          ),
        const SizedBox(height: 16),
        KcCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Monthly Transaction Volume (H1 2026)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 16),
              KcChartWrapper.barChart(
                context: context,
                data: monthlyData,
                height: 180,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
