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
import '../../../ornaments/models/ornament_model.dart';
import '../../../ornaments/providers/inventory_providers.dart';
import '../../models/loan_model.dart';
import '../../providers/loan_providers.dart';

class CreateLoanPage extends ConsumerStatefulWidget {
  const CreateLoanPage({super.key});

  @override
  ConsumerState<CreateLoanPage> createState() => _CreateLoanPageState();
}

class _CreateLoanPageState extends ConsumerState<CreateLoanPage> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Step 1: Customer Selection
  String _selectedCustomerId = 'KC-CUS-000101';
  String _selectedCustomerName = 'Rahul Kumar Sharma';
  String _selectedCustomerKycStatus = 'Verified';
  String _selectedCustomerRisk = 'Low Risk';

  // Step 2 & 3: Collateral Selection
  final List<OrnamentModel> _selectedCollateral = [];

  // Step 4 & 5: Terms & Valuation
  final _principalController = TextEditingController(text: '150000');
  final _interestRateController = TextEditingController(text: '12.0');
  final _tenureMonthsController = TextEditingController(text: '12');
  final _processingFeeController = TextEditingController(text: '500');
  InterestType _interestType = InterestType.simple;
  PaymentFrequency _frequency = PaymentFrequency.monthly;

  // Step 7: Approval
  final _reviewerNotesController = TextEditingController(text: 'Verified collateral valuation and customer KYC eligibility.');
  final _rejectionReasonController = TextEditingController();

  // Step 8: Disbursement
  DisbursementMethod _disbursementMethod = DisbursementMethod.bankTransfer;
  final _disbursementRefController = TextEditingController(text: 'NEFT-88901234');

  bool _isSubmitting = false;
  LoanModel? _createdLoan;

  @override
  void initState() {
    super.initState();
    _loadSampleCollateral();
  }

  Future<void> _loadSampleCollateral() async {
    final list = await ref.read(inventoryRepositoryProvider).getOrnaments();
    if (list.isNotEmpty && mounted) {
      setState(() {
        _selectedCollateral.add(list.first);
        if (list.length > 1) {
          _selectedCollateral.add(list[1]);
        }
      });
    }
  }

  @override
  void dispose() {
    _principalController.dispose();
    _interestRateController.dispose();
    _tenureMonthsController.dispose();
    _processingFeeController.dispose();
    _reviewerNotesController.dispose();
    _rejectionReasonController.dispose();
    _disbursementRefController.dispose();
    super.dispose();
  }

  double get _principal => double.tryParse(_principalController.text) ?? 150000.0;
  double get _interestRate => double.tryParse(_interestRateController.text) ?? 12.0;
  int get _tenureMonths => int.tryParse(_tenureMonthsController.text) ?? 12;

  double get _totalCollateralValuation {
    double sum = 0.0;
    for (final o in _selectedCollateral) {
      sum += o.valuation.totalEstimatedValue;
    }
    return sum;
  }

  double get _totalNetWeight {
    double sum = 0.0;
    for (final o in _selectedCollateral) {
      sum += o.weight.netMetalWeight;
    }
    return sum;
  }

  double get _eligibleLoanAmount => (_totalCollateralValuation * 0.75);

  bool _validateStep(int step) {
    if (step == 0 && _selectedCustomerKycStatus != 'Verified') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Warning: Selected customer KYC is NOT Verified! Please resolve KYC before proceeding with loan approval.'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return false;
    } else if (step == 1 && _selectedCollateral.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least 1 ornament for collateral pledge.')));
      return false;
    } else if (step == 4 && _principal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid loan principal amount > ₹0.')));
      return false;
    }
    return true;
  }

  void _nextStep() {
    if (_validateStep(_currentStep)) {
      if (_currentStep < 7) {
        setState(() => _currentStep++);
      }
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _submitLoanProposal() async {
    setState(() => _isSubmitting = true);

    final now = DateTime.now();
    final loanId = 'KC-LN-${now.millisecondsSinceEpoch.toString().substring(5)}';
    final pledgeId = 'KC-PLG-${now.millisecondsSinceEpoch.toString().substring(6)}';

    final loan = LoanModel(
      id: loanId,
      customerId: _selectedCustomerId,
      customerName: _selectedCustomerName,
      customerKycStatus: _selectedCustomerKycStatus,
      customerRisk: _selectedCustomerRisk,
      pledgeId: pledgeId,
      collateralOrnaments: _selectedCollateral,
      pledgeDate: now,
      maturityDate: now.add(Duration(days: _tenureMonths * 30)),
      principalAmount: _principal,
      outstandingPrincipal: _principal,
      interestRatePercentage: _interestRate,
      accruedInterest: 0.0,
      nextDueDate: now.add(const Duration(days: 30)),
      collateralTotalValue: _totalCollateralValuation,
      collateralNetWeightGrams: _totalNetWeight,
      status: LoanStatus.active,
      riskStatus: LoanRiskStatus.low,
      branch: 'Main Branch (Store 01)',
      loanOfficer: 'Arjun Mehta (Manager)',
      disbursementMethod: _disbursementMethod,
      disbursementReference: _disbursementRefController.text.trim(),
      createdAt: now,
      updatedAt: now,
    );

    final created = await ref.read(loanRepositoryProvider).createLoan(loan);

    ref.invalidate(loanListProvider);
    ref.invalidate(loanMetricsProvider);

    if (mounted) {
      setState(() {
        _isSubmitting = false;
        _createdLoan = created;
        _currentStep = 7; // Disbursed Confirmation
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
                onPressed: () => context.go(AppRoutes.loans),
              ),
              const SizedBox(width: 8),
              Text(
                'New Loan & Pledge Creation Wizard',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Stepper Header Tabs
          if (_currentStep < 7)
            Card(
              elevation: 0,
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStepTab(0, '1. Customer'),
                      _buildStepDivider(),
                      _buildStepTab(1, '2. Collateral'),
                      _buildStepDivider(),
                      _buildStepTab(2, '3. Summary'),
                      _buildStepDivider(),
                      _buildStepTab(3, '4. Valuation'),
                      _buildStepDivider(),
                      _buildStepTab(4, '5. Loan Terms'),
                      _buildStepDivider(),
                      _buildStepTab(5, '6. Review'),
                      _buildStepDivider(),
                      _buildStepTab(6, '7. Approval'),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 20),

          // Main Step Card
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
        return _buildStep1Customer();
      case 1:
        return _buildStep2Collateral();
      case 2:
        return _buildStep3Summary();
      case 3:
        return _buildStep4Valuation();
      case 4:
        return _buildStep5Terms();
      case 5:
        return _buildStep6Review();
      case 6:
        return _buildStep7Approval();
      case 7:
        return _buildStep8DisbursementConfirmation();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep1Customer() {
    final isVerified = _selectedCustomerKycStatus == 'Verified';

    return Column(
      key: const ValueKey(0),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('STEP 1: SELECT CUSTOMER & KYC ELIGIBILITY CHECK', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),

        // Customer Selection Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const CircleAvatar(radius: 24, child: Icon(Icons.person_rounded)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_selectedCustomerName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text('Customer ID: $_selectedCustomerId • Mobile: +91 98765 43210', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              DropdownButton<String>(
                value: _selectedCustomerId,
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedCustomerId = val;
                      if (val == 'KC-CUS-000105') {
                        _selectedCustomerName = 'Amitabh Banerjee';
                        _selectedCustomerKycStatus = 'Pending';
                        _selectedCustomerRisk = 'High Risk';
                      } else {
                        _selectedCustomerName = 'Rahul Kumar Sharma';
                        _selectedCustomerKycStatus = 'Verified';
                        _selectedCustomerRisk = 'Low Risk';
                      }
                    });
                  }
                },
                items: const [
                  DropdownMenuItem(value: 'KC-CUS-000101', child: Text('Rahul Kumar Sharma (KYC Verified)')),
                  DropdownMenuItem(value: 'KC-CUS-000105', child: Text('Amitabh Banerjee (KYC Pending Warning)')),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // KYC Warning / Success Banner
        if (!isVerified)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFEF4444)),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('KYC STATUS UNVERIFIED — LOAN BLOCK', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF991B1B))),
                      SizedBox(height: 2),
                      Text('This customer profile does not have an approved KYC record. Loan approval is blocked until identity verification is completed.', style: TextStyle(fontSize: 12, color: Color(0xFF7F1D1D))),
                    ],
                  ),
                ),
                KcStatusBadge(label: 'KYC Pending', statusColor: Color(0xFFDC2626)),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF10B981)),
            ),
            child: const Row(
              children: [
                Icon(Icons.verified_user_rounded, color: Color(0xFF059669), size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('KYC VERIFIED & LOAN ELIGIBLE', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF065F46))),
                      SizedBox(height: 2),
                      Text('Customer Aadhaar & PAN identity verified. Eligible for Gold/Silver loan pledge proposal.', style: TextStyle(fontSize: 12, color: Color(0xFF047857))),
                    ],
                  ),
                ),
                KcStatusBadge(label: 'Verified', statusColor: Color(0xFF059669)),
              ],
            ),
          ),

        const SizedBox(height: 24),
        _buildNavButtons(),
      ],
    );
  }

  Widget _buildStep2Collateral() {
    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('STEP 2: SELECT PLEDGED ORNAMENTS (COLLATERAL)', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        Text('Selected Ornaments (${_selectedCollateral.length})', style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        ..._selectedCollateral.map((orn) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Card(
              child: ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(image: NetworkImage(orn.imageUrl), fit: BoxFit.cover),
                  ),
                ),
                title: Text(orn.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text('${orn.id} • ${orn.metalType.label} ${orn.purity.label} • Gross: ${orn.weight.grossWeight}g / Net: ${orn.weight.netMetalWeight}g'),
                trailing: Text(KcFormatters.inr(orn.valuation.totalEstimatedValue), style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          );
        }),
        const SizedBox(height: 24),
        _buildNavButtons(),
      ],
    );
  }

  Widget _buildStep3Summary() {
    return Column(
      key: const ValueKey(2),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('STEP 3: COLLATERAL SUMMARY & LTV ESTIMATE', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              _buildSummaryRow('Pledged Items Count', '${_selectedCollateral.length} Ornaments'),
              _buildSummaryRow('Total Net Metal Weight', '${_totalNetWeight.toStringAsFixed(2)} g'),
              _buildSummaryRow('Total Estimated Collateral Value', KcFormatters.inr(_totalCollateralValuation)),
              const Divider(height: 24),
              _buildSummaryRow('Configured LTV Benchmark', '75.0% LTV'),
              _buildSummaryRow('Estimated Max Eligible Loan Amount', KcFormatters.inr(_eligibleLoanAmount)),
            ],
          ),
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
        Text('STEP 4: DETAILED VALUATION BREAKDOWN (SERVICE ISOLATED)', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        const Text('Valuation summary is calculated using standard metal rates: Gold 22K @ ₹6,640/g, Silver 925 @ ₹88/g.'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(10)),
          child: Column(
            children: [
              _buildSummaryRow('Total Metal Valuation', KcFormatters.inr(_totalCollateralValuation)),
              _buildSummaryRow('Eligible Loan Capacity (75% LTV)', KcFormatters.inr(_eligibleLoanAmount)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildNavButtons(),
      ],
    );
  }

  Widget _buildStep5Terms() {
    return Column(
      key: const ValueKey(4),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('STEP 5: CONFIGURE LOAN TERMS & INTEREST RATE', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: KcTextField(
                controller: _principalController,
                label: 'Sanctioned Principal Amount (₹) *',
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: KcTextField(
                controller: _interestRateController,
                label: 'Interest Rate (% p.a.) *',
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: KcTextField(
                controller: _tenureMonthsController,
                label: 'Tenure (Months) *',
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Interest Calculation Type *', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<InterestType>(
                    initialValue: _interestType,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    onChanged: (val) => setState(() => _interestType = val!),
                    items: InterestType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label))).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Payment Frequency *', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<PaymentFrequency>(
                    initialValue: _frequency,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    onChanged: (val) => setState(() => _frequency = val!),
                    items: PaymentFrequency.values.map((f) => DropdownMenuItem(value: f, child: Text(f.label))).toList(),
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

  Widget _buildStep6Review() {
    final estInterest = (_principal * (_interestRate / 100.0) * (_tenureMonths / 12.0));

    return Column(
      key: const ValueKey(5),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('STEP 6: LOAN SUMMARY & SCHEDULE PREVIEW', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(10)),
          child: Column(
            children: [
              _buildSummaryRow('Customer', '$_selectedCustomerName ($_selectedCustomerId)'),
              _buildSummaryRow('Collateral Items', '${_selectedCollateral.length} Ornaments (${_totalNetWeight.toStringAsFixed(1)}g Net Wt)'),
              _buildSummaryRow('Sanctioned Principal', KcFormatters.inr(_principal)),
              _buildSummaryRow('Interest Rate & Type', '$_interestRate% p.a. (${_interestType.label})'),
              _buildSummaryRow('Expected Annual Interest', KcFormatters.inr(estInterest)),
              _buildSummaryRow('Tenure', '$_tenureMonths Months'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildNavButtons(),
      ],
    );
  }

  Widget _buildStep7Approval() {
    return Column(
      key: const ValueKey(6),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('STEP 7: MANAGER APPROVAL REVIEW', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        KcTextField(
          controller: _reviewerNotesController,
          label: 'Reviewer Approval Notes',
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Disbursement Method *', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<DisbursementMethod>(
                    initialValue: _disbursementMethod,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    onChanged: (val) => setState(() => _disbursementMethod = val!),
                    items: DisbursementMethod.values.map((m) => DropdownMenuItem(value: m, child: Text(m.label))).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: KcTextField(
                controller: _disbursementRefController,
                label: 'Payment Transaction Ref #',
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            KcOutlinedButton(label: 'Back', onPressed: _prevStep),
            const Spacer(),
            KcPrimaryButton(
              label: 'Approve & Disburse Loan',
              icon: Icons.check_circle_rounded,
              isLoading: _isSubmitting,
              onPressed: _submitLoanProposal,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep8DisbursementConfirmation() {
    return Column(
      key: const ValueKey(7),
      children: [
        const SizedBox(height: 24),
        const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 64),
        const SizedBox(height: 16),
        Text('Loan Successfully Approved & Disbursed!', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text('Loan Account ID: ${_createdLoan?.id ?? "KC-LN-000101"} • Pledge ID: ${_createdLoan?.pledgeId ?? "KC-PLG-000101"}', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            KcOutlinedButton(
              label: 'Return to Loans List',
              onPressed: () => context.go(AppRoutes.loans),
            ),
            const SizedBox(width: 16),
            KcPrimaryButton(
              label: 'Open Loan Details',
              icon: Icons.launch_rounded,
              onPressed: () => context.go('/loans/${_createdLoan?.id ?? "KC-LN-000101"}'),
            ),
          ],
        ),
        const SizedBox(height: 24),
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
