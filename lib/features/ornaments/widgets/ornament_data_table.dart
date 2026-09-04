import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/feedback/kc_status_badge.dart';

import '../models/ornament_model.dart';
import 'barcode_qr_dialog.dart';
import 'ornament_status_chip.dart';
import 'transfer_ornament_dialog.dart';

class OrnamentDataTable extends ConsumerWidget {
  const OrnamentDataTable({
    super.key,
    required this.ornaments,
  });

  final List<OrnamentModel> ornaments;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    if (!context.isDesktop) {
      return Column(
        children: ornaments.map((o) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: KcCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: Image.asset(
                            o.category.assetImage,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: scheme.surfaceContainerHighest,
                              child: Icon(o.category.icon, size: 24, color: scheme.primary),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(o.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15), overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            Text('${o.id} • ${o.purity.label}', style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                          ],
                        ),
                      ),
                      OrnamentStatusChip(status: o.status),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      KcStatusBadge(label: 'Gross: ${o.weight.grossWeight}g', statusColor: scheme.primary),
                      KcStatusBadge(label: 'Net Metal: ${o.weight.netMetalWeight}g', statusColor: const Color(0xFF059669)),
                      KcStatusBadge(label: KcFormatters.inr(o.valuation.totalEstimatedValue), statusColor: scheme.onSurfaceVariant),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(o.location.locker, style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                      OutlinedButton(
                        onPressed: () => context.go('/inventory/${o.id}'),
                        child: const Text('View Details'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    }

    return KcCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
              border: Border(bottom: BorderSide(color: scheme.outline.withValues(alpha: 0.3))),
            ),
            child: const Row(
              children: [
                Expanded(flex: 3, child: Text('Ornament Asset', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
                Expanded(flex: 2, child: Text('Metal & Purity', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
                Expanded(flex: 2, child: Text('Weight Breakdown', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
                Expanded(flex: 2, child: Text('Status & Owner', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
                Expanded(flex: 2, child: Text('Est. Value (INR)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
                Expanded(flex: 2, child: Text('Vault Location', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
                SizedBox(width: 140, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13), textAlign: TextAlign.center)),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: ornaments.length,
            separatorBuilder: (context, index) => Divider(height: 1, color: scheme.outline.withValues(alpha: 0.15)),
            itemBuilder: (context, index) {
              final o = ornaments[index];

              return InkWell(
                onTap: () => context.go('/inventory/${o.id}'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox(
                                width: 44,
                                height: 44,
                                child: Image.asset(
                                  o.category.assetImage,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: scheme.surfaceContainerHighest,
                                    child: Icon(o.category.icon, size: 20, color: scheme.primary),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(o.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14), overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 2),
                                  Text('${o.id} • ${o.category.label}', style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(o.metalType.label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: o.metalType.color)),
                            const SizedBox(height: 2),
                            Text(o.purity.label, style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Gross: ${o.weight.grossWeight}g', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                            const SizedBox(height: 2),
                            Text('Net: ${o.weight.netMetalWeight}g', style: const TextStyle(fontSize: 11, color: Color(0xFF059669), fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            OrnamentStatusChip(status: o.status),
                            if (o.ownerCustomerName != null) ...[
                              const SizedBox(height: 4),
                              Text(o.ownerCustomerName!, style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant), overflow: TextOverflow.ellipsis),
                            ],
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(KcFormatters.inr(o.valuation.totalEstimatedValue), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(o.location.branch, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12), overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            Text('${o.location.locker} • ${o.location.tray}', style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 140,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.qr_code_2_rounded, size: 18),
                              tooltip: 'Barcode & QR Tag',
                              onPressed: () => showBarcodeQrDialog(context, o),
                            ),
                            IconButton(
                              icon: const Icon(Icons.sync_alt_rounded, size: 18),
                              tooltip: 'Vault Transfer',
                              onPressed: () => showTransferOrnamentDialog(context, o),
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right_rounded, size: 20),
                              tooltip: 'View Details',
                              onPressed: () => context.go('/inventory/${o.id}'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
