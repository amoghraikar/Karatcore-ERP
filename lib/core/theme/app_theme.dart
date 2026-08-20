import 'package:flutter/material.dart';

import '../constants/color_tokens.dart';
import '../constants/typography_tokens.dart';
import 'dark_theme.dart';
import 'light_theme.dart';

/// Editorial Luxury ThemeData Builder for KaratCore ERP.
abstract final class AppTheme {
  static ThemeData get light => _build(buildLightColorScheme(), Brightness.light);
  static ThemeData get dark => _build(buildDarkColorScheme(), Brightness.dark);

  static ThemeData _build(ColorScheme scheme, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scaffoldBg = isDark ? KcColors.bgDark : KcColors.bgLight;
    final cardContainer = isDark ? KcColors.surfaceDark : KcColors.surfaceLight;
    final hairlineBorder = isDark ? KcColors.borderDark : KcColors.borderLight;

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      textTheme: KcTypography.buildTextTheme(scheme),
      scaffoldBackgroundColor: scaffoldBg,
      canvasColor: scaffoldBg,
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBg,
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
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: hairlineBorder,
            width: 1.0,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardContainer,
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
            color: KcColors.goldAccent,
            width: 1.5,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? KcColors.textPrimaryDark : KcColors.textPrimaryLight,
          foregroundColor: isDark ? KcColors.bgDark : KcColors.surfaceLight,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: base.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? KcColors.surfaceDark : KcColors.surfaceLight,
        deleteIconColor: scheme.onSurfaceVariant,
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
