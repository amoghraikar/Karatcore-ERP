import 'package:flutter/material.dart';
import '../constants/color_tokens.dart';

ColorScheme buildLightColorScheme() => const ColorScheme.light(
      primary: KcColors.carbon950,
      onPrimary: KcColors.pureWhite,
      primaryContainer: KcColors.carbon100,
      onPrimaryContainer: KcColors.carbon950,
      secondary: KcColors.carbon800,
      onSecondary: KcColors.pureWhite,
      secondaryContainer: KcColors.carbon100,
      onSecondaryContainer: KcColors.carbon950,
      tertiary: KcColors.signalOrange,
      onTertiary: KcColors.pureWhite,
      tertiaryContainer: KcColors.gold100,
      onTertiaryContainer: KcColors.carbon950,
      error: KcColors.signalRed,
      onError: KcColors.pureWhite,
      errorContainer: KcColors.dangerSoft,
      onErrorContainer: KcColors.signalRed,
      surface: KcColors.pureWhite,
      onSurface: KcColors.carbon950,
      surfaceContainerHighest: KcColors.carbon50,
      onSurfaceVariant: KcColors.carbon500,
      outline: KcColors.carbon200,
      outlineVariant: Color(0xFFE4E4E7),
      shadow: Color(0x0A000000),
      scrim: Color(0x66000000),
    );
