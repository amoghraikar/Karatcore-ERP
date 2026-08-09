import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/breadcrumb_item.dart';

class KcBreadcrumbBar extends StatelessWidget {
  const KcBreadcrumbBar({super.key, required this.items});
  final List<BreadcrumbItem> items;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ),
            InkWell(
              onTap: items[i].path != null ? () => context.go(items[i].path!) : null,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  items[i].label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: i == items.length - 1
                            ? scheme.onSurface
                            : scheme.onSurfaceVariant,
                        fontWeight: i == items.length - 1
                            ? FontWeight.w700
                            : FontWeight.w500,
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
