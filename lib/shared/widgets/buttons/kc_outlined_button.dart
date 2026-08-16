import 'package:flutter/material.dart';
import '../../../core/constants/color_tokens.dart';

class KcOutlinedButton extends StatelessWidget {
  const KcOutlinedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.fullWidth = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final btn = OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: isDark ? KcColors.obsidian900 : KcColors.pureWhite,
        foregroundColor: isDark ? KcColors.pureWhite : KcColors.slate900,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        side: BorderSide(
          color: isDark ? KcColors.obsidian800 : KcColors.slate300,
          width: 1.0,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: isDark ? KcColors.gold400 : KcColors.gold700),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: btn);
    }
    return btn;
  }
}
