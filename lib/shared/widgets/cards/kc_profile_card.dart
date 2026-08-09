import 'package:flutter/material.dart';
import '../../components/kc_avatar.dart';
import 'kc_card.dart';

class KcProfileCard extends StatelessWidget {
  const KcProfileCard({
    super.key,
    required this.name,
    required this.role,
    required this.initials,
    this.email,
  });

  final String name;
  final String role;
  final String initials;
  final String? email;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return KcCard(
      child: Row(
        children: [
          KcAvatar(initials: initials, size: 52),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(role, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                if (email != null) ...[
                  const SizedBox(height: 2),
                  Text(email!, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
