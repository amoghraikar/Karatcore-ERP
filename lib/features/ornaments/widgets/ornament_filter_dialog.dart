import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ornament_model.dart';
import '../providers/inventory_providers.dart';
import '../repository/inventory_repository.dart';

class OrnamentFilterDialog extends ConsumerStatefulWidget {
  const OrnamentFilterDialog({super.key});

  @override
  ConsumerState<OrnamentFilterDialog> createState() => _OrnamentFilterDialogState();
}

class _OrnamentFilterDialogState extends ConsumerState<OrnamentFilterDialog> {
  MetalType? _selectedMetal;
  OrnamentPurity? _selectedPurity;
  OrnamentCategory? _selectedCategory;
  OrnamentStatus? _selectedStatus;
  OwnershipType? _selectedOwnership;

  @override
  void initState() {
    super.initState();
    final current = ref.read(inventoryFilterProvider);
    _selectedMetal = current.metalType;
    _selectedPurity = current.purity;
    _selectedCategory = current.category;
    _selectedStatus = current.status;
    _selectedOwnership = current.ownershipType;
  }

  void _apply() {
    final filters = InventoryFilterParams(
      metalType: _selectedMetal,
      purity: _selectedPurity,
      category: _selectedCategory,
      status: _selectedStatus,
      ownershipType: _selectedOwnership,
    );
    ref.read(ornamentListProvider.notifier).updateFilters(filters);
    Navigator.of(context).pop();
  }

  void _clear() {
    setState(() {
      _selectedMetal = null;
      _selectedPurity = null;
      _selectedCategory = null;
      _selectedStatus = null;
      _selectedOwnership = null;
    });
    ref.read(ornamentListProvider.notifier).clearFilters();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      constraints: const BoxConstraints(maxWidth: 580),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filter Inventory Ornaments', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.of(context).pop()),
            ],
          ),
          const Divider(height: 24),

          // Metal Type Filter
          Text('Metal Type', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Row(
            children: MetalType.values.map((m) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(m.label),
                  selected: _selectedMetal == m,
                  onSelected: (val) => setState(() => _selectedMetal = val ? m : null),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Purity Filter
          Text('Gold & Silver Purity', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: OrnamentPurity.values.map((p) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(p.label),
                    selected: _selectedPurity == p,
                    onSelected: (val) => setState(() => _selectedPurity = val ? p : null),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Category Filter
          Text('Ornament Category', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: OrnamentCategory.values.map((c) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(c.label),
                    selected: _selectedCategory == c,
                    onSelected: (val) => setState(() => _selectedCategory = val ? c : null),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Status Filter
          Text('Inventory Status', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: OrnamentStatus.values.map((st) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(st.label),
                    selected: _selectedStatus == st,
                    onSelected: (val) => setState(() => _selectedStatus = val ? st : null),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              OutlinedButton(onPressed: _clear, child: const Text('Clear All')),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: scheme.primary, foregroundColor: scheme.onPrimary),
                onPressed: _apply,
                child: const Text('Apply Inventory Filters'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> showOrnamentFilterSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (context) => const SingleChildScrollView(child: OrnamentFilterDialog()),
  );
}
