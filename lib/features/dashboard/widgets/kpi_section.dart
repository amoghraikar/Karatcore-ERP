import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/routing/routes.dart';
import '../../../shared/widgets/cards/kc_metric_card.dart';
import '../providers/dashboard_provider.dart';

class KpiSection extends ConsumerWidget {
  const KpiSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kpis = ref.watch(dashboardKpisProvider);

    final crossAxisCount = context.isDesktop ? 3 : (context.isTablet ? 2 : 1);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 120,
      ),
      itemCount: kpis.length,
      itemBuilder: (context, index) {
        final kpi = kpis[index];
        return InkWell(
          onTap: () => context.go(AppRoutes.kyc),
          borderRadius: BorderRadius.circular(12),
          child: KcMetricCard(
            title: kpi.title,
            value: kpi.value,
            trend: kpi.trend,
            icon: kpi.icon,
          ),
        );
      },
    );
  }
}
