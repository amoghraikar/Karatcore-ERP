import 'package:flutter/material.dart';

/// Enterprise Luxury Jewellery & Gold Loan Color System for KaratCore ERP.
abstract final class KcColors {
  // Rich Navy & Midnight Spectrum
  static const Color navy950 = Color(0xFF070E1B);
  static const Color navy900 = Color(0xFF0B1F3F);
  static const Color navy800 = Color(0xFF0F2942);
  static const Color navy700 = Color(0xFF1E3A5F);
  static const Color navy600 = Color(0xFF2D4A77);
  static const Color navy50  = Color(0xFFEDF4FE);

  // Luxury Gold & Bullion Spectrum
  static const Color gold700 = Color(0xFFB45309);
  static const Color gold600 = Color(0xFFD97706);
  static const Color gold500 = Color(0xFFF59E0B);
  static const Color gold400 = Color(0xFFFBBF24);
  static const Color gold300 = Color(0xFFFCD34D);
  static const Color gold100 = Color(0xFFFEF3C7);
  static const Color gold50  = Color(0xFFFFFBEB);

  // Emerald & Financial Growth Spectrum
  static const Color emerald700 = Color(0xFF047857);
  static const Color emerald600 = Color(0xFF059669);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald100 = Color(0xFFD1FAE5);
  static const Color emerald50  = Color(0xFFECFDF5);

  // Slate Neutral Spectrum
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

  // Functional Signal Highlights
  static const Color pureWhite  = Color(0xFFFFFFFF);
  static const Color pitchBlack = Color(0xFF000000);

  static const Color signalOrange = gold600;
  static const Color signalRed    = Color(0xFFDC2626);
  static const Color signalGreen  = emerald600;
  static const Color signalBlue   = Color(0xFF2563EB);

  // Legacy & Compatibility Mapping
  static const Color carbon950 = slate950;
  static const Color carbon900 = slate900;
  static const Color carbon800 = slate800;
  static const Color carbon700 = slate700;
  static const Color carbon600 = slate600;
  static const Color carbon500 = slate500;
  static const Color carbon400 = slate400;
  static const Color carbon300 = slate300;
  static const Color carbon200 = slate200;
  static const Color carbon100 = slate100;
  static const Color carbon50  = slate50;

  static const Color obsidian950 = slate950;
  static const Color obsidian900 = slate900;
  static const Color obsidian800 = slate800;

  static const Color platinum900 = slate800;
  static const Color platinum800 = slate700;
  static const Color platinum700 = slate600;
  static const Color platinum200 = slate200;
  static const Color platinum100 = slate100;
  static const Color platinum50  = pureWhite;

  static const Color cyan600 = navy800;
  static const Color cyan400 = navy600;

  static const Color danger     = signalRed;
  static const Color dangerSoft = Color(0xFFFEE2E2);
  static const Color warning    = gold600;
  static const Color warningSoft= gold100;
  static const Color info       = signalBlue;
  static const Color infoSoft   = Color(0xFFDBEAFE);

  static const Color white       = pureWhite;
  static const Color paper       = pureWhite;
  static const Color darkSurface = navy950;
  static const Color darkCard    = navy900;
}
