import 'package:flutter/material.dart';
import '../../../core/constants/color_tokens.dart';
import '../../../shared/widgets/cards/kc_card.dart';

class NotificationsPanelWidget extends StatelessWidget {
  const NotificationsPanelWidget({super.key});

  @override
  Widget build(BuildContext context) {

    return KcCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notifications & Vault Alerts',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          const _AlertTile(
            title: 'Upcoming Loan Repayment Due Today',
            subtitle: 'Receipt #GL-9024 (Priya Sharma) ₹4,90,000 due before 5:00 PM',
            icon: Icons.event_available_rounded,
            color: KcColors.signalOrange,
          ),
          const SizedBox(height: 12),
          const _AlertTile(
            title: 'BIS Hallmark Purity Certificate Expiry',
            subtitle: 'Batch #BH-8802 certificate requires annual renewal in 12 days',
            icon: Icons.verified_outlined,
            color: KcColors.signalBlue,
          ),
          const SizedBox(height: 12),
          const _AlertTile(
            title: 'System Security Audit Completed',
            subtitle: 'Encrypted database backup stored in vault offline storage',
            icon: Icons.shield_outlined,
            color: KcColors.signalGreen,
          ),
        ],
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
