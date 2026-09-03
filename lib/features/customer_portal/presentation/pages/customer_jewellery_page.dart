import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/feedback/kc_empty_state.dart';
import '../../../../shared/widgets/feedback/kc_error_state.dart';
import '../../providers/customer_portal_providers.dart';

import '../../../../core/localization/app_localizations.dart';
import '../widgets/quality_certificate_dialog.dart';

class CustomerJewelleryPage extends ConsumerStatefulWidget {
  const CustomerJewelleryPage({super.key});

  @override
  ConsumerState<CustomerJewelleryPage> createState() => _CustomerJewelleryPageState();
}

class _CustomerJewelleryPageState extends ConsumerState<CustomerJewelleryPage> {
  String _selectedMetal = 'All';

  @override
  Widget build(BuildContext context) {
    final jewelleryAsync = ref.watch(customerJewelleryProvider);

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(context.pageGutter),
        children: [
          Text(
            context.tr('my_pledged_ornaments'),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'View gold & silver ornaments pledged in safe vault storage',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 20),

          // Metal Filter Chips
          Row(
            children: ['All', 'Gold', 'Silver'].map((metal) {
              final isSelected = _selectedMetal == metal;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(metal),
                  selected: isSelected,
                  onSelected: (val) => setState(() => _selectedMetal = metal),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          jewelleryAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, st) => KcErrorState(message: err.toString()),
            data: (items) {
              final filtered = items.where((i) {
                if (_selectedMetal == 'Gold') return i.metalType.label.toLowerCase().contains('gold');
                if (_selectedMetal == 'Silver') return i.metalType.label.toLowerCase().contains('silver');
                return true;
              }).toList();

              if (filtered.isEmpty) {
                return const KcEmptyState(
                  title: 'No Pledged Jewellery Found',
                  subtitle: 'You do not have any pledged ornaments matching the selected filter.',
                  icon: Icons.diamond_outlined,
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: context.isDesktop ? 3 : (context.isTablet ? 2 : 1),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemCount: filtered.length,
                itemBuilder: (ctx, idx) {
                  final item = filtered[idx];
                  return KcCard(
                    padding: const EdgeInsets.all(16),
                    child: InkWell(
                      onTap: () => context.go('/customer/jewellery/${item.id}'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF059669).withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.diamond_rounded, color: Color(0xFF059669), size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                                    Text('ID: #${item.id}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF059669).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(context.tr('vault_secure'), style: const TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.w800, fontSize: 9)),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(context.tr('purity'), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                  Text('${item.metalType.label} (${item.purity.label})', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(context.tr('net_weight'), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                  Text('${item.weight.netMetalWeight}g', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF7C3AED))),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => QualityCertificateDialog.show(context, item),
                              icon: const Icon(Icons.verified_rounded, size: 16, color: Color(0xFFD97706)),
                              label: Text(
                                context.tr('view_certificate'),
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFD97706)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

