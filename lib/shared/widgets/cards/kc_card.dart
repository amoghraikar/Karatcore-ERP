import 'package:flutter/material.dart';

class KcCard extends StatelessWidget {
  const KcCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
    this.color,
    this.border,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(
      padding: padding,
      child: child,
    );

    if (onTap != null) {
      content = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: content,
      );
    }

    if (border != null || color != null) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Container(
        decoration: BoxDecoration(
          color: color ?? (isDark ? Theme.of(context).colorScheme.surface : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: border ?? Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: Material(
          color: Colors.transparent,
          child: content,
        ),
      );
    }

    return Card(
      color: color,
      child: content,
    );
  }
}
