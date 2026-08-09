import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/cards/kc_metric_card.dart';
import '../../../staff/providers/staff_providers.dart';

class SecurityDashboardPage extends ConsumerWidget {
  const SecurityDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(securityEventsProvider);

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(context.pageGutter),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Security & Device Monitor', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text('Store Owner session monitoring, device authorizations & login history', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
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
                  title: 'Active Session',
                  value: '1 Connected',
                  trend: 'macOS Web Terminal',
                  icon: Icons.devices_rounded,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: KcMetricCard(
                  title: 'Encryption Standard',
                  value: 'TLS 1.3 / AES-256',
                  trend: 'Zero Security Incidents',
                  icon: Icons.security_rounded,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: KcMetricCard(
                  title: 'Authentication Status',
                  value: 'Owner Verified',
                  trend: 'Biometric Ready',
                  icon: Icons.fingerprint_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          KcCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Active Owner Session', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: const Color(0xFF059669).withValues(alpha: 0.15), shape: BoxShape.circle),
                    child: const Icon(Icons.laptop_mac_rounded, color: Color(0xFF059669)),
                  ),
                  title: const Text('MacBook Pro 16" (Current Device)', style: TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: const Text('macOS Chrome • IP: 192.168.1.45 • Session Active'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFF059669).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                    child: const Text('THIS SESSION', style: TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.w800, fontSize: 11)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          eventsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, st) => Text('Error loading security events: $err'),
            data: (events) {
              return KcCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Security Event Log (${events.length})', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 16),
                    ...events.map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Icon(
                                e.status == 'SUCCESS' ? Icons.check_circle_rounded : Icons.warning_rounded,
                                color: e.status == 'SUCCESS' ? const Color(0xFF059669) : const Color(0xFFD97706),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${e.eventType} — ${e.description}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                    Text('${e.actorName} • ${e.deviceInfo} • ${KcFormatters.date(e.timestamp)}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
