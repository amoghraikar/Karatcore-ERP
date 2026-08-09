import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/customer_model.dart';
import '../providers/customer_providers.dart';
import '../repository/customer_repository.dart';

class CustomerFilterDialog extends ConsumerStatefulWidget {
  const CustomerFilterDialog({super.key});

  @override
  ConsumerState<CustomerFilterDialog> createState() => _CustomerFilterDialogState();
}

class _CustomerFilterDialogState extends ConsumerState<CustomerFilterDialog> {
  CustomerKycStatus? _selectedKyc;
  CustomerStatus? _selectedStatus;
  CustomerType? _selectedType;
  CustomerRiskLevel? _selectedRisk;
  bool? _hasActiveLoans;

  @override
  void initState() {
    super.initState();
    final current = ref.read(customerFilterProvider);
    _selectedKyc = current.kycStatus;
    _selectedStatus = current.customerStatus;
    _selectedType = current.customerType;
    _selectedRisk = current.riskLevel;
    _hasActiveLoans = current.hasActiveLoans;
  }

  void _apply() {
    final newFilters = CustomerFilterParams(
      kycStatus: _selectedKyc,
      customerStatus: _selectedStatus,
      customerType: _selectedType,
      riskLevel: _selectedRisk,
      hasActiveLoans: _hasActiveLoans,
    );
    ref.read(customerListProvider.notifier).updateFilters(newFilters);
    Navigator.of(context).pop();
  }

  void _clear() {
    setState(() {
      _selectedKyc = null;
      _selectedStatus = null;
      _selectedType = null;
      _selectedRisk = null;
      _hasActiveLoans = null;
    });
    ref.read(customerListProvider.notifier).clearFilters();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      constraints: const BoxConstraints(maxWidth: 520),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Customers',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // KYC Status
          Text('KYC Verification Status', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: CustomerKycStatus.values.map((status) {
              final isSelected = _selectedKyc == status;
              return ChoiceChip(
                label: Text(status.label),
                selected: isSelected,
                onSelected: (val) => setState(() => _selectedKyc = val ? status : null),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Customer Status
          Text('Customer Lifecycle Status', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: CustomerStatus.values.map((status) {
              final isSelected = _selectedStatus == status;
              return ChoiceChip(
                label: Text(status.label),
                selected: isSelected,
                onSelected: (val) => setState(() => _selectedStatus = val ? status : null),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Customer Type
          Text('Customer Type', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: CustomerType.values.map((type) {
              final isSelected = _selectedType == type;
              return ChoiceChip(
                avatar: Icon(type.icon, size: 16),
                label: Text(type.label),
                selected: isSelected,
                onSelected: (val) => setState(() => _selectedType = val ? type : null),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Risk Level
          Text('Risk Classification', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: CustomerRiskLevel.values.map((risk) {
              final isSelected = _selectedRisk == risk;
              return ChoiceChip(
                label: Text(risk.label),
                selected: isSelected,
                onSelected: (val) => setState(() => _selectedRisk = val ? risk : null),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              OutlinedButton(
                onPressed: _clear,
                child: const Text('Clear All'),
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                ),
                onPressed: _apply,
                child: const Text('Apply Filters'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> showCustomerFilterSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => const SingleChildScrollView(child: CustomerFilterDialog()),
  );
}
