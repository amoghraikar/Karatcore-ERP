import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/buttons/kc_outlined_button.dart';
import '../../../../shared/widgets/cards/kc_card.dart';

import '../models/reports_model.dart';
import '../providers/reports_providers.dart';

class ReportDateFilter extends ConsumerWidget {
  const ReportDateFilter({super.key});

  void _showCustomRangePicker(BuildContext context, WidgetRef ref, ReportDateFilterModel currentFilter) async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: DateTimeRange(start: currentFilter.startDate, end: currentFilter.endDate),
    );

    if (range != null) {
      ref.read(reportDateFilterProvider.notifier).setCustomRange(range.start, range.end);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(reportDateFilterProvider);
    final scheme = Theme.of(context).colorScheme;

    return KcCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.date_range_rounded, size: 20),
              const SizedBox(width: 8),
              Text(
                'Report Date Filter:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${KcFormatters.date(filter.startDate)} – ${KcFormatters.date(filter.endDate)}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: scheme.primary),
                ),
              ),
              const Spacer(),
              if (filter.preset != DateFilterPreset.thisMonth || filter.comparisonMode != ComparisonMode.none)
                KcOutlinedButton(
                  label: 'Reset Filters',
                  icon: Icons.refresh_rounded,
                  onPressed: () => ref.read(reportDateFilterProvider.notifier).reset(),
                ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final preset in DateFilterPreset.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilterChip(
                      selected: filter.preset == preset,
                      label: Text(preset.label),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: filter.preset == preset ? FontWeight.w800 : FontWeight.w500,
                        color: filter.preset == preset ? scheme.onPrimary : scheme.onSurface,
                      ),
                      selectedColor: scheme.primary,
                      onSelected: (selected) {
                        if (preset == DateFilterPreset.custom) {
                          _showCustomRangePicker(context, ref, filter);
                        } else {
                          ref.read(reportDateFilterProvider.notifier).setPreset(preset);
                        }
                      },
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 20),
          Row(
            children: [
              const Icon(Icons.compare_arrows_rounded, size: 18),
              const SizedBox(width: 6),
              const Text('Comparison Mode:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(width: 12),
              DropdownButton<ComparisonMode>(
                value: filter.comparisonMode,
                underline: const SizedBox.shrink(),
                onChanged: (mode) {
                  if (mode != null) {
                    ref.read(reportDateFilterProvider.notifier).setComparisonMode(mode);
                  }
                },
                items: ComparisonMode.values.map((mode) {
                  return DropdownMenuItem(
                    value: mode,
                    child: Text(mode.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
