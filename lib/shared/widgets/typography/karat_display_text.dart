import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/color_tokens.dart';

enum KaratDisplaySize {
  display, // 48-72px
  h1,      // 32-48px
  h2,      // 22-28px
  h3,      // 18-22px
}

class KaratDisplayText extends StatelessWidget {
  const KaratDisplayText(
    this.text, {
    super.key,
    this.size = KaratDisplaySize.h1,
    this.color,
    this.fontWeight = FontWeight.w800,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
    this.accentDot = false,
  });

  final String text;
  final KaratDisplaySize size;
  final Color? color;
  final FontWeight fontWeight;
  final int? maxLines;
  final TextOverflow overflow;
  final bool accentDot;

  double _getFontSize() {
    switch (size) {
      case KaratDisplaySize.display:
        return 52;
      case KaratDisplaySize.h1:
        return 36;
      case KaratDisplaySize.h2:
        return 24;
      case KaratDisplaySize.h3:
        return 20;
    }
  }

  double _getLetterSpacing() {
    switch (size) {
      case KaratDisplaySize.display:
        return -1.4;
      case KaratDisplaySize.h1:
        return -1.0;
      case KaratDisplaySize.h2:
        return -0.5;
      case KaratDisplaySize.h3:
        return -0.3;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = color ?? (isDark ? KcColors.textPrimaryDark : KcColors.textPrimaryLight);
    final fontSize = _getFontSize();
    final letterSpacing = _getLetterSpacing();

    if (!accentDot) {
      return Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: fontSize,
          fontWeight: fontWeight,
          letterSpacing: letterSpacing,
          height: 1.1,
          color: defaultColor,
        ),
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    return RichText(
      maxLines: maxLines,
      overflow: overflow,
      text: TextSpan(
        style: GoogleFonts.plusJakartaSans(
          fontSize: fontSize,
          fontWeight: fontWeight,
          letterSpacing: letterSpacing,
          height: 1.1,
          color: defaultColor,
        ),
        children: [
          TextSpan(text: text),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Container(
              width: fontSize * 0.16,
              height: fontSize * 0.16,
              margin: EdgeInsets.only(left: fontSize * 0.12),
              decoration: const BoxDecoration(
                color: KcColors.goldAccent,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
