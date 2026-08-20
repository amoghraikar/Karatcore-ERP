import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/color_tokens.dart';

class KcMetricCard extends StatelessWidget {
  const KcMetricCard({
    super.key,
    required this.title,
    required this.value,
    this.trend,
    this.isPositiveTrend = true,
    this.icon,
    this.iconColor,
    this.onTap,
  });

  final String title;
  final String value;
  final String? trend;
  final bool isPositiveTrend;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? KcColors.surfaceDark : KcColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? KcColors.borderDark : KcColors.borderLight,
          width: 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              title.toUpperCase(),
                              style: GoogleFonts.plusJakartaSans(
                                color: isDark ? KcColors.textSecondaryDark : KcColors.textSecondaryLight,
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                                letterSpacing: 0.8,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: KcColors.goldAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (icon != null)
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0x0AFFFFFF) : const Color(0x08111214),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isDark ? KcColors.borderDark : KcColors.borderLight,
                          ),
                        ),
                        child: Icon(icon, size: 14, color: iconColor ?? (isDark ? KcColors.textPrimaryDark : KcColors.textPrimaryLight)),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    letterSpacing: -0.6,
                    color: isDark ? KcColors.textPrimaryDark : KcColors.textPrimaryLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (trend != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        isPositiveTrend ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                        size: 13,
                        color: isPositiveTrend ? KcColors.success : KcColors.danger,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          trend!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            color: isPositiveTrend ? KcColors.success : KcColors.danger,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
