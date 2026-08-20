import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Single Primary Font Family (Plus Jakarta Sans) for KaratCore ERP.
abstract final class KcTypography {
  static TextTheme buildTextTheme(ColorScheme colorScheme) {
    final font = GoogleFonts.plusJakartaSansTextTheme();

    return font.copyWith(
      displayLarge: font.displayLarge?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w800,
        fontSize: 56,
        letterSpacing: -1.4,
        height: 1.05,
      ),
      displayMedium: font.displayMedium?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w800,
        fontSize: 42,
        letterSpacing: -1.1,
        height: 1.1,
      ),
      displaySmall: font.displaySmall?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w700,
        fontSize: 32,
        letterSpacing: -0.8,
        height: 1.15,
      ),
      headlineLarge: font.headlineLarge?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w700,
        fontSize: 28,
        letterSpacing: -0.6,
        height: 1.2,
      ),
      headlineMedium: font.headlineMedium?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w700,
        fontSize: 24,
        letterSpacing: -0.4,
        height: 1.25,
      ),
      headlineSmall: font.headlineSmall?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w600,
        fontSize: 20,
        letterSpacing: -0.3,
        height: 1.3,
      ),
      titleLarge: font.titleLarge?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w700,
        fontSize: 18,
        letterSpacing: -0.2,
      ),
      titleMedium: font.titleMedium?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w600,
        fontSize: 16,
        letterSpacing: -0.1,
      ),
      titleSmall: font.titleSmall?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      bodyLarge: font.bodyLarge?.copyWith(
        color: colorScheme.onSurface,
        fontSize: 16,
        height: 1.5,
      ),
      bodyMedium: font.bodyMedium?.copyWith(
        color: colorScheme.onSurface,
        fontSize: 14,
        height: 1.45,
      ),
      bodySmall: font.bodySmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
        fontSize: 12,
        height: 1.4,
      ),
      labelLarge: font.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 13,
        letterSpacing: 0.2,
      ),
      labelMedium: font.labelMedium?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 12,
        letterSpacing: 0.3,
      ),
      labelSmall: font.labelSmall?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 11,
        letterSpacing: 0.5,
      ),
    );
  }
}
