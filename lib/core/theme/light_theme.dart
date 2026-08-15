import 'package:flutter/material.dart';
import '../constants/color_tokens.dart';

ColorScheme buildLightColorScheme() => const ColorScheme.light(
      primary: KcColors.navy900,
      onPrimary: KcColors.pureWhite,
      primaryContainer: KcColors.navy50,
      onPrimaryContainer: KcColors.navy900,
      secondary: KcColors.gold600,
      onSecondary: KcColors.pureWhite,
      secondaryContainer: KcColors.gold100,
      onSecondaryContainer: KcColors.gold700,
      tertiary: KcColors.emerald600,
      onTertiary: KcColors.pureWhite,
      tertiaryContainer: KcColors.emerald100,
      onTertiaryContainer: KcColors.emerald700,
      error: KcColors.signalRed,
      onError: KcColors.pureWhite,
      errorContainer: KcColors.dangerSoft,
      onErrorContainer: KcColors.signalRed,
      surface: KcColors.pureWhite,
      onSurface: KcColors.slate900,
      surfaceContainerHighest: KcColors.slate100,
      onSurfaceVariant: KcColors.slate600,
      outline: KcColors.slate300,
      outlineVariant: KcColors.slate200,
      shadow: Color(0x0F0B1F3F),
      scrim: Color(0x66070E1B),
    );
