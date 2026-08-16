import 'package:flutter/material.dart';

import '../constants/color_tokens.dart';
import '../constants/typography_tokens.dart';
import 'dark_theme.dart';
import 'light_theme.dart';

/// Luxury Champagne Obsidian & Satin Gold ThemeData Builder.
abstract final class AppTheme {
  static ThemeData get light => _build(buildLightColorScheme(), Brightness.light);
  static ThemeData get dark => _build(buildDarkColorScheme(), Brightness.dark);

  static ThemeData _build(ColorScheme scheme, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final cardContainer = isDark ? KcColors.obsidian900 : KcColors.pureWhite;
    final surfaceSoft = isDark ? KcColors.obsidian950 : KcColors.slate50;
    final hairlineBorder = isDark ? KcColors.obsidian800 : KcColors.slate200;

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      textTheme: KcTypography.buildTextTheme(scheme),
      scaffoldBackgroundColor: surfaceSoft,
      canvasColor: isDark ? KcColors.obsidian950 : scheme.surface,
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
          fontWeight: FontWeight.w800,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: cardContainer,
        surfaceTintColor: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: hairlineBorder,
            width: 1.0,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? KcColors.obsidian900 : KcColors.slate50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: hairlineBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: hairlineBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: KcColors.gold500,
            width: 1.5,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: KcColors.gold500,
          foregroundColor: KcColors.obsidian950,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: base.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? KcColors.obsidian850 : KcColors.slate100,
        deleteIconColor: isDark ? KcColors.slate400 : KcColors.slate600,
        side: BorderSide(color: hairlineBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: scheme.onSurface),
      ),
      dividerTheme: DividerThemeData(
        color: hairlineBorder,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
