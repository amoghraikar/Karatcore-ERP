import 'package:flutter/material.dart';

/// Animation & Motion Tokens for KaratCore ERP.
abstract final class KcDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration pageTransition = Duration(milliseconds: 300);
  static const Duration shimmer = Duration(milliseconds: 1500);
}

abstract final class KcCurves {
  static const Curve defaultCurve = Curves.easeOutCubic;
  static const Curve scaleCurve = Curves.easeOutBack;
  static const Curve smooth = Curves.easeInOutCubic;
}
