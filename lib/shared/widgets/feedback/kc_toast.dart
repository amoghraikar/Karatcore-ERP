import 'package:flutter/material.dart';
import '../../../core/constants/color_tokens.dart';

enum KcToastType {
  success(Icons.check_circle_rounded, Color(0xFF059669), Color(0xFFF0FDF4)),
  info(Icons.info_rounded, Color(0xFF2563EB), Color(0xFFEFF6FF)),
  warning(Icons.warning_amber_rounded, Color(0xFFD97706), Color(0xFFFFFBEB)),
  error(Icons.error_rounded, Color(0xFFDC2626), Color(0xFFFEF2F2));

  const KcToastType(this.icon, this.accentColor, this.backgroundColor);
  final IconData icon;
  final Color accentColor;
  final Color backgroundColor;
}

class KcToast {
  const KcToast._();

  static void show(
    BuildContext context, {
    required String message,
    String? title,
    KcToastType type = KcToastType.info,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        duration: duration,
        elevation: 6,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        padding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: type.backgroundColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: type.accentColor.withValues(alpha: 0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(type.icon, color: type.accentColor, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null)
                      Text(
                        title,
                        style: TextStyle(
                          color: type.accentColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    Text(
                      message,
                      style: const TextStyle(
                        color: KcColors.obsidian950,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (onAction != null && actionLabel != null) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    messenger.hideCurrentSnackBar();
                    onAction();
                  },
                  child: Text(
                    actionLabel,
                    style: TextStyle(
                      color: type.accentColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static void success(BuildContext context, String message, {String? title, VoidCallback? onAction, String? actionLabel}) {
    show(context, message: message, title: title, type: KcToastType.success, onAction: onAction, actionLabel: actionLabel);
  }

  static void info(BuildContext context, String message, {String? title, VoidCallback? onAction, String? actionLabel}) {
    show(context, message: message, title: title, type: KcToastType.info, onAction: onAction, actionLabel: actionLabel);
  }

  static void warning(BuildContext context, String message, {String? title, VoidCallback? onAction, String? actionLabel}) {
    show(context, message: message, title: title, type: KcToastType.warning, onAction: onAction, actionLabel: actionLabel);
  }

  static void error(BuildContext context, String message, {String? title, VoidCallback? onAction, String? actionLabel}) {
    show(context, message: message, title: title, type: KcToastType.error, onAction: onAction, actionLabel: actionLabel);
  }
}
