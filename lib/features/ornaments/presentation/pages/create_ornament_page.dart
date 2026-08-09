import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/formatters.dart';

import '../../../../shared/widgets/buttons/kc_outlined_button.dart';
import '../../../../shared/widgets/buttons/kc_primary_button.dart';
import '../../../../shared/widgets/cards/kc_card.dart';

import '../../../../shared/widgets/feedback/kc_status_badge.dart';
import '../../../../shared/widgets/inputs/kc_text_field.dart';
import '../../models/ornament_model.dart';
import '../../providers/inventory_providers.dart';

class CreateOrnamentPage extends ConsumerStatefulWidget {
  const CreateOrnamentPage({super.key});

  @override
  ConsumerState<CreateOrnamentPage> createState() => _CreateOrnamentPageState();
}

class _CreateOrnamentPageState extends ConsumerState<CreateOrnamentPage> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Step 1: Basic Info
  final _nameController = TextEditingController(text: 'Royal 22K Gold Antique Necklace');
  OrnamentCategory _category = OrnamentCategory.necklaces;
  final _subcategoryController = TextEditingController(text: 'Heritage Antique');
  final _descriptionController = TextEditingController(text: 'Handcrafted 22K Gold antique necklace set with ruby stones and intricate filigree work.');

  // Step 2: Metal & Purity
  MetalType _metalType = MetalType.gold;
  OrnamentPurity _purity = OrnamentPurity.k22_916;

  // Step 3: Weight Breakdown
  final _grossWeightController = TextEditingController(text: '48.50');
  final _stoneWeightController = TextEditingController(text: '2.50');
  final _otherWeightController = TextEditingController(text: '0.50');

  // Step 4: Valuation
  final _metalRateController = TextEditingController(text: '6640.80');
  final _makingChargesController = TextEditingController(text: '25000.00');
  final _stoneValueController = TextEditingController(text: '12000.00');

  // Step 5: Ownership
  OwnershipType _ownershipType = OwnershipType.shopOwned;
  final String _selectedCustomerId = 'KC-CUS-000101';
  final String _selectedCustomerName = 'Rahul Kumar Sharma';

  // Step 6: Location
  String _branch = 'Main Branch (Store 01)';
  final String _storageArea = 'Central Vault Safe';
  String _locker = 'Locker #01 (Main Safe)';
  final String _tray = 'Tray #04';

  bool _isSubmitting = false;
  OrnamentModel? _createdOrnament;

  @override
  void dispose() {
    _nameController.dispose();
    _subcategoryController.dispose();
    _descriptionController.dispose();
    _grossWeightController.dispose();
    _stoneWeightController.dispose();
    _otherWeightController.dispose();
    _metalRateController.dispose();
    _makingChargesController.dispose();
    _stoneValueController.dispose();
    super.dispose();
  }

  double get _gross => double.tryParse(_grossWeightController.text) ?? 0.0;
  double get _stone => double.tryParse(_stoneWeightController.text) ?? 0.0;
  double get _other => double.tryParse(_otherWeightController.text) ?? 0.0;
  double get _netMetalWeight {
    final net = _gross - _stone - _other;
    return net > 0 ? net : 0.0;
  }

  double get _metalRate => double.tryParse(_metalRateController.text) ?? 6640.80;
  double get _makingCharges => double.tryParse(_makingChargesController.text) ?? 0.0;
  double get _stoneValue => double.tryParse(_stoneValueController.text) ?? 0.0;
  double get _metalValue => _netMetalWeight * _metalRate;
  double get _totalEstimatedValue => _metalValue + _makingCharges + _stoneValue;

  bool _validateStep(int step) {
    if (step == 0 && _nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ornament name is required.')));
      return false;
    } else if (step == 2 && _gross <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid Gross Weight > 0g.')));
      return false;
    }
    return true;
  }

  void _nextStep() {
    if (_validateStep(_currentStep)) {
      if (_currentStep < 8) {
        setState(() => _currentStep++);
      }
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _submitOrnament() async {
    setState(() => _isSubmitting = true);

    final now = DateTime.now();
    final id = 'KC-ORN-${now.millisecondsSinceEpoch.toString().substring(5)}';

    final weight = WeightBreakdown(
      grossWeight: _gross,
      stoneWeight: _stone,
      otherWeight: _other,
    );

    final valuation = ValuationBreakdown(
      metalRate: _metalRate,
      metalValue: _metalValue,
      makingCharges: _makingCharges,
      stoneValue: _stoneValue,
      totalEstimatedValue: _totalEstimatedValue,
    );

    final location = InventoryLocationModel(
      branch: _branch,
      storageArea: _storageArea,
      locker: _locker,
      tray: _tray,
    );

    final ornament = OrnamentModel(
      id: id,
      name: _nameController.text.trim(),
      category: _category,
      subcategory: _subcategoryController.text.trim(),
      description: _descriptionController.text.trim(),
      metalType: _metalType,
      purity: _purity,
      weight: weight,
      valuation: valuation,
      status: OrnamentStatus.available,
      ownershipType: _ownershipType,
      ownerCustomerId: _ownershipType == OwnershipType.customerOwned ? _selectedCustomerId : null,
      ownerCustomerName: _ownershipType == OwnershipType.customerOwned ? _selectedCustomerName : null,
      location: location,
      barcode: '8901234567890',
      qrCode: 'QR-$id',
      createdAt: now,
      updatedAt: now,
    );

    final created = await ref.read(inventoryRepositoryProvider).createOrnament(ornament);

    ref.invalidate(ornamentListProvider);
    ref.invalidate(inventoryMetricsProvider);

    if (mounted) {
      setState(() {
        _isSubmitting = false;
        _createdOrnament = created;
        _currentStep = 8; // Confirmation Step
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
                onPressed: () => context.go(AppRoutes.ornaments),
              ),
              const SizedBox(width: 8),
              Text(
                'Add New Ornament Wizard',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Stepper Header
          if (_currentStep < 8)
            Card(
              elevation: 0,
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStepTab(0, '1. Basic Info'),
                      _buildStepDivider(),
                      _buildStepTab(1, '2. Metal'),
                      _buildStepDivider(),
                      _buildStepTab(2, '3. Weight Formula'),
                      _buildStepDivider(),
                      _buildStepTab(3, '4. Valuation'),
                      _buildStepDivider(),
                      _buildStepTab(4, '5. Ownership'),
                      _buildStepDivider(),
                      _buildStepTab(5, '6. Location'),
                      _buildStepDivider(),
                      _buildStepTab(6, '7. Barcode / QR'),
                      _buildStepDivider(),
                      _buildStepTab(7, '8. Review'),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 20),

          // Main Form Card
          KcCard(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildStepContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepTab(int index, String title) {
    final scheme = Theme.of(context).colorScheme;
    final isActive = _currentStep == index;
    final isDone = _currentStep > index;

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
          title,
          style: TextStyle(
            fontWeight: isActive || isDone ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? scheme.primary : scheme.onSurfaceVariant,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildStepDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      width: 16,
      height: 1.5,
      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1Basic();
      case 1:
        return _buildStep2Metal();
      case 2:
        return _buildStep3Weight();
      case 3:
        return _buildStep4Valuation();
      case 4:
        return _buildStep5Ownership();
      case 5:
        return _buildStep6Location();
      case 6:
        return _buildStep7Barcode();
      case 7:
        return _buildStep8Review();
      case 8:
        return _buildStep9Confirmation();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep1Basic() {
    return Column(
      key: const ValueKey(0),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('STEP 1: BASIC ORNAMENT INFORMATION', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        KcTextField(
          controller: _nameController,
          label: 'Ornament Name *',
          hintText: 'e.g. Royal 22K Gold Antique Necklace',
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Category *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<OrnamentCategory>(
                    initialValue: _category,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    onChanged: (val) => setState(() => _category = val!),
                    items: OrnamentCategory.values.map((c) => DropdownMenuItem(value: c, child: Text(c.label))).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: KcTextField(
                controller: _subcategoryController,
                label: 'Subcategory / Style',
                hintText: 'e.g. Heritage Antique',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        KcTextField(
          controller: _descriptionController,
          label: 'Description & Craftsmanship Notes',
          maxLines: 2,
        ),
        const SizedBox(height: 24),
        _buildNavButtons(),
      ],
    );
  }

  Widget _buildStep2Metal() {
    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('STEP 2: METAL TYPE & PURITY SELECTION', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        const Text('Metal Type *', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        const SizedBox(height: 8),
        Row(
          children: MetalType.values.map((m) {
            final isSel = _metalType == m;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ChoiceChip(
                label: Text(m.label),
                selected: isSel,
                onSelected: (val) => setState(() => _metalType = m),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        const Text('Configurable Purity Level *', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        const SizedBox(height: 8),
        DropdownButtonFormField<OrnamentPurity>(
          initialValue: _purity,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          onChanged: (val) => setState(() => _purity = val!),
          items: OrnamentPurity.values.map((p) => DropdownMenuItem(value: p, child: Text('${p.label} — ${p.description}'))).toList(),
        ),
        const SizedBox(height: 24),
        _buildNavButtons(),
      ],
    );
  }

  Widget _buildStep3Weight() {
    return Column(
      key: const ValueKey(2),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('STEP 3: JEWELLERY WEIGHT BREAKDOWN FORMULA', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 14),

        // Formula Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildFormulaBox('Gross Weight', '${_gross.toStringAsFixed(2)}g', Colors.blue),
              const Text('—', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              _buildFormulaBox('Stones Weight', '${_stone.toStringAsFixed(2)}g', Colors.orange),
              const Text('—', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              _buildFormulaBox('Other Weight', '${_other.toStringAsFixed(2)}g', Colors.purple),
              const Text('=', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              _buildFormulaBox('Net Metal Weight', '${_netMetalWeight.toStringAsFixed(2)}g', const Color(0xFF059669)),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: KcTextField(
                controller: _grossWeightController,
                label: 'Gross Weight (grams) *',
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: KcTextField(
                controller: _stoneWeightController,
                label: 'Stones Weight (grams)',
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: KcTextField(
                controller: _otherWeightController,
                label: 'Other Weight (grams)',
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildNavButtons(),
      ],
    );
  }

  Widget _buildStep4Valuation() {
    return Column(
      key: const ValueKey(3),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('STEP 4: VALUATION & ESTIMATED VALUE (MOCK DISPLAY)', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: KcTextField(
                controller: _metalRateController,
                label: 'Metal Rate (₹ / g) *',
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: KcTextField(
                controller: _makingChargesController,
                label: 'Making Charges (₹)',
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: KcTextField(
                controller: _stoneValueController,
                label: 'Stone Value (₹)',
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(10)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Calculated Total Estimated Value:', style: TextStyle(fontSize: 12)),
                  Text(KcFormatters.inr(_totalEstimatedValue), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF059669))),
                ],
              ),
              const Text('Metal Value + Making Charges + Stone Value', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildNavButtons(),
      ],
    );
  }

  Widget _buildStep5Ownership() {
    return Column(
      key: const ValueKey(4),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('STEP 5: OWNERSHIP TYPE & CUSTOMER ASSIGNMENT', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        const Text('Ownership Classification *', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        const SizedBox(height: 8),
        DropdownButtonFormField<OwnershipType>(
          initialValue: _ownershipType,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          onChanged: (val) => setState(() => _ownershipType = val!),
          items: OwnershipType.values.map((o) => DropdownMenuItem(value: o, child: Text(o.label))).toList(),
        ),
        if (_ownershipType == OwnershipType.customerOwned || _ownershipType == OwnershipType.pledged) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                const Icon(Icons.person_rounded, size: 28, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Customer: $_selectedCustomerName', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      Text('Customer ID: $_selectedCustomerId', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                const KcStatusBadge(label: 'KYC Verified', statusColor: Color(0xFF059669), icon: Icons.verified_rounded),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
        _buildNavButtons(),
      ],
    );
  }

  Widget _buildStep6Location() {
    return Column(
      key: const ValueKey(5),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('STEP 6: STORAGE LOCATION HIERARCHY', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Branch Location *', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _branch,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    onChanged: (val) => setState(() => _branch = val!),
                    items: const [
                      DropdownMenuItem(value: 'Main Branch (Store 01)', child: Text('Main Branch (Store 01)')),
                      DropdownMenuItem(value: 'North Extension Branch', child: Text('North Extension Branch')),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Vault Locker *', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _locker,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    onChanged: (val) => setState(() => _locker = val!),
                    items: const [
                      DropdownMenuItem(value: 'Locker #01 (Main Safe)', child: Text('Locker #01 (Main Safe)')),
                      DropdownMenuItem(value: 'Locker #02 (Display Vault)', child: Text('Locker #02 (Display Vault)')),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildNavButtons(),
      ],
    );
  }

  Widget _buildStep7Barcode() {
    return Column(
      key: const ValueKey(6),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('STEP 7: BARCODE & QR CODE ASSET IDENTIFICATION', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
          child: const Column(
            children: [
              Text('STORES AUTOMATIC IDENTITY TAG GENERATION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey)),
              SizedBox(height: 12),
              Icon(Icons.qr_code_2_rounded, size: 72, color: Colors.black87),
              SizedBox(height: 8),
              Text('Barcode: 8901234567890 • QR: QR-KC-ORN-TEMP', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildNavButtons(),
      ],
    );
  }

  Widget _buildStep8Review() {
    return Column(
      key: const ValueKey(7),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('STEP 8: REVIEW COMPLETE ORNAMENT SUMMARY', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(10)),
          child: Column(
            children: [
              _buildSummaryRow('Ornament Name', _nameController.text),
              _buildSummaryRow('Category / Metal', '${_category.label} (${_metalType.label} ${_purity.label})'),
              _buildSummaryRow('Gross / Net Weight', '${_gross}g Gross / ${_netMetalWeight.toStringAsFixed(2)}g Net Metal'),
              _buildSummaryRow('Estimated Total Value', KcFormatters.inr(_totalEstimatedValue)),
              _buildSummaryRow('Ownership Type', _ownershipType.label),
              _buildSummaryRow('Location', '$_branch / $_locker'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            KcOutlinedButton(label: 'Back', onPressed: _prevStep),
            const Spacer(),
            KcPrimaryButton(
              label: 'Save & Log Ornament',
              icon: Icons.check_circle_rounded,
              isLoading: _isSubmitting,
              onPressed: _submitOrnament,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep9Confirmation() {
    return Column(
      key: const ValueKey(8),
      children: [
        const SizedBox(height: 24),
        const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 64),
        const SizedBox(height: 16),
        Text('Ornament Successfully Created & Logged!', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text('Ornament ID: ${_createdOrnament?.id ?? "KC-ORN-000101"}', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            KcOutlinedButton(
              label: 'Return to Inventory',
              onPressed: () => context.go(AppRoutes.ornaments),
            ),
            const SizedBox(width: 16),
            KcPrimaryButton(
              label: 'Open Ornament Details',
              icon: Icons.launch_rounded,
              onPressed: () => context.go('/inventory/${_createdOrnament?.id ?? "KC-ORN-000101"}'),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildFormulaBox(String label, String val, Color col) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        const SizedBox(height: 4),
        Text(val, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: col)),
      ],
    );
  }

  Widget _buildSummaryRow(String title, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
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
