import 'package:flutter/material.dart';
import '../../../core/constants/color_tokens.dart';

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

    final effectiveColor = widget.color ?? (isDark ? KcColors.obsidian900 : KcColors.pureWhite);
    final effectiveBorder = widget.border ??
        Border.all(
          color: _isHovered && widget.onTap != null
              ? KcColors.gold500.withValues(alpha: 0.6)
              : (isDark ? KcColors.obsidian800 : KcColors.slate200),
          width: _isHovered && widget.onTap != null ? 1.2 : 1.0,
        );

    return MouseRegion(
      onEnter: (_) {
        if (widget.onTap != null && mounted) setState(() => _isHovered = true);
      },
      onExit: (_) {
        if (widget.onTap != null && mounted) setState(() => _isHovered = false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        transform: Matrix4.diagonal3Values(
          _isHovered && widget.onTap != null ? 1.012 : 1.0,
          _isHovered && widget.onTap != null ? 1.012 : 1.0,
          1.0,
        ),
        decoration: BoxDecoration(
          color: effectiveColor,
          borderRadius: BorderRadius.circular(12),
          border: effectiveBorder,
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: _isHovered && widget.onTap != null ? 0.45 : 0.25)
                  : scheme.shadow.withValues(alpha: _isHovered && widget.onTap != null ? 0.10 : 0.04),
              blurRadius: _isHovered && widget.onTap != null ? 14 : 8,
              offset: Offset(0, _isHovered && widget.onTap != null ? 6 : 3),
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
