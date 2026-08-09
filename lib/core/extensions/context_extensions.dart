import 'package:flutter/material.dart';
import '../config/app_constants.dart';
import '../constants/spacing_tokens.dart';

extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;

  double get width => MediaQuery.sizeOf(this).width;
  double get height => MediaQuery.sizeOf(this).height;

  bool get isMobile => width < AppConstants.mobileBreakpoint;
  bool get isTablet => width >= AppConstants.mobileBreakpoint && width < AppConstants.tabletBreakpoint;
  bool get isDesktop => width >= AppConstants.tabletBreakpoint;

  double get pageGutter {
    if (isMobile) return KcSpace.pageGutterMobile;
    if (isTablet) return KcSpace.pageGutterTablet;
    return KcSpace.pageGutterDesktop;
  }
}
