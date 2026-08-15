import 'package:flutter/material.dart';
import '../constants/color_tokens.dart';

ColorScheme buildDarkColorScheme() => const ColorScheme.dark(
      primary: KcColors.gold500,
      onPrimary: KcColors.slate950,
      primaryContainer: KcColors.slate800,
      onPrimaryContainer: KcColors.gold300,
      secondary: KcColors.emerald500,
      onSecondary: KcColors.slate950,
      secondaryContainer: KcColors.slate800,
      onSecondaryContainer: KcColors.emerald100,
      tertiary: KcColors.gold400,
      onTertiary: KcColors.slate950,
      tertiaryContainer: Color(0xFF271F0C),
      onTertiaryContainer: KcColors.gold300,
      error: Color(0xFFF87171),
      onError: KcColors.pitchBlack,
      errorContainer: Color(0xFF450A0A),
      onErrorContainer: Color(0xFFFECACA),
      surface: KcColors.slate900,
      onSurface: KcColors.pureWhite,
      surfaceContainerHighest: KcColors.slate800,
      onSurfaceVariant: KcColors.slate300,
      outline: KcColors.slate700,
      outlineVariant: KcColors.slate800,
      shadow: Color(0x66000000),
      scrim: Color(0x66000000),
    );
