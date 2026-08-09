import 'package:flutter/material.dart';

class KcSearchBarUI extends StatefulWidget {
  const KcSearchBarUI({
    super.key,
    this.hintText = 'Search ERP database...',
    this.suggestions = const [],
    this.onChanged,
    this.onSubmitted,
    this.onSuggestionSelected,
  });

  final String hintText;
  final List<String> suggestions;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onSuggestionSelected;

  @override
  State<KcSearchBarUI> createState() => _KcSearchBarUIState();
}

class _KcSearchBarUIState extends State<KcSearchBarUI> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showDropdown = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _showDropdown = _focusNode.hasFocus && _controller.text.isNotEmpty);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final filteredSuggestions = widget.suggestions
        .where((s) => s.toLowerCase().contains(_controller.text.toLowerCase()))
        .toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          onChanged: (val) {
            setState(() => _showDropdown = _focusNode.hasFocus && val.isNotEmpty);
            if (widget.onChanged != null) widget.onChanged!(val);
          },
          onSubmitted: (val) {
            setState(() => _showDropdown = false);
            if (widget.onSubmitted != null) widget.onSubmitted!(val);
          },
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: const Icon(Icons.search_rounded, size: 20),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    onPressed: () {
                      _controller.clear();
                      setState(() => _showDropdown = false);
                      if (widget.onChanged != null) widget.onChanged!('');
                    },
                  )
                : null,
          ),
        ),
        if (_showDropdown && filteredSuggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: scheme.outline),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: filteredSuggestions.length > 5 ? 5 : filteredSuggestions.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, idx) {
                final suggestion = filteredSuggestions[idx];
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.history_rounded, size: 16),
                  title: Text(suggestion),
                  onTap: () {
                    _controller.text = suggestion;
                    setState(() => _showDropdown = false);
                    _focusNode.unfocus();
                    if (widget.onSuggestionSelected != null) {
                      widget.onSuggestionSelected!(suggestion);
                    }
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
