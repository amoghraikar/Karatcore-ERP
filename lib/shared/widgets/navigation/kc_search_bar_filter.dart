import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';

class KcSearchBarFilter extends StatelessWidget {
  const KcSearchBarFilter({
    super.key,
    required this.searchController,
    required this.hintText,
    required this.onSearchChanged,
    required this.filterButton,
    required this.sortDropdown,
  });

  final TextEditingController searchController;
  final String hintText;
  final ValueChanged<String> onSearchChanged;
  final Widget filterButton;
  final Widget sortDropdown;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final searchField = TextField(
      controller: searchController,
      onChanged: onSearchChanged,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear_rounded),
                onPressed: () {
                  searchController.clear();
                  onSearchChanged('');
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );

    if (context.isMobile) {
      return Card(
        elevation: 0,
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              searchField,
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: filterButton),
                  const SizedBox(width: 10),
                  Expanded(child: sortDropdown),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(child: searchField),
            const SizedBox(width: 12),
            filterButton,
            const SizedBox(width: 12),
            sortDropdown,
          ],
        ),
      ),
    );
  }
}
