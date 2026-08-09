import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../shared/models/user_session.dart';
import '../../../shared/widgets/feedback/kc_status_badge.dart';

class WelcomeHeader extends StatelessWidget {
  const WelcomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, d MMMM yyyy').format(now);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, ${UserSession.mock.name}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$dateStr • Operational Overview & Bullion Vault Status',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            const Wrap(
              spacing: 8,
              children: [
                KcStatusBadge(
                  label: 'VAULT AUDITED',
                  type: KcStatusType.success,
                ),
                KcStatusBadge(
                  label: 'LIVE GOLD: ₹7,450/g',
                  type: KcStatusType.info,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
