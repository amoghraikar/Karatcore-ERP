import 'package:flutter/material.dart';

/// Champagne Obsidian & Satin Gold Luxury Design System Tokens.
abstract final class KcColors {
  // Obsidian Core Canvas & Surfaces
  static const Color obsidian950 = Color(0xFF0B0E14); // Primary App Canvas Background
  static const Color obsidian900 = Color(0xFF131822); // Card & Elevated Surface Container
  static const Color obsidian850 = Color(0xFF1B2230); // Higher Surface / Hover / Header Container
  static const Color obsidian800 = Color(0xFF222A3A); // Subtle Hairline Dividers & Borders
  static const Color obsidian700 = Color(0xFF2E384D); // Soft Interactive Borders

  // Champagne & Satin Gold Spectrum
  static const Color gold700 = Color(0xFFB45309);
  static const Color gold600 = Color(0xFFD97706);
  static const Color gold500 = Color(0xFFF59E0B); // Primary Brand Accent
  static const Color gold400 = Color(0xFFFBBF24); // High Glow Gold Accent
  static const Color gold300 = Color(0xFFFCD34D);
  static const Color gold100 = Color(0xFFFEF3C7);
  static const Color gold50  = Color(0xFFFFFBEB);

  // Emerald Growth Spectrum
  static const Color emerald700 = Color(0xFF047857);
  static const Color emerald600 = Color(0xFF059669);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald100 = Color(0xFFD1FAE5);
  static const Color emerald50  = Color(0xFFECFDF5);

  // Neutral Slate & Platinum Spectrum
  static const Color slate950 = Color(0xFF020617);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate50  = Color(0xFFF8FAFC);

  // Functional Highlights
  static const Color pureWhite  = Color(0xFFFFFFFF);
  static const Color pitchBlack = Color(0xFF000000);

  static const Color signalOrange = gold500;
  static const Color signalRed    = Color(0xFFEF4444);
  static const Color signalGreen  = emerald500;
  static const Color signalBlue   = Color(0xFF3B82F6);

  // Backward Compatibility Tokens
  static const Color navy950 = obsidian950;
  static const Color navy900 = obsidian900;
  static const Color navy800 = obsidian850;
  static const Color navy700 = obsidian800;
  static const Color navy600 = obsidian700;
  static const Color navy50  = Color(0xFF1E293B);

  static const Color carbon950 = obsidian950;
  static const Color carbon900 = obsidian900;
  static const Color carbon800 = obsidian850;
  static const Color carbon700 = obsidian800;
  static const Color carbon600 = obsidian700;
  static const Color carbon500 = slate500;
  static const Color carbon400 = slate400;
  static const Color carbon300 = slate300;
  static const Color carbon200 = slate200;
  static const Color carbon100 = slate100;
  static const Color carbon50  = slate50;

  static const Color platinum900 = obsidian850;
  static const Color platinum800 = obsidian800;
  static const Color platinum700 = slate600;
  static const Color platinum200 = slate200;
  static const Color platinum100 = slate100;
  static const Color platinum50  = pureWhite;

  static const Color cyan600 = obsidian850;
  static const Color cyan400 = gold400;

  static const Color danger     = signalRed;
  static const Color dangerSoft = Color(0xFF450A0A);
  static const Color warning    = gold500;
  static const Color warningSoft= Color(0xFF271F0C);
  static const Color info       = signalBlue;
  static const Color infoSoft   = Color(0xFF172554);

  static const Color white       = pureWhite;
  static const Color paper       = obsidian900;
  static const Color darkSurface = obsidian950;
  static const Color darkCard    = obsidian900;
}
