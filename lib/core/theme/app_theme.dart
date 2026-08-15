import 'package:flutter/material.dart';

import '../constants/color_tokens.dart';
import '../constants/typography_tokens.dart';
import 'dark_theme.dart';
import 'light_theme.dart';

/// Monochrome Architectural Minimalist (Swiss Style) ThemeData Builder.
abstract final class AppTheme {
  static ThemeData get light => _build(buildLightColorScheme(), Brightness.light);
  static ThemeData get dark => _build(buildDarkColorScheme(), Brightness.dark);

  static ThemeData _build(ColorScheme scheme, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final cardContainer = isDark ? KcColors.slate800 : KcColors.pureWhite;
    final surfaceSoft = isDark ? KcColors.slate900 : KcColors.slate50;
    final hairlineBorder = isDark ? KcColors.slate700 : KcColors.slate200;

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      textTheme: KcTypography.buildTextTheme(scheme),
      scaffoldBackgroundColor: surfaceSoft,
      canvasColor: scheme.surface,
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        iconTheme: IconThemeData(color: scheme.onSurface),
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: cardContainer,
        surfaceTintColor: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: hairlineBorder,
            width: 1.0,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? KcColors.carbon900 : KcColors.carbon50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(
            color: hairlineBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(
            color: hairlineBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(
            color: isDark ? KcColors.pureWhite : KcColors.pitchBlack,
            width: 1.5,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? KcColors.pureWhite : KcColors.pitchBlack,
          foregroundColor: isDark ? KcColors.pitchBlack : KcColors.pureWhite,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          textStyle: base.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
