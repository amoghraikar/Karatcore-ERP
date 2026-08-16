import 'package:flutter/material.dart';
import '../../../core/constants/color_tokens.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final searchField = TextField(
      controller: searchController,
      onChanged: onSearchChanged,
      style: TextStyle(color: isDark ? KcColors.pureWhite : KcColors.slate900, fontSize: 13.5),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: isDark ? KcColors.slate400 : KcColors.slate500, fontSize: 13),
        prefixIcon: const Icon(Icons.search_rounded, color: KcColors.gold500, size: 20),
        suffixIcon: searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear_rounded, size: 18),
                onPressed: () {
                  searchController.clear();
                  onSearchChanged('');
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: isDark ? KcColors.obsidian800 : KcColors.slate200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: isDark ? KcColors.obsidian800 : KcColors.slate200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: KcColors.gold500, width: 1.5),
        ),
        filled: true,
        fillColor: isDark ? KcColors.obsidian850 : KcColors.slate50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );

    if (context.isMobile) {
      return Container(
        decoration: BoxDecoration(
          color: isDark ? KcColors.obsidian900 : KcColors.pureWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? KcColors.obsidian800 : KcColors.slate200),
        ),
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
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? KcColors.obsidian900 : KcColors.pureWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? KcColors.obsidian800 : KcColors.slate200),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Expanded(child: searchField),
          const SizedBox(width: 12),
          filterButton,
          const SizedBox(width: 12),
          SizedBox(width: 220, child: sortDropdown),
        ],
      ),
    );
  }
}
