import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/color_tokens.dart';

class KcPrimaryButton extends StatefulWidget {
  const KcPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;

  @override
  State<KcPrimaryButton> createState() => _KcPrimaryButtonState();
}

class _KcPrimaryButtonState extends State<KcPrimaryButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final btnColor = _isHovered
        ? (isDark ? KcColors.pureWhite : const Color(0xFF27272A))
        : (isDark ? KcColors.textPrimaryDark : KcColors.textPrimaryLight);

    final textColor = isDark ? KcColors.bgDark : KcColors.pureWhite;

    final btn = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: btnColor,
          boxShadow: [
            if (_isHovered)
              BoxShadow(
                color: KcColors.goldAccent.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 4),
              )
            else
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.isLoading ? null : widget.onPressed,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: widget.isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: textColor,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.label.toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            color: textColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            letterSpacing: 0.5,
                          ),
                        ),
                        if (widget.icon != null) ...[
                          const SizedBox(width: 8),
                          Icon(widget.icon, size: 16, color: KcColors.goldAccent),
                        ],
                      ],
                    ),
            ),
          ),
        ),
      ),
    );

    if (widget.fullWidth) {
      return SizedBox(width: double.infinity, child: btn);
    }
    return btn;
  }
}
