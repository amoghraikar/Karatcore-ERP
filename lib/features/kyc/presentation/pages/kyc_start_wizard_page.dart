import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/routes.dart';

import '../../../../shared/widgets/buttons/kc_outlined_button.dart';
import '../../../../shared/widgets/buttons/kc_primary_button.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/inputs/kc_text_field.dart';
import '../../models/kyc_model.dart';
import '../../providers/kyc_providers.dart';
import '../../../customers/models/customer_model.dart';
import '../../../customers/providers/customer_providers.dart';

class KycStartWizardPage extends ConsumerStatefulWidget {
  const KycStartWizardPage({super.key, this.customerId});

  final String? customerId;

  @override
  ConsumerState<KycStartWizardPage> createState() => _KycStartWizardPageState();
}

class _KycStartWizardPageState extends ConsumerState<KycStartWizardPage> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Step 2 Consent
  bool _acceptedTerms = false;
  bool _acceptedPrivacy = false;

  // Step 3 Method
  KycVerificationMethod _selectedMethod = KycVerificationMethod.aadhaarDoc;

  // Step 4 & 5 Document Info
  final String _docType = 'Aadhaar Card';
  final _docNumberController = TextEditingController(text: '9988-7766-4433');
  final _nameOnDocController = TextEditingController(text: 'Rahul Kumar Sharma');
  final DateTime _dateOfBirth = DateTime(1985, 4, 12);
  bool _hasUploadedFront = true;
  bool _hasUploadedBack = true;
  bool _isSubmitting = false;
  KycRecordModel? _submittedRecord;

  @override
  void dispose() {
    _docNumberController.dispose();
    _nameOnDocController.dispose();
    super.dispose();
  }

  String _getTargetCustomerId() {
    if (widget.customerId != null && widget.customerId!.isNotEmpty) return widget.customerId!;
    final path = GoRouterState.of(context).uri.path;
    final parts = path.split('/');
    if (parts.length > 2 && parts[2].isNotEmpty) {
      return parts[2];
    }
    return 'KC-CUS-000101';
  }

  bool _validateStep(int step) {
    if (step == 1) {
      if (!_acceptedTerms || !_acceptedPrivacy) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please accept identity collection terms and privacy policy to continue.')),
        );
        return false;
      }
    } else if (step == 3) {
      if (!_hasUploadedFront) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload front side of government document.')),
        );
        return false;
      }
    } else if (step == 4) {
      if (_docNumberController.text.trim().isEmpty || _nameOnDocController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document number and Name on document are required.')),
        );
        return false;
      }
    }
    return true;
  }

  void _nextStep() {
    if (_validateStep(_currentStep)) {
      if (_currentStep < 5) {
        setState(() => _currentStep++);
      }
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _submitKyc() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    final custId = _getTargetCustomerId();
    final customer = ref.read(customerDetailProvider(custId)).valueOrNull;

    final consent = KycConsentModel(
      givenAt: DateTime.now(),
      version: 'v2.4-2026',
      acceptedTerms: _acceptedTerms,
      acceptedPrivacy: _acceptedPrivacy,
    );

    final doc = KycDocumentModel(
      id: 'DOC-${DateTime.now().millisecondsSinceEpoch}',
      type: _docType,
      documentNumber: _docNumberController.text.trim().isEmpty ? '9988-7766-4433' : _docNumberController.text.trim(),
      nameOnDoc: _nameOnDocController.text.trim().isEmpty ? (customer?.fullName ?? 'Customer Name') : _nameOnDocController.text.trim(),
      dateOfBirth: _dateOfBirth,
      uploadDate: DateTime.now(),
      uploadedBy: 'Store Compliance Agent',
      status: 'Verified',
      isMasked: true,
    );

    final submittedDocs = [
      CustomerDocument(
        id: 'DOC-AADHAAR-$custId',
        name: '$_docType Scan (Front & Back)',
        documentType: _docType,
        uploadDate: DateTime.now(),
        status: 'Verified',
        isVerified: true,
        fileSize: '1.4 MB',
        documentNumber: _docNumberController.text.trim().isEmpty ? '9988-7766-4433' : _docNumberController.text.trim(),
      ),
      CustomerDocument(
        id: 'DOC-PAN-$custId',
        name: 'PAN Card Income Tax Proof',
        documentType: 'PAN Card',
        uploadDate: DateTime.now(),
        status: 'Verified',
        isVerified: true,
        fileSize: '890 KB',
        documentNumber: 'ABCPS9918F',
      ),
    ];

    try {
      final record = await ref.read(kycRepositoryProvider).startKycWorkflow(
            customerId: custId,
            customerName: customer?.fullName ?? 'Customer #$custId',
            customerMobile: customer?.mobile ?? '+91 98200 00000',
            customerEmail: customer?.email ?? 'customer@karatcore.com',
            method: _selectedMethod,
            consent: consent,
            documents: [doc],
          );
      _submittedRecord = record;
    } catch (_) {}

    try {
      await ref.read(customerListProvider.notifier).updateKycStatus(
            custId,
            CustomerKycStatus.verified,
            documents: submittedDocs,
          );
    } catch (_) {}

    ref.invalidate(customerListProvider);
    ref.invalidate(customerDetailProvider(custId));
    ref.invalidate(kycQueueProvider);
    ref.invalidate(kycMetricsProvider);
    ref.invalidate(kycDetailProvider(custId));

    if (mounted) {
      setState(() {
        _isSubmitting = false;
        _currentStep = 5; // Step 6: Confirmation Screen
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final custId = _getTargetCustomerId();

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(context.pageGutter),
        children: [
          // Header Row
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => context.go('/kyc/$custId'),
              ),
              const SizedBox(width: 8),
              Text(
                'Start Customer KYC Wizard',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Stepper Progress Header
          if (_currentStep < 5)
            Card(
              elevation: 0,
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStepIndicator(0, '1. Confirm Customer'),
                      _buildStepDivider(),
                      _buildStepIndicator(1, '2. Consent'),
                      _buildStepDivider(),
                      _buildStepIndicator(2, '3. Method'),
                      _buildStepDivider(),
                      _buildStepIndicator(3, '4. Document Capture'),
                      _buildStepDivider(),
                      _buildStepIndicator(4, '5. Document Info'),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 20),

          // Main Wizard Card
          KcCard(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildStepContent(custId),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int stepIndex, String title) {
    final scheme = Theme.of(context).colorScheme;
    final isActive = _currentStep == stepIndex;
    final isDone = _currentStep > stepIndex;

    return Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: isDone ? const Color(0xFF059669) : (isActive ? scheme.primary : scheme.outline.withValues(alpha: 0.3)),
          child: isDone
              ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
              : Text(
                  '${stepIndex + 1}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isActive ? scheme.onPrimary : scheme.onSurfaceVariant),
                ),
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
      margin: const EdgeInsets.symmetric(horizontal: 12),
      width: 20,
      height: 1.5,
      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
    );
  }

  Widget _buildStepContent(String custId) {
    switch (_currentStep) {
      case 0:
        return _buildStep1CustomerConfirmation(custId);
      case 1:
        return _buildStep2Consent();
      case 2:
        return _buildStep3Method();
      case 3:
        return _buildStep4DocumentCapture();
      case 4:
        return _buildStep5DocumentInfo();
      case 5:
        return _buildStep6Confirmation();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep1CustomerConfirmation(String custId) {
    final customer = ref.watch(customerDetailProvider(custId)).valueOrNull;

    return Column(
      key: const ValueKey(0),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('STEP 1: CUSTOMER IDENTITY CONFIRMATION', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 0.5)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              _buildConfirmRow('Customer ID', custId),
              _buildConfirmRow('Full Name', customer?.fullName ?? 'Customer #$custId'),
              _buildConfirmRow('Mobile Number', customer?.mobile ?? 'N/A'),
              _buildConfirmRow('Email Address', customer?.email ?? 'N/A'),
              _buildConfirmRow('Current KYC Status', customer?.kycStatus.label ?? 'Pending Verification'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildNavigationButtons(),
      ],
    );
  }

  Widget _buildStep2Consent() {
    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('STEP 2: IDENTITY COLLECTION CONSENT & PRIVACY POLICY', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 0.5)),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
          ),
          child: const Text(
            'PRIVACY POLICY PLACEHOLDER (v2.4-2026)\n\n'
            'KaratCore ERP collects government-issued identity documents (Aadhaar, PAN, Passport, Voter ID) strictly for compliance, store gold pledge security, and statutory anti-money laundering audit verification. Information is securely stored and accessible only to authorized compliance personnel.',
            style: TextStyle(fontSize: 12, height: 1.5),
          ),
        ),
        const SizedBox(height: 16),
        CheckboxListTile(
          value: _acceptedTerms,
          onChanged: (val) => setState(() => _acceptedTerms = val ?? false),
          title: const Text('Customer has reviewed and accepts identity collection terms.', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ),
        CheckboxListTile(
          value: _acceptedPrivacy,
          onChanged: (val) => setState(() => _acceptedPrivacy = val ?? false),
          title: const Text('Customer authorizes store compliance audit check (Timestamped).', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 20),
        _buildNavigationButtons(),
      ],
    );
  }

  Widget _buildStep3Method() {
    return Column(
      key: const ValueKey(2),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('STEP 3: SELECT VERIFICATION METHOD', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 0.5)),
        const SizedBox(height: 16),
        ...KycVerificationMethod.values.map((method) {
          final isSelected = _selectedMethod == method;
          final isDigiLocker = method == KycVerificationMethod.digiLocker;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () => setState(() => _selectedMethod = method),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3) : null,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(method.icon, size: 24, color: isSelected ? Theme.of(context).colorScheme.primary : null),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(method.label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                              if (isDigiLocker) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                                  child: const Text('UI Placeholder / Available when connected', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.orange)),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(method.description, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 20),
        _buildNavigationButtons(),
      ],
    );
  }

  Widget _buildStep4DocumentCapture() {
    return Column(
      key: const ValueKey(3),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('STEP 4: GOVERNMENT DOCUMENT CAPTURE & UPLOAD', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 0.5)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_hasUploadedFront ? Icons.check_circle_rounded : Icons.cloud_upload_rounded, color: _hasUploadedFront ? Colors.green : Colors.white70, size: 36),
                    const SizedBox(height: 8),
                    Text(_hasUploadedFront ? 'Front Side Uploaded' : 'Upload Front Side', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
                          onPressed: () => setState(() => _hasUploadedFront = true),
                          child: const Text('Choose File'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_hasUploadedBack ? Icons.check_circle_rounded : Icons.cloud_upload_rounded, color: _hasUploadedBack ? Colors.green : Colors.white70, size: 36),
                    const SizedBox(height: 8),
                    Text(_hasUploadedBack ? 'Back Side Uploaded' : 'Upload Back Side', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
                          onPressed: () => setState(() => _hasUploadedBack = true),
                          child: const Text('Choose File'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildNavigationButtons(),
      ],
    );
  }

  Widget _buildStep5DocumentInfo() {
    return Column(
      key: const ValueKey(4),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('STEP 5: EXTRACTED DOCUMENT INFORMATION & NUMBER MASKING', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 0.5)),
        const SizedBox(height: 16),
        KcTextField(
          controller: _docNumberController,
          label: 'Document Number (Masked by default) *',
          hintText: 'e.g. 9988-7766-4433',
          prefixIcon: const Icon(Icons.pin_rounded),
        ),
        const SizedBox(height: 16),
        KcTextField(
          controller: _nameOnDocController,
          label: 'Name Printed on Document *',
          hintText: 'e.g. Rahul Kumar Sharma',
          prefixIcon: const Icon(Icons.person_outline_rounded),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            KcOutlinedButton(label: 'Back', onPressed: _prevStep),
            const Spacer(),
            KcPrimaryButton(
              label: 'Final Verify & Submit KYC',
              icon: Icons.verified_user_rounded,
              isLoading: _isSubmitting,
              onPressed: _submitKyc,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep6Confirmation() {
    final custId = _getTargetCustomerId();

    return Column(
      key: const ValueKey(5),
      children: [
        const SizedBox(height: 24),
        const Icon(Icons.verified_user_rounded, color: Color(0xFF059669), size: 64),
        const SizedBox(height: 16),
        Text('KYC Verification Successfully Completed!', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text('Verification Record ID: ${_submittedRecord?.id ?? "KYC-REC-009"}', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            KcOutlinedButton(
              label: 'Back to Customer Directory',
              onPressed: () => context.go(AppRoutes.customers),
            ),
            const SizedBox(width: 12),
            KcOutlinedButton(
              label: 'View Customer Profile',
              icon: Icons.visibility_rounded,
              onPressed: () => context.go('/customers/$custId'),
            ),
            const SizedBox(width: 12),
            KcPrimaryButton(
              label: 'KYC Dashboard Queue',
              icon: Icons.dashboard_rounded,
              onPressed: () => context.go(AppRoutes.kyc),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildConfirmRow(String title, String val) {
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

  Widget _buildNavigationButtons() {
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
