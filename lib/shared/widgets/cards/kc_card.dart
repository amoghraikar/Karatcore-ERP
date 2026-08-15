import 'package:flutter/material.dart';

class KcCard extends StatefulWidget {
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
  State<KcCard> createState() => _KcCardState();
}

class _KcCardState extends State<KcCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    Widget content = Padding(
      padding: widget.padding,
      child: widget.child,
    );

    if (widget.onTap != null) {
      content = InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: content,
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        transform: Matrix4.diagonal3Values(_isHovered && widget.onTap != null ? 1.015 : 1.0, _isHovered && widget.onTap != null ? 1.015 : 1.0, 1.0),
        decoration: BoxDecoration(
          color: widget.color ?? scheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: widget.border ??
              Border.all(
                color: _isHovered && widget.onTap != null
                    ? scheme.primary.withValues(alpha: 0.5)
                    : scheme.outline.withValues(alpha: isDark ? 0.3 : 0.15),
                width: _isHovered && widget.onTap != null ? 1.2 : 1.0,
              ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: _isHovered ? 0.5 : 0.3)
                  : scheme.shadow.withValues(alpha: _isHovered ? 0.12 : 0.06),
              blurRadius: _isHovered ? 16 : 10,
              offset: Offset(0, _isHovered ? 6 : 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: content,
        ),
      ),
    );
  }
}
