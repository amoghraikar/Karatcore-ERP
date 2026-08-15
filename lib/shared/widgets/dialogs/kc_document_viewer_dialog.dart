import 'package:flutter/material.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../features/customers/models/customer_model.dart';
import '../buttons/kc_outlined_button.dart';
import '../buttons/kc_primary_button.dart';
import '../feedback/kc_status_badge.dart';

class KcDocumentViewerDialog extends StatelessWidget {
  const KcDocumentViewerDialog({
    super.key,
    required this.customerName,
    required this.customerId,
    required this.document,
  });

  final String customerName;
  final String customerId;
  final CustomerDocument document;

  static void show(
    BuildContext context, {
    required String customerName,
    required String customerId,
    required CustomerDocument document,
  }) {
    showDialog(
      context: context,
      builder: (context) => KcDocumentViewerDialog(
        customerName: customerName,
        customerId: customerId,
        document: document,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 720,
        constraints: const BoxConstraints(maxHeight: 720),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Bar
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.folder_shared_rounded, color: scheme.primary, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        document.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Customer: $customerName ($customerId) • Uploaded ${KcFormatters.date(document.uploadDate)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                KcStatusBadge(
                  label: document.isVerified ? 'VERIFIED' : 'PENDING REVIEW',
                  statusColor: document.isVerified ? const Color(0xFF059669) : Colors.orange,
                  icon: document.isVerified ? Icons.verified_rounded : Icons.hourglass_top_rounded,
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Main Document Preview Canvas & Metadata Info Split
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: Document Visual Scan Mockup
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                document.documentType.toLowerCase().contains('pan')
                                    ? Icons.credit_card_rounded
                                    : Icons.badge_rounded,
                                size: 80,
                                color: Colors.white70,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                document.name.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white12,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'GOVERNMENT OF INDIA • ${document.documentNumber}',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 12,
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF059669).withValues(alpha: 0.2),
                                  border: Border.all(color: const Color(0xFF059669)),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.verified_user_rounded, color: Color(0xFF10B981), size: 16),
                                    SizedBox(width: 6),
                                    Text(
                                      'TAMPER-EVIDENT VERIFIED SCAN',
                                      style: TextStyle(
                                        color: Color(0xFF10B981),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),

                  // Right: Metadata Details Sidebar
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Document Vault Details',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 14),
                          _buildDetailRow('Document ID', document.id),
                          _buildDetailRow('Category', document.documentType),
                          _buildDetailRow('Masked ID', document.documentNumber),
                          _buildDetailRow('Upload Date', KcFormatters.date(document.uploadDate)),
                          _buildDetailRow('File Size', document.fileSize),
                          _buildDetailRow('Status', document.status),
                          _buildDetailRow('Storage Bucket', 'karatcore-kyc-documents'),
                          const Spacer(),
                          const Divider(),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.shield_rounded, size: 16, color: Color(0xFF059669)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'UIDAI & Reserve Bank Compliant Masking',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Footer Action Buttons
            Row(
              children: [
                KcOutlinedButton(
                  label: 'Download Original File',
                  icon: Icons.download_rounded,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Downloading ${document.name} to local device...')),
                    );
                  },
                ),
                const SizedBox(width: 12),
                KcOutlinedButton(
                  label: 'Print Copy',
                  icon: Icons.print_rounded,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Preparing print job for ${document.name}...')),
                    );
                  },
                ),
                const Spacer(),
                KcPrimaryButton(
                  label: 'Close Document Viewer',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(key, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
