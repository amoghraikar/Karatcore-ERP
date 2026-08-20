import 'package:flutter/material.dart';
import '../constants/color_tokens.dart';

ColorScheme buildLightColorScheme() => const ColorScheme.light(
      primary: KcColors.textPrimaryLight,
      onPrimary: KcColors.bgLight,
      primaryContainer: Color(0xFFE8E5DC),
      onPrimaryContainer: KcColors.textPrimaryLight,
      secondary: KcColors.goldAccent,
      onSecondary: KcColors.pureWhite,
      secondaryContainer: KcColors.goldSubdued,
      onSecondaryContainer: KcColors.goldAccent,
      tertiary: KcColors.success,
      onTertiary: KcColors.pureWhite,
      tertiaryContainer: KcColors.successSubdued,
      onTertiaryContainer: KcColors.success,
      error: KcColors.danger,
      onError: KcColors.pureWhite,
      errorContainer: KcColors.dangerSubdued,
      onErrorContainer: KcColors.danger,
      surface: KcColors.surfaceLight,
      onSurface: KcColors.textPrimaryLight,
      surfaceContainerHighest: Color(0xFFEFECE4),
      onSurfaceVariant: KcColors.textSecondaryLight,
      outline: KcColors.borderLight,
      outlineVariant: Color(0x0A111214),
      shadow: Color(0x08000000),
      scrim: Color(0x40000000),
    );
