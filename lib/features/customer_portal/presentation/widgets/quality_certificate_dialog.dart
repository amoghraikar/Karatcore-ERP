import 'package:flutter/material.dart';
import '../../../../shared/widgets/buttons/kc_outlined_button.dart';
import '../../../../shared/widgets/buttons/kc_primary_button.dart';
import '../../../../shared/widgets/feedback/kc_toast.dart';
import '../../../ornaments/models/ornament_model.dart';


class QualityCertificateDialog extends StatelessWidget {
  const QualityCertificateDialog({
    super.key,
    required this.ornament,
  });

  final OrnamentModel ornament;

  static void show(BuildContext context, OrnamentModel ornament) {
    showDialog(
      context: context,
      builder: (ctx) => QualityCertificateDialog(ornament: ornament),
    );
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final certNo = 'CERT-BIS-${ornament.id.toUpperCase()}';
    final isGold = ornament.metalType.label.toLowerCase().contains('gold');
    final accentColor = isGold ? const Color(0xFFD97706) : const Color(0xFF64748B);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: EdgeInsets.zero,
      content: Container(
        width: 580,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF18181B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accentColor.withValues(alpha: 0.3), width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Certificate Top Header Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.verified_rounded, color: accentColor, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'BIS HALLMARK CERTIFICATE OF PURITY',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
                        ),
                        Text(
                          'KaratCore Certified Safe Vault Storage',
                          style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF059669).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF059669)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 14),
                      SizedBox(width: 4),
                      Text(
                        'BIS VERIFIED',
                        style: TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.w800, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),

            // Ornament & Assayer Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Certificate Serial No.', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        Text(certNo, style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w800, fontSize: 14, color: accentColor)),
                        const SizedBox(height: 8),
                        Text('Ornament Name', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        Text(ornament.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('BIS Reg. No.', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      const Text('BIS-HM-MH-400002', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                      const SizedBox(height: 8),
                      Text('Assayer / Appraiser', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      const Text('Govt Approved Assayer #982', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Key Specs Grid
            Text('Technical Assay Specifications', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSpecTile(context, 'Metal Type', ornament.metalType.label),
                ),
                Expanded(
                  child: _buildSpecTile(context, 'Certified Purity', '${ornament.purity.label} (${ornament.purity.description})'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildSpecTile(context, 'Gross Weight', '${ornament.weight.grossWeight}g'),
                ),
                Expanded(
                  child: _buildSpecTile(context, 'Net Gold Weight', '${ornament.weight.netMetalWeight}g', highlight: true),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildSpecTile(context, 'Appraised Valuation', '₹${ornament.valuation.totalEstimatedValue.toStringAsFixed(2)}'),
                ),
                Expanded(
                  child: _buildSpecTile(context, 'Vault Security Tag', ornament.location.fullLocationPath),
                ),

              ],
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: KcOutlinedButton(
                    label: 'PRINT CERTIFICATE',
                    icon: Icons.print_rounded,
                    onPressed: () {
                      KcToast.show(context, message: 'Sending quality certificate to printer...', type: KcToastType.info);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: KcPrimaryButton(
                    label: 'DOWNLOAD PDF',
                    icon: Icons.download_rounded,
                    onPressed: () {
                      KcToast.show(context, message: 'Quality Certificate PDF downloaded to device!', type: KcToastType.success);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecTile(BuildContext context, String label, String value, {bool highlight = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: highlight
            ? const Color(0xFF7C3AED).withValues(alpha: 0.1)
            : (isDark ? const Color(0xFF27272A) : const Color(0xFFFAFAFA)),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: highlight ? const Color(0xFF7C3AED) : Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: highlight ? const Color(0xFF7C3AED) : null,
            ),
          ),
        ],
      ),
    );
  }
}
