import 'package:flutter/material.dart';

import '../../../core/constants/color_tokens.dart';

class KcTableColumn<T> {
  const KcTableColumn({
    required this.header,
    required this.cellBuilder,
    this.width,
    this.onSort,
    this.isNumeric = false,
  });

  final String header;
  final Widget Function(T item) cellBuilder;
  final double? width;
  final VoidCallback? onSort;
  final bool isNumeric;
}

class KcDataTable<T> extends StatelessWidget {
  const KcDataTable({
    super.key,
    required this.columns,
    required this.items,
    this.selectedItems = const {},
    this.onSelectionChanged,
    this.onRowTap,
    this.emptyWidget,
    this.sortColumnIndex,
    this.sortAscending = true,
  });

  final List<KcTableColumn<T>> columns;
  final List<T> items;
  final Set<T> selectedItems;
  final ValueChanged<Set<T>>? onSelectionChanged;
  final ValueChanged<T>? onRowTap;
  final Widget? emptyWidget;
  final int? sortColumnIndex;
  final bool sortAscending;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final hasSelection = onSelectionChanged != null;

    if (items.isEmpty) {
      return emptyWidget ??
          Container(
            padding: const EdgeInsets.all(32),
            alignment: Alignment.center,
            child: Text(
              'No data available',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 300),
        child: DataTable(
          headingRowHeight: 44,
          dataRowMinHeight: 48,
          dataRowMaxHeight: 56,
          horizontalMargin: 16,
          columnSpacing: 24,
          headingRowColor: WidgetStateProperty.all(
            isDark ? KcColors.carbon900 : KcColors.carbon50,
          ),
          showCheckboxColumn: hasSelection,
          sortColumnIndex: sortColumnIndex,
          sortAscending: sortAscending,
          columns: [
            for (int i = 0; i < columns.length; i++)
              DataColumn(
                numeric: columns[i].isNumeric,
                label: Text(
                  columns[i].header.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: scheme.onSurfaceVariant,
                      ),
                ),
                onSort: columns[i].onSort != null ? (_, __) => columns[i].onSort!() : null,
              ),
          ],
          rows: [
            for (final item in items)
              DataRow(
                selected: selectedItems.contains(item),
                onSelectChanged: hasSelection
                    ? (selected) {
                        final updated = Set<T>.from(selectedItems);
                        if (selected == true) {
                          updated.add(item);
                        } else {
                          updated.remove(item);
                        }
                        onSelectionChanged!(updated);
                      }
                    : (onRowTap != null ? (_) => onRowTap!(item) : null),
                cells: [
                  for (final col in columns)
                    DataCell(
                      col.cellBuilder(item),
                      onTap: onRowTap != null ? () => onRowTap!(item) : null,
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
