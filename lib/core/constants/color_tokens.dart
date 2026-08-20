import 'package:flutter/material.dart';

/// Premium Editorial Design Tokens for KaratCore ERP.
abstract final class KcColors {
  // Editorial Canvas & Background Palette
  static const Color bgLight = Color(0xFFF4F2ED); // Warm Off-White / Ivory
  static const Color bgDark = Color(0xFF111214); // Deep Charcoal / Near Black

  // Surface Canvas Tokens
  static const Color surfaceLight = Color(0xFFFFFFFF); // Pure White Surface Container
  static const Color surfaceDark = Color(0xFF181A1E); // Elevated Dark Surface

  // Primary Text & Hierarchy
  static const Color textPrimaryLight = Color(0xFF111214);
  static const Color textPrimaryDark = Color(0xFFF4F2ED);
  static const Color textSecondaryLight = Color(0xFF6B6B6B);
  static const Color textSecondaryDark = Color(0xFF9A9A9A);
  static const Color textMutedLight = Color(0xFFA0A0A0);
  static const Color textMutedDark = Color(0xFF6E727A);

  // Karat Gold Accent (Used with extreme restraint for value/prestige)
  static const Color goldAccent = Color(0xFFB88A3B); // Karat Gold Primary
  static const Color goldLight = Color(0xFFD4A659);
  static const Color goldSubdued = Color(0x1AB88A3B);

  // Deep Navy & Functional Status Tokens
  static const Color deepNavy = Color(0xFF111C2C);
  static const Color success = Color(0xFF26745A); // Muted Emerald
  static const Color warning = Color(0xFFA97828); // Muted Amber
  static const Color danger = Color(0xFFA94848); // Muted Red
  static const Color successSubdued = Color(0x1F26745A);
  static const Color warningSubdued = Color(0x1FA97828);
  static const Color dangerSubdued = Color(0x1FA94848);

  // Structural Hairline Borders
  static const Color borderLight = Color(0x14111214);
  static const Color borderDark = Color(0x14F4F2ED);

  // Legacy/Compatibility Color Tokens
  static const Color obsidian950 = bgDark;
  static const Color obsidian900 = surfaceDark;
  static const Color obsidian850 = Color(0xFF20232A);
  static const Color obsidian800 = Color(0xFF2D313B);
  static const Color obsidian700 = Color(0xFF3F4452);

  static const Color gold700 = Color(0xFF8C6425);
  static const Color gold600 = Color(0xFF9E742F);
  static const Color gold500 = goldAccent;
  static const Color gold400 = goldLight;
  static const Color gold300 = Color(0xFFE2BE78);
  static const Color gold100 = Color(0xFFF7E8C9);
  static const Color gold50 = Color(0xFFFDF8EE);

  static const Color emerald700 = Color(0xFF1B5340);
  static const Color emerald600 = success;
  static const Color emerald500 = Color(0xFF329172);
  static const Color emerald100 = Color(0xFFD3EBE2);
  static const Color emerald50 = Color(0xFFF0F9F5);

  static const Color slate950 = Color(0xFF0D0E10);
  static const Color slate900 = textPrimaryLight;
  static const Color slate800 = Color(0xFF2D3036);
  static const Color slate700 = Color(0xFF454952);
  static const Color slate600 = textSecondaryLight;
  static const Color slate500 = Color(0xFF858A94);
  static const Color slate400 = textSecondaryDark;
  static const Color slate300 = Color(0xFFD1D5DB);
  static const Color slate200 = Color(0xFFE5E7EB);
  static const Color slate100 = Color(0xFFF3F4F6);
  static const Color slate50 = bgLight;

  static const Color pinkAccent = goldAccent;
  static const Color stippleBgLight = bgLight;
  static const Color stippleBgDark = bgDark;
  static const Color monoCardDark = surfaceDark;
  static const Color charcoalPrimary = textPrimaryLight;

  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color pitchBlack = Color(0xFF000000);

  static const Color signalOrange = warning;
  static const Color signalRed = danger;
  static const Color signalGreen = success;
  static const Color signalBlue = Color(0xFF2563EB);

  static const Color navy950 = deepNavy;
  static const Color navy900 = deepNavy;
  static const Color navy800 = Color(0xFF18273D);
  static const Color navy700 = Color(0xFF213450);
  static const Color navy600 = Color(0xFF2C4468);
  static const Color navy50 = Color(0xFFF0F4FA);

  static const Color carbon950 = bgDark;
  static const Color carbon900 = surfaceDark;
  static const Color carbon800 = Color(0xFF22252C);
  static const Color carbon700 = Color(0xFF333842);
  static const Color carbon600 = Color(0xFF4A515E);
  static const Color carbon500 = slate500;
  static const Color carbon400 = slate400;
  static const Color carbon300 = slate300;
  static const Color carbon200 = slate200;
  static const Color carbon100 = slate100;
  static const Color carbon50 = slate50;

  static const Color platinum900 = surfaceDark;
  static const Color platinum800 = Color(0xFF22252C);
  static const Color platinum700 = slate600;
  static const Color platinum200 = slate200;
  static const Color platinum100 = slate100;
  static const Color platinum50 = pureWhite;

  static const Color cyan600 = deepNavy;
  static const Color cyan400 = goldLight;

  static const Color dangerSoft = dangerSubdued;
  static const Color warningSoft = warningSubdued;
  static const Color info = signalBlue;
  static const Color infoSoft = Color(0x1F2563EB);

  static const Color white = pureWhite;
  static const Color paper = surfaceLight;
  static const Color darkSurface = surfaceDark;
  static const Color darkCard = surfaceDark;
}
