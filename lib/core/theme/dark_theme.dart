import 'package:flutter/material.dart';
import '../constants/color_tokens.dart';

ColorScheme buildDarkColorScheme() => const ColorScheme.dark(
      primary: KcColors.gold500,
      onPrimary: KcColors.obsidian950,
      primaryContainer: Color(0xFF271F0C),
      onPrimaryContainer: KcColors.gold300,
      secondary: KcColors.emerald500,
      onSecondary: KcColors.obsidian950,
      secondaryContainer: Color(0xFF064E3B),
      onSecondaryContainer: KcColors.emerald100,
      tertiary: KcColors.gold400,
      onTertiary: KcColors.obsidian950,
      tertiaryContainer: Color(0xFF271F0C),
      onTertiaryContainer: KcColors.gold300,
      error: Color(0xFFEF4444),
      onError: KcColors.pureWhite,
      errorContainer: Color(0xFF450A0A),
      onErrorContainer: Color(0xFFFECACA),
      surface: KcColors.obsidian900,
      onSurface: KcColors.pureWhite,
      surfaceContainerHighest: KcColors.obsidian850,
      onSurfaceVariant: KcColors.slate400,
      outline: KcColors.obsidian800,
      outlineVariant: KcColors.obsidian700,
      shadow: Color(0x99000000),
      scrim: Color(0x99000000),
    );
