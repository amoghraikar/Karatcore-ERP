import 'package:flutter/material.dart';
import '../constants/color_tokens.dart';

ColorScheme buildDarkColorScheme() => const ColorScheme.dark(
      primary: KcColors.gold500,
      onPrimary: KcColors.navy950,
      primaryContainer: KcColors.navy800,
      onPrimaryContainer: KcColors.gold300,
      secondary: KcColors.emerald500,
      onSecondary: KcColors.navy950,
      secondaryContainer: KcColors.navy700,
      onSecondaryContainer: KcColors.emerald100,
      tertiary: KcColors.gold400,
      onTertiary: KcColors.navy950,
      tertiaryContainer: Color(0xFF271F0C),
      onTertiaryContainer: KcColors.gold300,
      error: Color(0xFFF87171),
      onError: KcColors.pitchBlack,
      errorContainer: Color(0xFF450A0A),
      onErrorContainer: Color(0xFFFECACA),
      surface: KcColors.navy950,
      onSurface: KcColors.pureWhite,
      surfaceContainerHighest: KcColors.navy900,
      onSurfaceVariant: KcColors.slate400,
      outline: KcColors.navy700,
      outlineVariant: KcColors.navy800,
      shadow: Color(0x99000000),
      scrim: Color(0x99000000),
    );
