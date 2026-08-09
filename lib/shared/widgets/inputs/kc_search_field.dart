import 'package:flutter/material.dart';

class KcSearchField extends StatelessWidget {
  const KcSearchField({
    super.key,
    this.controller,
    this.hint = 'Search loans, customers, inventory...',
    this.onChanged,
  });

  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      controller: controller,
      hintText: hint,
      onChanged: onChanged,
      leading: const Icon(Icons.search_rounded),
    );
  }
}
