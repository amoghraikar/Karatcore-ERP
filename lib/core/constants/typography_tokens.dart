import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Monochrome Architectural Minimalist Typography for KaratCore ERP.
abstract final class KcTypography {
  static TextTheme buildTextTheme(ColorScheme colorScheme) {
    final bodyFont = GoogleFonts.interTextTheme();
    final architecturalFont = GoogleFonts.spaceGroteskTextTheme();

    return bodyFont.copyWith(
      displayLarge: architecturalFont.displayLarge?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w700,
        fontSize: 48,
        letterSpacing: -1.0,
      ),
      displayMedium: architecturalFont.displayMedium?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w700,
        fontSize: 38,
        letterSpacing: -0.8,
      ),
      displaySmall: architecturalFont.displaySmall?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w700,
        fontSize: 30,
        letterSpacing: -0.5,
      ),
      headlineLarge: architecturalFont.headlineLarge?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w700,
        fontSize: 26,
        letterSpacing: -0.4,
      ),
      headlineMedium: architecturalFont.headlineMedium?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w700,
        fontSize: 22,
        letterSpacing: -0.3,
      ),
      headlineSmall: architecturalFont.headlineSmall?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w600,
        fontSize: 18,
        letterSpacing: -0.2,
      ),
      titleLarge: bodyFont.titleLarge?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w700,
        fontSize: 17,
        letterSpacing: -0.1,
      ),
      titleMedium: bodyFont.titleMedium?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w600,
        fontSize: 15,
      ),
      titleSmall: bodyFont.titleSmall?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      bodyLarge: bodyFont.bodyLarge?.copyWith(
        color: colorScheme.onSurface,
        fontSize: 15,
      ),
      bodyMedium: bodyFont.bodyMedium?.copyWith(
        color: colorScheme.onSurface,
        fontSize: 13,
      ),
      bodySmall: bodyFont.bodySmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
        fontSize: 11,
      ),
      labelLarge: bodyFont.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 13,
        letterSpacing: 0.5,
      ),
      labelMedium: bodyFont.labelMedium?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 11,
        letterSpacing: 0.5,
      ),
      labelSmall: bodyFont.labelSmall?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 10,
        letterSpacing: 0.8,
      ),
    );
  }
}
