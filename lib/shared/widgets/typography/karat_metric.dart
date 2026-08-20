import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/color_tokens.dart';

class KaratMetric extends StatelessWidget {
  const KaratMetric({
    super.key,
    required this.label,
    required this.value,
    this.subtext,
    this.trend,
    this.isPositive = true,
    this.isOversized = false,
    this.onTap,
  });

  final String label;
  final String value;
  final String? subtext;
  final String? trend;
  final bool isPositive;
  final bool isOversized;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? KcColors.textPrimaryDark : KcColors.textPrimaryLight;
    final secondaryColor = isDark ? KcColors.textSecondaryDark : KcColors.textSecondaryLight;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label.toUpperCase(),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: secondaryColor,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: isOversized ? 44 : 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: isOversized ? -1.2 : -0.6,
                      height: 1.05,
                      color: primaryColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (trend != null) ...[
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isPositive ? KcColors.successSubdued : KcColors.dangerSubdued,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      trend!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isPositive ? KcColors.success : KcColors.danger,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (subtext != null) ...[
              const SizedBox(height: 4),
              Text(
                subtext!,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: secondaryColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
