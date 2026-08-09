import 'package:flutter/material.dart';

import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/feedback/kc_empty_state.dart';
import '../../../../shared/widgets/inputs/kc_text_field.dart';

import 'export_dialog.dart';
import 'report_share_dialog.dart';

class ReportColumnConfig {
  const ReportColumnConfig({
    required this.key,
    required this.label,
    this.isVisible = true,
    this.isNumeric = false,
  });

  final String key;
  final String label;
  final bool isVisible;
  final bool isNumeric;

  ReportColumnConfig copyWith({bool? isVisible}) {
    return ReportColumnConfig(
      key: key,
      label: label,
      isVisible: isVisible ?? this.isVisible,
      isNumeric: isNumeric,
    );
  }
}

class ReportTable extends StatefulWidget {
  const ReportTable({
    super.key,
    required this.title,
    required this.columns,
    required this.rows,
    this.onRowTap,
  });

  final String title;
  final List<ReportColumnConfig> columns;
  final List<Map<String, dynamic>> rows;
  final Function(Map<String, dynamic> row)? onRowTap;

  @override
  State<ReportTable> createState() => _ReportTableState();
}

class _ReportTableState extends State<ReportTable> {
  final TextEditingController _searchController = TextEditingController();
  late List<ReportColumnConfig> _activeColumns;
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  int _currentPage = 0;
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _activeColumns = List.from(widget.columns);
  }

  void _showColumnCustomizer() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Customize Table Columns', style: TextStyle(fontWeight: FontWeight.w800)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < _activeColumns.length; i++)
                  CheckboxListTile(
                    title: Text(_activeColumns[i].label),
                    value: _activeColumns[i].isVisible,
                    onChanged: (val) {
                      setDialogState(() {
                        _activeColumns[i] = _activeColumns[i].copyWith(isVisible: val ?? true);
                      });
                      setState(() {});
                    },
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _activeColumns = List.from(widget.columns);
                });
                Navigator.of(ctx).pop();
              },
              child: const Text('Reset Columns'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (ctx) => ExportDialog(
        reportTitle: widget.title,
        data: widget.rows,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isMobile = MediaQuery.of(context).size.width < 768;

    // Filter rows by search
    final query = _searchController.text.trim().toLowerCase();
    var filteredRows = widget.rows.where((r) {
      if (query.isEmpty) return true;
      return r.values.any((val) => val.toString().toLowerCase().contains(query));
    }).toList();

    // Sort rows
    final sortKey = _activeColumns[_sortColumnIndex].key;
    filteredRows.sort((a, b) {
      final valA = a[sortKey];
      final valB = b[sortKey];
      if (valA == null || valB == null) return 0;
      final cmp = valA.toString().compareTo(valB.toString());
      return _sortAscending ? cmp : -cmp;
    });

    // Paginate
    final totalPages = (filteredRows.length / _pageSize).ceil();
    final pageStart = _currentPage * _pageSize;
    final pageEnd = (pageStart + _pageSize) < filteredRows.length ? (pageStart + _pageSize) : filteredRows.length;
    final pageRows = filteredRows.isEmpty ? <Map<String, dynamic>>[] : filteredRows.sublist(pageStart, pageEnd);

    final visibleCols = _activeColumns.where((c) => c.isVisible).toList();

    return KcCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Actions Toolbar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: KcTextField(
                    controller: _searchController,
                    hintText: 'Search records...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    onChanged: (val) => setState(() => _currentPage = 0),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  tooltip: 'Column Visibility',
                  icon: const Icon(Icons.view_column_rounded),
                  onPressed: _showColumnCustomizer,
                ),
                IconButton(
                  tooltip: 'Share Report',
                  icon: const Icon(Icons.share_rounded),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (ctx) => ReportShareDialog(reportTitle: widget.title),
                  ),
                ),
                IconButton(
                  tooltip: 'Export Report',
                  icon: const Icon(Icons.file_download_rounded),
                  onPressed: _showExportDialog,
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          if (filteredRows.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: KcEmptyState(
                title: widget.rows.isEmpty ? 'No records in selected period' : 'No matching records found',
                subtitle: widget.rows.isEmpty
                    ? 'There is no activity to report for this period. Try widening the report date filter.'
                    : 'Try refining your search terms or resetting column filters.',
              ),
            )
          else if (isMobile)
            // Mobile Card Transformation Layout
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pageRows.length,
              separatorBuilder: (context, index) => Divider(height: 1, color: scheme.outline.withValues(alpha: 0.15)),
              itemBuilder: (context, index) {
                final row = pageRows[index];

                return InkWell(
                  onTap: widget.onRowTap != null ? () => widget.onRowTap!(row) : null,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final col in visibleCols)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(col.label, style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
                                Text(row[col.key]?.toString() ?? '—', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            )
          else
            // Desktop Data Table View
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                sortColumnIndex: _sortColumnIndex,
                sortAscending: _sortAscending,
                columns: [
                  for (int i = 0; i < _activeColumns.length; i++)
                    if (_activeColumns[i].isVisible)
                      DataColumn(
                        label: Text(_activeColumns[i].label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                        numeric: _activeColumns[i].isNumeric,
                        onSort: (columnIndex, ascending) {
                          setState(() {
                            _sortColumnIndex = i;
                            _sortAscending = ascending;
                          });
                        },
                      ),
                ],
                rows: [
                  for (final row in pageRows)
                    DataRow(
                      onSelectChanged: widget.onRowTap != null ? (_) => widget.onRowTap!(row) : null,
                      cells: [
                        for (final col in visibleCols)
                          DataCell(
                            Text(row[col.key]?.toString() ?? '—', style: const TextStyle(fontSize: 13)),
                          ),
                      ],
                    ),
                ],
              ),
            ),

          // Pagination Footer
          if (filteredRows.isNotEmpty) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Text('Showing ${pageStart + 1}–$pageEnd of ${filteredRows.length} items', style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded),
                    onPressed: _currentPage > 0 ? () => setState(() => _currentPage--) : null,
                  ),
                  Text('${_currentPage + 1} / ${totalPages == 0 ? 1 : totalPages}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded),
                    onPressed: (_currentPage + 1) < totalPages ? () => setState(() => _currentPage++) : null,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
