import 'package:flutter/material.dart';
import '../../../core/constants/color_tokens.dart';

class KcFilterOption<T> {
  const KcFilterOption({required this.label, required this.value, this.icon});
  final String label;
  final T value;
  final IconData? icon;
}

class KcFilterGroup<T> extends StatelessWidget {
  const KcFilterGroup({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
  });

  final List<KcFilterOption<T>> options;
  final T selectedValue;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final option in options) ...[
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                showCheckmark: false,
                avatar: option.icon != null ? Icon(option.icon, size: 16) : null,
                label: Text(option.label),
                selected: option.value == selectedValue,
                onSelected: (_) => onSelected(option.value),
                selectedColor: isDark ? KcColors.pureWhite : KcColors.pitchBlack,
                labelStyle: TextStyle(
                  color: option.value == selectedValue
                      ? (isDark ? KcColors.pitchBlack : KcColors.pureWhite)
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight: option.value == selectedValue ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                  side: BorderSide(
                    color: option.value == selectedValue
                        ? Colors.transparent
                        : (isDark ? KcColors.carbon700 : KcColors.carbon200),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
