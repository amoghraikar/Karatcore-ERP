import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/color_tokens.dart';

enum KaratBadgeVariant {
  neutral,
  gold,
  success,
  warning,
  danger,
  navy,
}

class KaratBadge extends StatelessWidget {
  const KaratBadge({
    super.key,
    required this.label,
    this.variant = KaratBadgeVariant.neutral,
    this.showDot = false,
    this.icon,
  });

  final String label;
  final KaratBadgeVariant variant;
  final bool showDot;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bg;
    Color fg;
    Color dotColor;

    switch (variant) {
      case KaratBadgeVariant.gold:
        bg = KcColors.goldSubdued;
        fg = KcColors.goldAccent;
        dotColor = KcColors.goldAccent;
        break;
      case KaratBadgeVariant.success:
        bg = KcColors.successSubdued;
        fg = KcColors.success;
        dotColor = KcColors.success;
        break;
      case KaratBadgeVariant.warning:
        bg = KcColors.warningSubdued;
        fg = KcColors.warning;
        dotColor = KcColors.warning;
        break;
      case KaratBadgeVariant.danger:
        bg = KcColors.dangerSubdued;
        fg = KcColors.danger;
        dotColor = KcColors.danger;
        break;
      case KaratBadgeVariant.navy:
        bg = KcColors.deepNavy;
        fg = KcColors.pureWhite;
        dotColor = KcColors.goldAccent;
        break;
      case KaratBadgeVariant.neutral:
        bg = isDark ? const Color(0x1FA0A0A0) : const Color(0x0F111214);
        fg = isDark ? KcColors.textSecondaryDark : KcColors.textSecondaryLight;
        dotColor = isDark ? KcColors.textSecondaryDark : KcColors.textSecondaryLight;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: fg.withValues(alpha: 0.15),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
