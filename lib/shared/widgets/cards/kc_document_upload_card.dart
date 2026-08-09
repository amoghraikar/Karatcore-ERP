import 'package:flutter/material.dart';
import '../../../core/constants/color_tokens.dart';
import 'kc_card.dart';

enum KcUploadStatus { idle, uploading, completed, error }

class KcDocumentUploadCard extends StatelessWidget {
  const KcDocumentUploadCard({
    super.key,
    required this.title,
    this.subtitle = 'PDF, PNG, JPG up to 10MB',
    this.status = KcUploadStatus.idle,
    this.progress = 0.0,
    this.fileName,
    this.fileSize,
    this.onUploadTap,
    this.onRemoveTap,
  });

  final String title;
  final String subtitle;
  final KcUploadStatus status;
  final double progress;
  final String? fileName;
  final String? fileSize;
  final VoidCallback? onUploadTap;
  final VoidCallback? onRemoveTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (status == KcUploadStatus.completed || status == KcUploadStatus.uploading) {
      return KcCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? KcColors.carbon800 : KcColors.carbon100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.description_outlined, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName ?? title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      if (fileSize != null)
                        Text(
                          fileSize!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                        ),
                    ],
                  ),
                ),
                if (onRemoveTap != null)
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    onPressed: onRemoveTap,
                    tooltip: 'Remove file',
                  ),
              ],
            ),
            if (status == KcUploadStatus.uploading) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
            ],
          ],
        ),
      );
    }

    return KcCard(
      onTap: onUploadTap,
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? KcColors.carbon800 : KcColors.carbon100,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cloud_upload_outlined, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
