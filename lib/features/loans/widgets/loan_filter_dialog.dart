import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/loan_model.dart';
import '../providers/loan_providers.dart';
import '../repository/loan_repository.dart';

class LoanFilterDialog extends ConsumerStatefulWidget {
  const LoanFilterDialog({super.key});

  @override
  ConsumerState<LoanFilterDialog> createState() => _LoanFilterDialogState();
}

class _LoanFilterDialogState extends ConsumerState<LoanFilterDialog> {
  LoanStatus? _selectedStatus;
  LoanRiskStatus? _selectedRisk;
  String? _selectedMetal;
  String? _selectedBranch;

  final List<String> _branches = [
    'Main Branch (Store 01)',
    'North Extension Branch',
    'South Jeweller Hub',
  ];

  @override
  void initState() {
    super.initState();
    final current = ref.read(loanFilterProvider);
    _selectedStatus = current.status;
    _selectedRisk = current.riskStatus;
    _selectedMetal = current.metalType;
    _selectedBranch = current.branch;
  }

  void _apply() {
    final filters = LoanFilterParams(
      status: _selectedStatus,
      riskStatus: _selectedRisk,
      metalType: _selectedMetal,
      branch: _selectedBranch,
    );
    ref.read(loanListProvider.notifier).updateFilters(filters);
    Navigator.of(context).pop();
  }

  void _clear() {
    setState(() {
      _selectedStatus = null;
      _selectedRisk = null;
      _selectedMetal = null;
      _selectedBranch = null;
    });
    ref.read(loanListProvider.notifier).clearFilters();
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
              Text('Filter Gold & Silver Loans', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.of(context).pop()),
            ],
          ),
          const Divider(height: 24),

          // Loan Status Filter
          Text('Loan Account Status', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: LoanStatus.values.map((st) {
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
          const SizedBox(height: 16),

          // Risk Filter
          Text('Risk Level', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Row(
            children: LoanRiskStatus.values.map((rk) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(rk.label),
                  selected: _selectedRisk == rk,
                  onSelected: (val) => setState(() => _selectedRisk = val ? rk : null),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Collateral Metal Type Filter
          Text('Collateral Metal Type', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Row(
            children: ['Gold', 'Silver', 'Other'].map((m) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(m),
                  selected: _selectedMetal == m,
                  onSelected: (val) => setState(() => _selectedMetal = val ? m : null),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Branch Filter
          Text('Store Branch', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _selectedBranch,
            decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Select Branch Location'),
            onChanged: (val) => setState(() => _selectedBranch = val),
            items: _branches.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
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
                child: const Text('Apply Loan Filters'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> showLoanFilterSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (context) => const SingleChildScrollView(child: LoanFilterDialog()),
  );
}
