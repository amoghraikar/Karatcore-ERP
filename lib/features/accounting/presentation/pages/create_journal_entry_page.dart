import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/formatters.dart';

import '../../../../shared/widgets/buttons/kc_outlined_button.dart';
import '../../../../shared/widgets/buttons/kc_primary_button.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/feedback/kc_skeleton_loader.dart';
import '../../../../shared/widgets/feedback/kc_status_badge.dart';
import '../../../../shared/widgets/inputs/kc_text_field.dart';

import '../../models/accounting_model.dart';
import '../../providers/accounting_providers.dart';

class LineFormState {
  LineFormState({
    required this.accountId,
    required this.accountName,
    required this.debit,
    required this.credit,
    required this.description,
  });

  String accountId;
  String accountName;
  double debit;
  double credit;
  String description;
}

class CreateJournalEntryPage extends ConsumerStatefulWidget {
  const CreateJournalEntryPage({super.key});

  @override
  ConsumerState<CreateJournalEntryPage> createState() => _CreateJournalEntryPageState();
}

class _CreateJournalEntryPageState extends ConsumerState<CreateJournalEntryPage> {
  int _currentStep = 0;
  final _refController = TextEditingController(text: 'JV-2026-901');
  final _descController = TextEditingController(text: 'Quarterly interest accrual & vault maintenance adjustment');

  final List<LineFormState> _lines = [
    LineFormState(accountId: 'ACC-107', accountName: 'Interest Receivable — Accrued', debit: 50000.0, credit: 0.0, description: 'Debit Interest Receivable'),
    LineFormState(accountId: 'ACC-401', accountName: 'Pledge Interest Income', debit: 0.0, credit: 50000.0, description: 'Credit Interest Income'),
  ];

  bool _isSubmitting = false;

  double get _totalDebit => _lines.fold(0.0, (sum, l) => sum + l.debit);
  double get _totalCredit => _lines.fold(0.0, (sum, l) => sum + l.credit);
  double get _difference => (_totalDebit - _totalCredit).abs();
  bool get _isBalanced => _difference < 0.01;

  void _addLine() {
    setState(() {
      _lines.add(
        LineFormState(
          accountId: 'ACC-101',
          accountName: 'Cash in Vault',
          debit: 0.0,
          credit: 0.0,
          description: 'Adjustment line',
        ),
      );
    });
  }

