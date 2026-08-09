import 'package:flutter/material.dart';
import '../../core/config/app_constants.dart';

/// Reusable Brand Mark Component for KaratCore ERP.
/// Displays the official KaratCore diamond emblem asset cleanly without cropping.
class KcBrandMark extends StatelessWidget {
  const KcBrandMark({
    super.key,
    this.size = 38,
    this.showWordmark = true,
    this.wordmark,
    this.subtitle,
    this.useFullLogo = false,
  });

  final double size;
  final bool showWordmark;
  final String? wordmark;
  final String? subtitle;
  final bool useFullLogo;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    if (useFullLogo) {
      final fullPath = isDark ? AppConstants.logoFullWhite : AppConstants.logoFullDark;
      return Image.asset(
        fullPath,
        height: size,
        fit: BoxFit.contain,
      );
    }

    final assetPath = isDark ? AppConstants.logoWhite : AppConstants.logoDark;

    // Render emblem uncropped with slight padding for outer rays
    final emblemWidget = SizedBox(
      width: size,
      height: size,
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Image.asset(
          assetPath,
          width: size,
          height: size,
          fit: BoxFit.contain,
          alignment: Alignment.center,
        ),
      ),
    );

    if (!showWordmark) return emblemWidget;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        emblemWidget,
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                wordmark ?? 'KaratCore',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      height: 1.1,
                      color: scheme.onSurface,
                    ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontSize: 9,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
