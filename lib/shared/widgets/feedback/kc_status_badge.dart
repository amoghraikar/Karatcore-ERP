import 'package:flutter/material.dart';
import '../../../core/constants/color_tokens.dart';

enum KcBadgeType { success, warning, error, info }
typedef KcStatusType = KcBadgeType;

class KcStatusBadge extends StatelessWidget {
  const KcStatusBadge({
    super.key,
    required this.label,
    this.type = KcBadgeType.info,
    this.statusColor,
    this.icon,
  });

  final String label;
  final KcBadgeType type;
  final Color? statusColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Color border;

    if (statusColor != null) {
      bg = statusColor!.withValues(alpha: 0.12);
      fg = statusColor!;
      border = statusColor!.withValues(alpha: 0.3);
    } else {
      switch (type) {
        case KcBadgeType.success:
          bg = KcColors.emerald500.withValues(alpha: 0.12);
          fg = KcColors.emerald600;
          border = KcColors.emerald500.withValues(alpha: 0.3);
          break;
        case KcBadgeType.warning:
          bg = KcColors.gold500.withValues(alpha: 0.16);
          fg = KcColors.warning;
          border = KcColors.gold500.withValues(alpha: 0.4);
          break;
        case KcBadgeType.error:
          bg = KcColors.danger.withValues(alpha: 0.12);
          fg = KcColors.danger;
          border = KcColors.danger.withValues(alpha: 0.3);
          break;
        case KcBadgeType.info:
          bg = KcColors.info.withValues(alpha: 0.12);
          fg = KcColors.info;
          border = KcColors.info.withValues(alpha: 0.3);
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
