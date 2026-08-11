import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/feedback/kc_error_state.dart';
import '../../providers/customer_portal_providers.dart';

class CustomerKycPage extends ConsumerWidget {
  const CustomerKycPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(customerProfileProvider);

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(context.pageGutter),
        children: [
          Text(
            'KYC Verification & Identity',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'RBI compliant Know-Your-Customer verification status & identity document records',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),

          // Status Banner
          profileAsync.when(
            loading: () => const SizedBox(),
            error: (err, st) => KcErrorState(message: err.toString()),
            data: (profile) {
              final isVerified = profile?.kycStatus.name == 'verified';

              return KcCard(
                padding: const EdgeInsets.all(20),
                color: isVerified ? const Color(0xFFF0FDF4) : const Color(0xFFFFFBEB),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isVerified ? const Color(0xFF059669).withValues(alpha: 0.15) : const Color(0xFFD97706).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isVerified ? Icons.verified_user_rounded : Icons.pending_actions_rounded,
                        color: isVerified ? const Color(0xFF059669) : const Color(0xFFD97706),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isVerified ? 'KYC VERIFIED — LEVEL 2 ENHANCED' : 'KYC PENDING REVIEW',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: isVerified ? const Color(0xFF064E3B) : const Color(0xFF78350F),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isVerified
                                ? 'Your identity and address proof are fully verified by KaratCore Store Owner.'
                                : 'Your submitted identity documents are currently under review.',
                            style: TextStyle(
                              fontSize: 12,
                              color: isVerified ? const Color(0xFF065F46) : const Color(0xFF92400E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Masked Identity Records Card
          profileAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const SizedBox(),
            data: (profile) {
              if (profile == null) return const SizedBox();

              return KcCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Verified Identity Records (Masked)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 4),
                    const Text('For privacy protection, full Aadhaar and PAN numbers are masked.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 16),
                    _identityRow('PAN Card Verification', profile.panNumberPlaceholder.isEmpty ? 'ABCPS****F' : profile.panNumberPlaceholder),
                    const Divider(),
                    _identityRow('Aadhaar Unique ID', profile.aadhaarNumberPlaceholder.isEmpty ? 'XXXX-XXXX-8821' : profile.aadhaarNumberPlaceholder),
                    const Divider(),
                    _identityRow('Customer ID Ref', profile.id),
                    const Divider(),
                    _identityRow('Verification Date', KcFormatters.date(profile.createdAt)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _identityRow(String label, String maskedValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Row(
            children: [
              const Icon(Icons.lock_outline_rounded, size: 14, color: Color(0xFF059669)),
              const SizedBox(width: 6),
              Text(maskedValue, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 1.1)),
            ],
          ),
        ],
      ),
    );
  }
}
