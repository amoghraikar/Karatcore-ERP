import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/feedback/kc_skeleton_loader.dart';
import '../../providers/staff_providers.dart';

class SecurityActivityPage extends ConsumerWidget {
  const SecurityActivityPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final secEventsAsync = ref.watch(securityEventsProvider);

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(context.pageGutter),
        children: [
          Row(
            children: [
              const Icon(Icons.security_rounded, size: 32, color: Color(0xFF7C3AED)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('System Security Event Timeline', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text('Audit log of logins, failed authentication attempts, role modifications & session revocations', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          secEventsAsync.when(
            loading: () => const KcSkeletonLoader(height: 400),
            error: (err, st) => Center(child: Text('Error loading security events: $err')),
            data: (events) {
              return Column(
                children: events.map((event) {
                  final isWarn = event.status == 'WARN';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: KcCard(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isWarn ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isWarn ? Icons.warning_amber_rounded : Icons.shield_rounded,
                              color: isWarn ? const Color(0xFFDC2626) : const Color(0xFF059669),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(event.eventType, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isWarn ? const Color(0xFFFEE2E2) : const Color(0xFFDCFCE7),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(event.status, style: TextStyle(color: isWarn ? const Color(0xFFDC2626) : const Color(0xFF15803D), fontWeight: FontWeight.w800, fontSize: 10)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(event.description, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                const SizedBox(height: 4),
                                Text('Actor: ${event.actorName} (${event.actorId}) • Device: ${event.deviceInfo} • ${KcFormatters.dateTime(event.timestamp)}', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
