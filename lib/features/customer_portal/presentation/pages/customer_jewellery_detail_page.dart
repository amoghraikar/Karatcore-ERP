import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/feedback/customer_access_restricted_page.dart';
import '../../providers/customer_portal_providers.dart';

class CustomerJewelleryDetailPage extends ConsumerWidget {
  const CustomerJewelleryDetailPage({super.key, required this.ornamentId});

  final String ornamentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(customerJewelleryDetailProvider(ornamentId));

    return itemAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, st) => CustomerAccessRestrictedPage(
        message: err.toString().replaceAll('Exception: ', ''),
      ),
      data: (item) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.go('/customer/jewellery'),
            ),
            title: Text('Jewellery Item #${item.id}'),
          ),
          body: ListView(
            padding: EdgeInsets.all(context.pageGutter),
            children: [
              KcCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF059669).withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.diamond_rounded, color: Color(0xFF059669), size: 32),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
                              const SizedBox(height: 2),
                              Text('Category: ${item.category.label} • Metal: ${item.metalType.label}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    const Text('Ornament Specifications', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 12),
                    _specRow('Asset ID', '#${item.id}'),
                    const Divider(),
                    _specRow('Metal Specification', item.metalType.label),
                    const Divider(),
                    _specRow('Purity Certification', item.purity.label),
                    const Divider(),
                    _specRow('Gross Weight', '${item.weight.grossWeight} grams'),
                    const Divider(),
                    _specRow('Deduction Weight', '${item.weight.stoneWeight + item.weight.otherWeight} grams'),
                    const Divider(),
                    _specRow('Net Precious Weight', '${item.weight.netMetalWeight} grams'),
                    const Divider(),
                    _specRow('Vault Storage Status', 'Secured in Vault Storage'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _specRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ),
    );
  }
}
