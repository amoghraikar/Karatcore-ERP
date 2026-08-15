import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/routes.dart';

import '../../../../shared/widgets/buttons/kc_outlined_button.dart';
import '../../../../shared/widgets/buttons/kc_primary_button.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/inputs/kc_text_field.dart';
import '../../models/customer_model.dart';
import '../../providers/customer_providers.dart';

class CreateCustomerPage extends ConsumerStatefulWidget {
  const CreateCustomerPage({super.key});

  @override
  ConsumerState<CreateCustomerPage> createState() => _CreateCustomerPageState();
}

class _CreateCustomerPageState extends ConsumerState<CreateCustomerPage> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Step 1 - Basic Info
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final DateTime _dob = DateTime(1990, 1, 1);
  String _gender = 'Male';
  CustomerType _customerType = CustomerType.individual;

  // Step 2 - Contact Info
  final _mobileController = TextEditingController();
  final _altMobileController = TextEditingController();
  final _emailController = TextEditingController();

  // Step 3 - Address
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _countryController = TextEditingController(text: 'India');

  // Step 4 - Additional Info
  final _occupationController = TextEditingController();
  final _incomeController = TextEditingController();
  final _noteController = TextEditingController();
  final List<String> _selectedTags = ['New Customer'];

  bool _isSubmitting = false;
  CustomerModel? _createdCustomer;

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _mobileController.dispose();
    _altMobileController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _countryController.dispose();
    _occupationController.dispose();
    _incomeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  bool _validateStep(int step) {
    if (step == 0) {
      if (_firstNameController.text.trim().isEmpty || _lastNameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('First Name and Last Name are required.')),
        );
        return false;
      }
    } else if (step == 1) {
      if (_mobileController.text.trim().isEmpty || _emailController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mobile Number and Email Address are required.')),
        );
        return false;
      }
    } else if (step == 2) {
      if (_addressController.text.trim().isEmpty ||
          _cityController.text.trim().isEmpty ||
          _stateController.text.trim().isEmpty ||
          _pincodeController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complete address details are required.')),
        );
        return false;
      }
    }
    return true;
  }

  void _nextStep() {
    if (_validateStep(_currentStep)) {
      if (_currentStep < 4) {
        setState(() => _currentStep++);
      }
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _submitCustomer() async {
    setState(() => _isSubmitting = true);

    final newCust = CustomerModel(
      id: '',
      firstName: _firstNameController.text.trim(),
      middleName: _middleNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      dateOfBirth: _dob,
      gender: _gender,
      customerType: _customerType,
      mobile: _mobileController.text.trim(),
      alternateMobile: _altMobileController.text.trim(),
      email: _emailController.text.trim(),
      addressLine: _addressController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      pincode: _pincodeController.text.trim(),
      country: _countryController.text.trim(),
      occupation: _occupationController.text.trim().isEmpty ? 'Self-Employed' : _occupationController.text.trim(),
      annualIncome: _incomeController.text.trim().isEmpty ? '₹ 1,000,000 / Year' : _incomeController.text.trim(),
      kycStatus: CustomerKycStatus.pending,
      customerStatus: CustomerStatus.active,
      riskStatus: CustomerRiskLevel.low,
      tags: _selectedTags,
      createdAt: DateTime.now(),
      lastActivityAt: DateTime.now(),
      notes: _noteController.text.isNotEmpty
          ? [
              CustomerNote(
                id: 'N-NEW',
                content: _noteController.text.trim(),
                authorName: 'Onboarding Agent',
                createdAt: DateTime.now(),
              ),
            ]
          : [],
    );

    final created = await ref.read(customerListProvider.notifier).createCustomer(newCust);

    if (mounted) {
      setState(() {
        _isSubmitting = false;
        _createdCustomer = created;
        _currentStep = 5; // Step 6: Confirmation
      });
    }
  }

  Future<bool> _onWillPop() async {
    if (_currentStep == 5) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Unsaved Customer Data?'),
        content: const Text('Leaving now will reset all entered customer onboarding information.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Continue Editing')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discard & Leave'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: _currentStep == 5,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          context.go(AppRoutes.customers);
        }
      },
      child: Scaffold(
        body: ListView(
          padding: EdgeInsets.all(context.pageGutter),
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () async {
                    final should = await _onWillPop();
                    if (should && context.mounted) {
                      context.go(AppRoutes.customers);
                    }
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  'Onboard New Customer',
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
                        _buildStepIndicator(0, '1. Basic Info'),
                        _buildStepDivider(),
                        _buildStepIndicator(1, '2. Contact Details'),
                        _buildStepDivider(),
                        _buildStepIndicator(2, '3. Address'),
                        _buildStepDivider(),
                        _buildStepIndicator(3, '4. Additional & Tags'),
                        _buildStepDivider(),
                        _buildStepIndicator(4, '5. Review & Submit'),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // Stepper Form Card
            KcCard(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildCurrentStepContent(),
                ),
              ),
            ),
          ],
        ),
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
          backgroundColor: isDone
              ? const Color(0xFF059669)
              : (isActive ? scheme.primary : scheme.outline.withValues(alpha: 0.3)),
          child: isDone
              ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
              : Text(
                  '${stepIndex + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isActive ? scheme.onPrimary : scheme.onSurfaceVariant,
                  ),
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
      width: 24,
      height: 1.5,
      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1BasicInfo();
      case 1:
        return _buildStep2ContactInfo();
      case 2:
        return _buildStep3AddressInfo();
      case 3:
        return _buildStep4AdditionalInfo();
      case 4:
        return _buildStep5Review();
      case 5:
        return _buildStep6Confirmation();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep1BasicInfo() {
    return Column(
      key: const ValueKey(0),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('STEP 1: BASIC CUSTOMER INFORMATION', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 0.5)),
        const SizedBox(height: 16),
        if (context.isMobile) ...[
          KcTextField(controller: _firstNameController, label: 'First Name *', hintText: 'e.g. Rahul', prefixIcon: const Icon(Icons.person_rounded)),
          const SizedBox(height: 14),
          KcTextField(controller: _middleNameController, label: 'Middle Name', hintText: 'e.g. Kumar'),
          const SizedBox(height: 14),
          KcTextField(controller: _lastNameController, label: 'Last Name *', hintText: 'e.g. Sharma'),
        ] else ...[
          Row(
            children: [
              Expanded(
                child: KcTextField(
                  controller: _firstNameController,
                  label: 'First Name *',
                  hintText: 'e.g. Rahul',
                  prefixIcon: const Icon(Icons.person_rounded),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: KcTextField(
                  controller: _middleNameController,
                  label: 'Middle Name',
                  hintText: 'e.g. Kumar',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: KcTextField(
                  controller: _lastNameController,
                  label: 'Last Name *',
                  hintText: 'e.g. Sharma',
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        if (context.isMobile) ...[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Customer Type', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: CustomerType.values.map((type) {
                  return ChoiceChip(
                    avatar: Icon(type.icon, size: 16),
                    label: Text(type.label),
                    selected: _customerType == type,
                    onSelected: (val) => setState(() => _customerType = type),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Gender', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _gender,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                onChanged: (val) => setState(() => _gender = val ?? 'Male'),
                items: const [
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
              ),
            ],
          ),
        ] else ...[
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Customer Type', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 8),
                    Row(
                      children: CustomerType.values.map((type) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: ChoiceChip(
                            avatar: Icon(type.icon, size: 16),
                            label: Text(type.label),
                            selected: _customerType == type,
                            onSelected: (val) => setState(() => _customerType = type),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Gender', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _gender,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      onChanged: (val) => setState(() => _gender = val ?? 'Male'),
                      items: const [
                        DropdownMenuItem(value: 'Male', child: Text('Male')),
                        DropdownMenuItem(value: 'Female', child: Text('Female')),
                        DropdownMenuItem(value: 'Other', child: Text('Other')),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 24),
        _buildNavigationButtons(),
      ],
    );
  }

  Widget _buildStep2ContactInfo() {
    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('STEP 2: CONTACT DETAILS', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 0.5)),
        const SizedBox(height: 16),
        KcTextField(
          controller: _mobileController,
          label: 'Primary Mobile Number *',
          hintText: '+91 98200 12345',
          prefixIcon: const Icon(Icons.phone_rounded),
        ),
        const SizedBox(height: 16),
        KcTextField(
          controller: _altMobileController,
          label: 'Alternate Mobile Number',
          hintText: '+91 98200 99999',
          prefixIcon: const Icon(Icons.phone_android_rounded),
        ),
        const SizedBox(height: 16),
        KcTextField(
          controller: _emailController,
          label: 'Email Address *',
          hintText: 'rahul.sharma@example.com',
          prefixIcon: const Icon(Icons.email_rounded),
        ),
        const SizedBox(height: 24),
        _buildNavigationButtons(),
      ],
    );
  }

  Widget _buildStep3AddressInfo() {
    return Column(
      key: const ValueKey(2),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('STEP 3: RESIDENTIAL & PERMANENT ADDRESS', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 0.5)),
        const SizedBox(height: 16),
        KcTextField(
          controller: _addressController,
          label: 'Address Line *',
          hintText: 'Flat 402, Royal Palms, M.G. Road',
          prefixIcon: const Icon(Icons.location_on_rounded),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: KcTextField(
                controller: _cityController,
                label: 'City *',
                hintText: 'Mumbai',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: KcTextField(
                controller: _stateController,
                label: 'State *',
                hintText: 'Maharashtra',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: KcTextField(
                controller: _pincodeController,
                label: 'Pincode *',
                hintText: '400001',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: KcTextField(
                controller: _countryController,
                label: 'Country',
                enabled: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildNavigationButtons(),
      ],
    );
  }

  Widget _buildStep4AdditionalInfo() {
    return Column(
      key: const ValueKey(3),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('STEP 4: OCCUPATION, INCOME & INITIAL NOTES', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 0.5)),
        const SizedBox(height: 16),
        KcTextField(
          controller: _occupationController,
          label: 'Occupation / Business',
          hintText: 'e.g. Jewellery Retailer, Software Consultant',
        ),
        const SizedBox(height: 16),
        KcTextField(
          controller: _incomeController,
          label: 'Annual Income Bracket',
          hintText: 'e.g. ₹ 1,500,000 / Year',
        ),
        const SizedBox(height: 16),
        KcTextField(
          controller: _noteController,
          label: 'Internal Staff Onboarding Note',
          hintText: 'Special storage requests, verification physical notes...',
          maxLines: 3,
        ),
        const SizedBox(height: 24),
        _buildNavigationButtons(),
      ],
    );
  }

  Widget _buildStep5Review() {
    return Column(
      key: const ValueKey(4),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('STEP 5: REVIEW CUSTOMER ONBOARDING SUMMARY', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 0.5)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              _buildReviewRow('Full Name', '${_firstNameController.text} ${_middleNameController.text} ${_lastNameController.text}'),
              _buildReviewRow('Customer Type', _customerType.label),
              _buildReviewRow('Gender', _gender),
              _buildReviewRow('Mobile', _mobileController.text),
              _buildReviewRow('Email', _emailController.text),
              _buildReviewRow('Address', '${_addressController.text}, ${_cityController.text}, ${_stateController.text} - ${_pincodeController.text}'),
              _buildReviewRow('Occupation', _occupationController.text.isEmpty ? 'N/A' : _occupationController.text),
              _buildReviewRow('Income', _incomeController.text.isEmpty ? 'N/A' : _incomeController.text),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            KcOutlinedButton(
              label: 'Back',
              onPressed: _prevStep,
            ),
            const Spacer(),
            KcPrimaryButton(
              label: 'Confirm & Submit Customer',
              icon: Icons.check_circle_rounded,
              isLoading: _isSubmitting,
              onPressed: _submitCustomer,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep6Confirmation() {
    return Column(
      key: const ValueKey(5),
      children: [
        const SizedBox(height: 24),
        const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 64),
        const SizedBox(height: 16),
        Text('Customer Successfully Onboarded!', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text('System Generated Customer ID:', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _createdCustomer?.id ?? 'KC-CUS-000121',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onPrimaryContainer),
          ),
        ),
        const SizedBox(height: 32),
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
              onPressed: () {
                if (_createdCustomer != null) {
                  context.go('/customers/${_createdCustomer!.id}');
                } else {
                  context.go(AppRoutes.customers);
                }
              },
            ),
            const SizedBox(width: 12),
            KcPrimaryButton(
              label: 'Proceed to KYC Verification',
              icon: Icons.verified_user_rounded,
              onPressed: () {
                if (_createdCustomer != null) {
                  context.go('/kyc/${_createdCustomer!.id}/start');
                } else {
                  context.go(AppRoutes.kyc);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildReviewRow(String title, String val) {
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
        if (_currentStep > 0)
          KcOutlinedButton(
            label: 'Back',
            onPressed: _prevStep,
          ),
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
