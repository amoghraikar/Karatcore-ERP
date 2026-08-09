import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/kyc_model.dart';
import '../providers/kyc_providers.dart';
import '../repository/kyc_repository.dart';

class KycFilterDialog extends ConsumerStatefulWidget {
  const KycFilterDialog({super.key});

  @override
  ConsumerState<KycFilterDialog> createState() => _KycFilterDialogState();
}

class _KycFilterDialogState extends ConsumerState<KycFilterDialog> {
  KycStatus? _selectedStatus;
  KycVerificationLevel? _selectedLevel;
  KycRiskStatus? _selectedRisk;
  KycVerificationMethod? _selectedMethod;

  @override
  void initState() {
    super.initState();
    final current = ref.read(kycFilterProvider);
    _selectedStatus = current.status;
    _selectedLevel = current.level;
    _selectedRisk = current.riskStatus;
    _selectedMethod = current.method;
  }

  void _apply() {
    final filters = KycFilterParams(
      status: _selectedStatus,
      level: _selectedLevel,
      riskStatus: _selectedRisk,
      method: _selectedMethod,
    );
    ref.read(kycQueueProvider.notifier).updateFilters(filters);
    Navigator.of(context).pop();
  }

  void _clear() {
    setState(() {
      _selectedStatus = null;
      _selectedLevel = null;
      _selectedRisk = null;
      _selectedMethod = null;
    });
    ref.read(kycQueueProvider.notifier).clearFilters();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      constraints: const BoxConstraints(maxWidth: 540),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filter KYC Queue', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
              IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.of(context).pop()),
            ],
          ),
          const Divider(height: 24),

          // Status Filter
          Text('KYC Status', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: KycStatus.values.map((st) {
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

          // Verification Level
          Text('Verification Level', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Row(
            children: KycVerificationLevel.values.map((lvl) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(lvl.label),
                  selected: _selectedLevel == lvl,
                  onSelected: (val) => setState(() => _selectedLevel = val ? lvl : null),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Risk Status
          Text('Risk Classification', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Row(
            children: KycRiskStatus.values.map((rk) {
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
          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              OutlinedButton(onPressed: _clear, child: const Text('Clear All')),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: scheme.primary, foregroundColor: scheme.onPrimary),
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

Future<void> showKycFilterSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (context) => const SingleChildScrollView(child: KycFilterDialog()),
  );
}
