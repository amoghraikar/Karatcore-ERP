import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/cards/kc_metric_card.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(context.pageGutter),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notifications Center',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Alerts & Customer Reminders',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Row(
          children: [
            Expanded(
              child: KcMetricCard(
                title: 'Total Records',
                value: '1,248',
                trend: '+12.4% vs last mo',
                icon: Icons.folder_copy_rounded,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: KcMetricCard(
                title: 'Active Operations',
                value: '42',
                trend: 'Normal status',
                icon: Icons.sync_rounded,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: KcMetricCard(
                title: 'System Readiness',
                value: '100%',
                trend: 'Plug & Play Architecture',
                icon: Icons.verified_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        KcCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notifications Center Module Placeholder',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'This feature module is architected with a feature-first pattern (presentation, widgets, providers, models, services, repository). Ready for business logic plug-in.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
