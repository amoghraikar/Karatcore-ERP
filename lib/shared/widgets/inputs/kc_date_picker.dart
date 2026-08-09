import 'package:flutter/material.dart';
import '../../../core/utils/formatters.dart';

class KcDatePicker extends StatelessWidget {
  const KcDatePicker({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.label = 'Select Date',
  });

  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final String label;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) onDateSelected(picked);
      },
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_today_rounded),
        ),
        child: Text(
          selectedDate != null ? KcFormatters.date(selectedDate!) : 'Choose a date',
        ),
      ),
    );
  }
}
