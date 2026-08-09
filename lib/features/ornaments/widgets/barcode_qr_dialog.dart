import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/buttons/kc_outlined_button.dart';
import '../models/ornament_model.dart';
import '../providers/inventory_providers.dart';

class BarcodeQrDialog extends ConsumerWidget {
  const BarcodeQrDialog({
    super.key,
    required this.ornament,
  });

  final OrnamentModel ornament;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final barcodeService = ref.watch(barcodeServiceProvider);
    final barcodeVal = barcodeService.generateBarcode(ornament.id);
    final qrVal = barcodeService.generateQrCode(ornament.id);
    final scheme = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Barcode & QR Tag Identity', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text('${ornament.name} (${ornament.id})', style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                  ],
                ),
                IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.of(context).pop()),
              ],
            ),
            const Divider(height: 24),

            // Barcode Display Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  const Text('STORES BARCODE TAG', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Container(
                    height: 48,
                    width: 280,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    alignment: Alignment.center,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        VerticalDivider(color: Colors.white, thickness: 2, indent: 4, endIndent: 4),
                        VerticalDivider(color: Colors.white, thickness: 4, indent: 4, endIndent: 4),
                        VerticalDivider(color: Colors.white, thickness: 1, indent: 4, endIndent: 4),
                        VerticalDivider(color: Colors.white, thickness: 5, indent: 4, endIndent: 4),
                        VerticalDivider(color: Colors.white, thickness: 2, indent: 4, endIndent: 4),
                        VerticalDivider(color: Colors.white, thickness: 3, indent: 4, endIndent: 4),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(barcodeVal, style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 2, color: Colors.black, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // QR Code Display Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.qr_code_2_rounded, size: 64, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('DIGITAL ASSET QR TAG', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(qrVal, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.black)),
                        const SizedBox(height: 4),
                        Text('${ornament.purity.label} • ${ornament.weight.grossWeight}g Gross', style: const TextStyle(fontSize: 11, color: Colors.black87)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Action buttons
            Row(
              children: [
                KcOutlinedButton(
                  label: 'Print Tag',
                  icon: Icons.print_rounded,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Print job sent to thermal tag printer.')));
                  },
                ),
                const SizedBox(width: 8),
                KcOutlinedButton(
                  label: 'Download QR',
                  icon: Icons.download_rounded,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('QR code asset downloaded.')));
                  },
                ),
                const Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: scheme.primary, foregroundColor: scheme.onPrimary),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void showBarcodeQrDialog(BuildContext context, OrnamentModel ornament) {
  showDialog(
    context: context,
    builder: (context) => BarcodeQrDialog(ornament: ornament),
  );
}
