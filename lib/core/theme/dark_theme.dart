import 'package:flutter/material.dart';
import '../constants/color_tokens.dart';

ColorScheme buildDarkColorScheme() => const ColorScheme.dark(
      primary: KcColors.textPrimaryDark,
      onPrimary: KcColors.bgDark,
      primaryContainer: Color(0xFF22252C),
      onPrimaryContainer: KcColors.textPrimaryDark,
      secondary: KcColors.goldAccent,
      onSecondary: KcColors.bgDark,
      secondaryContainer: KcColors.goldSubdued,
      onSecondaryContainer: KcColors.goldLight,
      tertiary: KcColors.success,
      onTertiary: KcColors.bgDark,
      tertiaryContainer: KcColors.successSubdued,
      onTertiaryContainer: KcColors.success,
      error: KcColors.danger,
      onError: KcColors.pureWhite,
      errorContainer: KcColors.dangerSubdued,
      onErrorContainer: Color(0xFFFCA5A5),
      surface: KcColors.surfaceDark,
      onSurface: KcColors.textPrimaryDark,
      surfaceContainerHighest: Color(0xFF23262D),
      onSurfaceVariant: KcColors.textSecondaryDark,
      outline: KcColors.borderDark,
      outlineVariant: Color(0x14FFFFFF),
      shadow: Color(0x66000000),
      scrim: Color(0x99000000),
    );
