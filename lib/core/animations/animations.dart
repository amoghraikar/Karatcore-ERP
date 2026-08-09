import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../constants/animation_tokens.dart';

extension KcAnimationX on Widget {
  Widget animateFadeIn({Duration? duration, Curve? curve}) {
    return animate()
        .fadeIn(duration: duration ?? KcDurations.normal, curve: curve ?? KcCurves.defaultCurve);
  }

  Widget animateSlideUp({Duration? duration, Curve? curve, double offset = 20}) {
    return animate()
        .fadeIn(duration: duration ?? KcDurations.normal)
        .slideY(begin: offset / 100, end: 0, duration: duration ?? KcDurations.normal, curve: curve ?? KcCurves.defaultCurve);
  }

  Widget animateScaleIn({Duration? duration, Curve? curve}) {
    return animate()
        .scale(begin: const Offset(0.92, 0.92), end: const Offset(1, 1), duration: duration ?? KcDurations.normal, curve: curve ?? KcCurves.scaleCurve)
        .fadeIn(duration: duration ?? KcDurations.normal);
  }

  Widget animateShimmer({Duration? duration, Color? color}) {
    return animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: duration ?? KcDurations.shimmer, color: color);
  }
}

class KcHoverable extends StatefulWidget {
  const KcHoverable({
    super.key,
    required this.child,
    this.hoverScale = 1.02,
    this.duration = KcDurations.fast,
  });

  final Widget child;
  final double hoverScale;
  final Duration duration;

  @override
  State<KcHoverable> createState() => _KcHoverableState();
}

class _KcHoverableState extends State<KcHoverable> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? widget.hoverScale : 1.0,
        duration: widget.duration,
        curve: KcCurves.scaleCurve,
        child: widget.child,
      ),
    );
  }
}

class KcPressable extends StatefulWidget {
  const KcPressable({
    super.key,
    required this.child,
    this.onTap,
    this.pressScale = 0.96,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double pressScale;

  @override
  State<KcPressable> createState() => _KcPressableState();
}

class _KcPressableState extends State<KcPressable> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? widget.pressScale : 1.0,
        duration: KcDurations.fast,
        curve: KcCurves.defaultCurve,
        child: widget.child,
      ),
    );
  }
}

abstract final class KcPageTransitions {
  static CustomTransitionPage<T> fadeTransition<T>({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurveTween(curve: KcCurves.defaultCurve).animate(animation),
          child: child,
        );
      },
    );
  }
}

