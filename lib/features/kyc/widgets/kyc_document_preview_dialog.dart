import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/buttons/kc_outlined_button.dart';
import '../models/kyc_model.dart';
import '../providers/kyc_providers.dart';

class KycDocumentPreviewDialog extends ConsumerStatefulWidget {
  const KycDocumentPreviewDialog({
    super.key,
    required this.customerId,
    required this.document,
  });

  final String customerId;
  final KycDocumentModel document;

  @override
  ConsumerState<KycDocumentPreviewDialog> createState() => _KycDocumentPreviewDialogState();
}

class _KycDocumentPreviewDialogState extends ConsumerState<KycDocumentPreviewDialog> {
  double _rotationAngle = 0.0;
  bool _showBackSide = false;
  late bool _isMasked;

  @override
  void initState() {
    super.initState();
    _isMasked = widget.document.isMasked;
  }

  void _toggleMasking() {
    setState(() => _isMasked = !_isMasked);
    ref.read(kycRepositoryProvider).toggleDocumentMasking(
          customerId: widget.customerId,
          documentId: widget.document.id,
        );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.document.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text('${widget.document.type} • Uploaded by ${widget.document.uploadedBy}', style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.of(context).pop()),
              ],
            ),
            const Divider(height: 24),

            // Document Masking Banner & Reveal Interaction
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: scheme.outline.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(_isMasked ? Icons.lock_outline_rounded : Icons.lock_open_rounded, size: 18, color: _isMasked ? Colors.orange : Colors.green),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('PROTECTED SENSITIVE DOCUMENT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.orange)),
                        const SizedBox(height: 2),
                        Text(
                          'Number: ${_isMasked ? widget.document.maskedDocumentNumber : widget.document.documentNumber}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    icon: Icon(_isMasked ? Icons.visibility_rounded : Icons.visibility_off_rounded, size: 16),
                    label: Text(_isMasked ? 'Reveal Number' : 'Mask Number'),
                    onPressed: _toggleMasking,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Document Image View Container
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Transform.rotate(
                    angle: _rotationAngle,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _showBackSide ? Icons.credit_card_rounded : Icons.badge_rounded,
                          size: 96,
                          color: Colors.white70,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${widget.document.type} Mock Image (${_showBackSide ? "BACK SIDE" : "FRONT SIDE"})',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Size: ${widget.document.fileSize} • Sealed & Masked',
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Viewer Toolbar
            Row(
              children: [
                KcOutlinedButton(
                  label: _showBackSide ? 'Show Front' : 'Show Back',
                  icon: Icons.flip_rounded,
                  onPressed: () => setState(() => _showBackSide = !_showBackSide),
                ),
                const SizedBox(width: 8),
                KcOutlinedButton(
                  label: 'Rotate 90°',
                  icon: Icons.rotate_right_rounded,
                  onPressed: () => setState(() => _rotationAngle += 1.5708), // 90 degrees in radians
                ),
                const Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: scheme.primary, foregroundColor: scheme.onPrimary),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close Preview'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void showKycDocumentPreview(BuildContext context, String customerId, KycDocumentModel document) {
  showDialog(
    context: context,
    builder: (context) => KycDocumentPreviewDialog(customerId: customerId, document: document),
  );
}
