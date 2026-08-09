import 'package:flutter/material.dart';

/// Shadow & Elevation System for KaratCore ERP.
abstract final class KcShadows {
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x0A0F172A),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x0F0F172A),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x140F172A),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> darkGlow = [
    BoxShadow(
      color: Color(0x26E3B83B),
      blurRadius: 20,
      offset: Offset(0, 4),
    ),
  ];
}
