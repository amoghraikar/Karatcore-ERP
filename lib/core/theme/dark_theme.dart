import 'package:flutter/material.dart';
import '../constants/color_tokens.dart';

ColorScheme buildDarkColorScheme() => const ColorScheme.dark(
      primary: KcColors.pureWhite,
      onPrimary: KcColors.pitchBlack,
      primaryContainer: KcColors.carbon800,
      onPrimaryContainer: KcColors.pureWhite,
      secondary: KcColors.carbon300,
      onSecondary: KcColors.pitchBlack,
      secondaryContainer: KcColors.carbon800,
      onSecondaryContainer: KcColors.pureWhite,
      tertiary: KcColors.signalOrange,
      onTertiary: KcColors.pitchBlack,
      tertiaryContainer: Color(0xFF271F0C),
      onTertiaryContainer: KcColors.signalOrange,
      error: Color(0xFFF87171),
      onError: KcColors.pitchBlack,
      errorContainer: Color(0xFF450A0A),
      onErrorContainer: Color(0xFFFECACA),
      surface: KcColors.carbon950,
      onSurface: KcColors.pureWhite,
      surfaceContainerHighest: KcColors.carbon900,
      onSurfaceVariant: KcColors.carbon400,
      outline: KcColors.carbon700,
      outlineVariant: Color(0xFF18181B),
      shadow: Color(0x99000000),
      scrim: Color(0x99000000),
    );
