import 'package:flutter/material.dart';

class KcSkeletonLoader extends StatelessWidget {
  const KcSkeletonLoader({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.radius = 8,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
