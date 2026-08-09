import 'package:flutter/material.dart';

abstract final class KcBottomSheets {
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
  }) => showCustom<T>(context: context, child: child);

  static Future<T?> showCustom<T>({
    required BuildContext context,
    required Widget child,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          top: 16,
          left: 20,
          right: 20,
        ),
        child: child,
      ),
    );
  }
}
