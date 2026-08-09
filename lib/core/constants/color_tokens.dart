import 'package:flutter/material.dart';

/// Monochrome Architectural Minimalist (Swiss Style) Color Tokens for KaratCore ERP.
abstract final class KcColors {
  // Pure Monochromatic Spectrum
  static const Color pitchBlack = Color(0xFF000000);
  static const Color carbon950 = Color(0xFF09090B);
  static const Color carbon900 = Color(0xFF0C0C0E);
  static const Color carbon800 = Color(0xFF18181B);
  static const Color carbon700 = Color(0xFF27272A);
  static const Color carbon600 = Color(0xFF3F3F46);
  static const Color carbon500 = Color(0xFF52525B);
  static const Color carbon400 = Color(0xFF71717A);
  static const Color carbon300 = Color(0xFFA1A1AA);
  static const Color carbon200 = Color(0xFFE4E4E7);
  static const Color carbon100 = Color(0xFFF4F4F5);
  static const Color carbon50  = Color(0xFFFAFAFA);
  static const Color pureWhite  = Color(0xFFFFFFFF);

  // Architectural Accent (Sparse Signal Highlight)
  static const Color signalOrange = Color(0xFFD97706);
  static const Color signalRed = Color(0xFFDC2626);
  static const Color signalGreen = Color(0xFF16A34A);
  static const Color signalBlue = Color(0xFF2563EB);

  // Backward Compatibility Tokens
  static const Color obsidian950 = carbon950;
  static const Color obsidian900 = carbon900;
  static const Color obsidian800 = carbon800;
  static const Color obsidian700 = carbon700;
  static const Color obsidian600 = carbon600;
  static const Color obsidian500 = carbon500;

  static const Color platinum900 = carbon800;
  static const Color platinum800 = carbon700;
  static const Color platinum700 = carbon600;
  static const Color platinum600 = carbon500;
  static const Color platinum500 = carbon400;
  static const Color platinum400 = carbon300;
  static const Color platinum300 = carbon200;
  static const Color platinum200 = carbon100;
  static const Color platinum100 = carbon50;
  static const Color platinum50  = pureWhite;

  static const Color gold500 = signalOrange;
  static const Color gold400 = signalOrange;
  static const Color gold100 = Color(0xFFFEF3C7);
  static const Color emerald600 = signalGreen;
  static const Color emerald500 = signalGreen;
  static const Color cyan600 = carbon800;
  static const Color cyan400 = carbon300;

  static const Color slate900 = carbon950;
  static const Color slate800 = carbon900;
  static const Color slate700 = carbon800;
  static const Color slate600 = carbon600;
  static const Color slate500 = carbon500;
  static const Color slate400 = carbon400;
  static const Color slate300 = carbon300;
  static const Color slate200 = carbon200;
  static const Color slate100 = carbon100;

  static const Color navy900 = carbon950;
  static const Color navy800 = carbon900;
  static const Color navy600 = carbon700;
  static const Color navy50  = carbon100;

  static const Color danger = signalRed;
  static const Color dangerSoft = Color(0xFFFEE2E2);
  static const Color warning = signalOrange;
  static const Color warningSoft = Color(0xFFFEF3C7);
  static const Color info = signalBlue;
  static const Color infoSoft = Color(0xFFDBEAFE);

  static const Color white = pureWhite;
  static const Color paper = pureWhite;
  static const Color darkSurface = carbon950;
  static const Color darkCard = carbon900;
}