  void _removeLine(int index) {
    if (_lines.length > 2) {
      setState(() => _lines.removeAt(index));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('A journal entry must contain at least 2 lines.')));
    }
  }

  void _nextStep() {
    if (_currentStep == 2 && !_isBalanced) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('DOUBLE-ENTRY ERROR: Total Debit must equal Total Credit before submission!'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }
    if (_currentStep < 4) {
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _submitJournal() async {
    if (!_isBalanced) return;

    setState(() => _isSubmitting = true);
    final now = DateTime.now();

    final entry = JournalEntryModel(
      id: 'JNL-${now.millisecondsSinceEpoch.toString().substring(6)}',
      date: now,
      reference: _refController.text.trim(),
      description: _descController.text.trim(),
      lines: _lines
          .map((l) => JournalLineModel(
                lineId: 'L-${_lines.indexOf(l) + 1}',
                accountId: l.accountId,
                accountName: l.accountName,
                debit: l.debit,
                credit: l.credit,
                description: l.description,
              ))
          .toList(),
      createdBy: 'Chief Accountant',
    );

    await ref.read(journalEntriesProvider.notifier).addJournalEntry(entry);

    if (mounted) {
      setState(() {
        _isSubmitting = false;
        _currentStep = 4; // Final confirmation
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(context.pageGutter),
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => context.go(AppRoutes.accountingJournal),
              ),
              const SizedBox(width: 8),
              Text(
                'Guided Journal Entry Wizard',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Stepper Tabs Header
          if (_currentStep < 4)
            Card(
              elevation: 0,
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStepTab(0, '1. Basic Info'),
                    _buildStepTab(1, '2. Entry Lines'),
                    _buildStepTab(2, '3. Double-Entry Check'),
                    _buildStepTab(3, '4. Review & Submit'),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 20),

          KcCard(
            padding: const EdgeInsets.all(24),
            child: _buildStepContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildStepTab(int index, String label) {
    final isActive = _currentStep == index;
    final isDone = _currentStep > index;
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: isDone ? const Color(0xFF059669) : (isActive ? scheme.primary : scheme.outline.withValues(alpha: 0.3)),
          child: isDone
              ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
              : Text('${index + 1}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isActive ? scheme.onPrimary : scheme.onSurfaceVariant)),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontWeight: isActive || isDone ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? scheme.primary : scheme.onSurfaceVariant,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1BasicInfo();
      case 1:
        return _buildStep2Lines();
      case 2:
        return _buildStep3Validation();
      case 3:
        return _buildStep4Review();
      case 4:
        return _buildStep5Confirmation();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep1BasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('STEP 1: JOURNAL ENTRY BASIC INFORMATION', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        KcTextField(controller: _refController, label: 'Voucher Reference ID *'),
        const SizedBox(height: 16),
        KcTextField(controller: _descController, label: 'Journal Header Description *', maxLines: 2),
        const SizedBox(height: 24),
        _buildNavButtons(),
      ],
    );
  }

  Widget _buildStep2Lines() {
    final accountsAsync = ref.watch(chartOfAccountsProvider(null));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('STEP 2: JOURNAL ENTRY LINES', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
            OutlinedButton.icon(
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Add Line'),
              onPressed: _addLine,
            ),
          ],
        ),
        const SizedBox(height: 16),

        accountsAsync.when(
          loading: () => const KcSkeletonLoader(height: 200),
          error: (err, st) => Text('Error loading accounts: $err'),
          data: (accounts) {
            if (accounts.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text('No accounts available in Chart of Accounts. Please create accounts first.'),
                ),
              );
            }

            return Column(
              children: _lines.asMap().entries.map((entry) {
                final idx = entry.key;
                final line = entry.value;

                final String? selectedAccountId = accounts.any((a) => a.id == line.accountId)
                    ? line.accountId
                    : (accounts.isNotEmpty ? accounts.first.id : null);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text('Line #${idx + 1}', style: const TextStyle(fontWeight: FontWeight.w700)),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                              onPressed: () => _removeLine(idx),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: selectedAccountId,
                          decoration: const InputDecoration(labelText: 'Target Account', border: OutlineInputBorder()),
                          onChanged: (val) {
                            if (val != null && accounts.isNotEmpty) {
                              final acc = accounts.firstWhere((a) => a.id == val, orElse: () => accounts.first);
                              setState(() {
                                line.accountId = acc.id;
                                line.accountName = acc.name;
                              });
                            }
                          },
                          items: accounts.map((a) => DropdownMenuItem(value: a.id, child: Text('${a.id} — ${a.name} (${a.type.label})'))).toList(),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: line.debit.toString(),
                                decoration: const InputDecoration(labelText: 'Debit Amount (₹)', border: OutlineInputBorder()),
                                keyboardType: TextInputType.number,
                                onChanged: (val) {
                                  setState(() => line.debit = double.tryParse(val) ?? 0.0);
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                initialValue: line.credit.toString(),
                                decoration: const InputDecoration(labelText: 'Credit Amount (₹)', border: OutlineInputBorder()),
                                keyboardType: TextInputType.number,
                                onChanged: (val) {
                                  setState(() => line.credit = double.tryParse(val) ?? 0.0);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),

        const SizedBox(height: 24),
        _buildNavButtons(),
      ],
    );
  }

  Widget _buildStep3Validation() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final isBalanced = _isBalanced;

    final Color bgColor = isBalanced
        ? (isDark ? const Color(0xFF064E3B).withValues(alpha: 0.25) : const Color(0xFFECFDF5))
        : (isDark ? const Color(0xFF7F1D1D).withValues(alpha: 0.25) : const Color(0xFFFEF2F2));
    final Color borderColor = isBalanced
        ? (isDark ? const Color(0xFF059669) : const Color(0xFF10B981))
        : (isDark ? const Color(0xFFDC2626) : const Color(0xFFEF4444));
    final Color labelColor = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155);
    final Color valueColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final Color diffColor = isBalanced
        ? (isDark ? const Color(0xFF34D399) : const Color(0xFF059669))
        : (isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626));
    final Color dividerColor = isDark
        ? (isBalanced ? const Color(0xFF059669).withValues(alpha: 0.3) : const Color(0xFFDC2626).withValues(alpha: 0.3))
        : (isBalanced ? const Color(0xFF10B981).withValues(alpha: 0.3) : const Color(0xFFEF4444).withValues(alpha: 0.3));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'STEP 3: DOUBLE-ENTRY BALANCE VALIDATION',
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Debit Amount:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: labelColor)),
                  Text(KcFormatters.inr(_totalDebit), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: valueColor)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Credit Amount:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: labelColor)),
                  Text(KcFormatters.inr(_totalCredit), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: valueColor)),
                ],
              ),
              Divider(height: 24, color: dividerColor),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Balance Difference:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: valueColor)),
                  Text(
                    KcFormatters.inr(_difference),
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: diffColor),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              KcStatusBadge(
                label: isBalanced ? 'BALANCED — Ready to Submit' : 'UNBALANCED — Total Debit != Total Credit',
                statusColor: isBalanced ? const Color(0xFF059669) : const Color(0xFFDC2626),
                icon: isBalanced ? Icons.check_circle_rounded : Icons.error_rounded,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        _buildNavButtons(),
      ],
    );
  }

  Widget _buildStep4Review() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('STEP 4: REVIEW & CONFIRM JOURNAL VOUCHER', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        _buildSummaryRow('Reference ID', _refController.text),
        _buildSummaryRow('Description', _descController.text),
        _buildSummaryRow('Total Debit', KcFormatters.inr(_totalDebit)),
        _buildSummaryRow('Total Credit', KcFormatters.inr(_totalCredit)),
        const SizedBox(height: 24),
        Row(
          children: [
            KcOutlinedButton(label: 'Back', onPressed: _prevStep),
            const Spacer(),
            KcPrimaryButton(
              label: 'Post Journal Voucher',
              icon: Icons.check_circle_rounded,
              isLoading: _isSubmitting,
              onPressed: _submitJournal,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep5Confirmation() {
    return Column(
      children: [
        const SizedBox(height: 24),
        const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 64),
        const SizedBox(height: 16),
        Text('Journal Entry Posted Successfully!', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text('Voucher Reference: ${_refController.text}', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            KcOutlinedButton(
              label: 'Return to Journal Entries',
              onPressed: () => context.go(AppRoutes.accountingJournal),
            ),
            const SizedBox(width: 16),
            KcPrimaryButton(
              label: 'Create Another Journal',
              onPressed: () {
                setState(() {
                  _currentStep = 0;
                  _lines.clear();
                  _addLine();
                  _addLine();
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String title, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13)),
          Text(val, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildNavButtons() {
    return Row(
      children: [
        if (_currentStep > 0) KcOutlinedButton(label: 'Back', onPressed: _prevStep),
        const Spacer(),
        KcPrimaryButton(
          label: 'Continue to Step ${_currentStep + 2}',
          icon: Icons.arrow_forward_rounded,
          onPressed: _nextStep,
        ),
      ],
    );
  }
}
