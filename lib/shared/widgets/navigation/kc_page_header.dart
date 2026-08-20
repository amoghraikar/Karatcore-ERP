import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/color_tokens.dart';
import '../../../core/extensions/context_extensions.dart';

class KcPageHeader extends StatelessWidget {
  const KcPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    this.categoryTag,
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final String? categoryTag;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final tagText = (categoryTag ?? 'ENTERPRISE MODULE').toUpperCase();

    if (context.isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? KcColors.surfaceDark : KcColors.textPrimaryLight,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  tagText,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(width: 6),
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
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              fontSize: 24,
              letterSpacing: -0.6,
              color: isDark ? KcColors.textPrimaryDark : KcColors.textPrimaryLight,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: isDark ? KcColors.textSecondaryDark : scheme.onSurfaceVariant,
              ),
            ),
          ],
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: actions,
            ),
          ],
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark ? KcColors.surfaceDark : KcColors.textPrimaryLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      tagText,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: KcColors.goldAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                  letterSpacing: -0.8,
                  color: isDark ? KcColors.textPrimaryDark : KcColors.textPrimaryLight,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: isDark ? KcColors.textSecondaryDark : scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (actions.isNotEmpty) ...[
          const SizedBox(width: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < actions.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                actions[i],
              ],
            ],
          ),
        ],
      ],
    );
  }
}
