import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/routes.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../models/rbac_models.dart';
import '../../providers/staff_providers.dart';

class CreateStaffPage extends ConsumerStatefulWidget {
  const CreateStaffPage({super.key, this.editStaffId});

  final String? editStaffId;

  @override
  ConsumerState<CreateStaffPage> createState() => _CreateStaffPageState();
}

class _CreateStaffPageState extends ConsumerState<CreateStaffPage> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _empIdController = TextEditingController(text: 'EMP-${1010 + DateTime.now().millisecond % 100}');
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  String _selectedRole = 'LOAN_OFFICER';
  String _selectedDepartment = 'Gold Loan Operations';
  String _selectedBranchId = 'BR-001';
  String _selectedBranchName = 'Zaveri Bazaar Main Branch';

  @override
  void initState() {
    super.initState();
    if (widget.editStaffId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final staff = await ref.read(staffRepositoryProvider).getStaffById(widget.editStaffId!);
        if (staff != null && mounted) {
          setState(() {
            _nameController.text = staff.fullName;
            _empIdController.text = staff.employeeId;
            _emailController.text = staff.email;
            _phoneController.text = staff.mobile;
            _selectedRole = staff.roleCode;
            _selectedDepartment = staff.department;
            _selectedBranchId = staff.branchId;
            _selectedBranchName = staff.branchName;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.editStaffId != null;
    final authService = ref.watch(authorizationServiceProvider);
    final defaultPermissions = authService.getRolePermissions(_selectedRole);

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(context.pageGutter),
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => context.go(AppRoutes.staff),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isEdit ? 'Edit Staff Profile' : 'Onboard New Staff Member', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text('Multi-step staff creation wizard, role assignment & permission scope review', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Stepper Header
          Row(
            children: [
              _buildStepPill(0, '1. Basic Information'),
              const SizedBox(width: 8),
              _buildStepPill(1, '2. Role Assignment'),
              const SizedBox(width: 8),
              _buildStepPill(2, '3. Permission Review'),
              const SizedBox(width: 8),
              _buildStepPill(3, '4. Confirmation'),
            ],
          ),
          const SizedBox(height: 20),

          // Step Content
          KcCard(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_currentStep == 0) _buildStep1BasicInfo(),
                  if (_currentStep == 1) _buildStep2RoleAssignment(),
                  if (_currentStep == 2) _buildStep3PermissionReview(defaultPermissions),
                  if (_currentStep == 3) _buildStep4Confirmation(defaultPermissions),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Wizard Navigation Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentStep > 0)
                        OutlinedButton.icon(
                          onPressed: () => setState(() => _currentStep--),
                          icon: const Icon(Icons.arrow_back_rounded),
                          label: const Text('Previous Step'),
                        )
                      else
                        const SizedBox.shrink(),
                      if (_currentStep < 3)
                        ElevatedButton.icon(
                          onPressed: () {
                            if (_currentStep == 0 && !_formKey.currentState!.validate()) return;
                            setState(() => _currentStep++);
                          },
                          icon: const Icon(Icons.arrow_forward_rounded),
                          label: const Text('Next Step'),
                        )
                      else
                        ElevatedButton.icon(
                          onPressed: _saveStaffRecord,
                          icon: const Icon(Icons.check_circle_rounded),
                          label: Text(isEdit ? 'Save Changes' : 'Confirm & Create Staff Record'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF059669),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepPill(int index, String label) {
    final isActive = _currentStep == index;
    final isDone = _currentStep > index;
    final scheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isActive ? scheme.primary : (isDone ? scheme.primary.withValues(alpha: 0.15) : scheme.surfaceContainerHighest),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive || isDone ? FontWeight.w800 : FontWeight.w500,
              color: isActive ? scheme.onPrimary : (isDone ? scheme.primary : scheme.onSurfaceVariant),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildStep1BasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 1 — Employee Basic Details', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Full Name *', hintText: 'e.g. Arjun Rathore'),
          validator: (val) => val == null || val.trim().isEmpty ? 'Please enter employee full name' : null,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _empIdController,
                decoration: const InputDecoration(labelText: 'Employee ID *', hintText: 'e.g. EMP-1012'),
                validator: (val) => val == null || val.trim().isEmpty ? 'Enter Employee ID' : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Work Email *', hintText: 'e.g. arjun@karatcore.com'),
                validator: (val) => val == null || !val.contains('@') ? 'Enter a valid work email' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Mobile Number', hintText: '+91 98765 43210'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _selectedDepartment,
                decoration: const InputDecoration(labelText: 'Department *'),
                items: const [
                  DropdownMenuItem(value: 'Executive Management', child: Text('Executive Management')),
                  DropdownMenuItem(value: 'Accounts & Finance', child: Text('Accounts & Finance')),
                  DropdownMenuItem(value: 'Gold Loan Operations', child: Text('Gold Loan Operations')),
                  DropdownMenuItem(value: 'KYC & Compliance', child: Text('KYC & Compliance')),
                  DropdownMenuItem(value: 'Jewellery & Vault Inventory', child: Text('Jewellery & Vault Inventory')),
                  DropdownMenuItem(value: 'Cash Counter & POS', child: Text('Cash Counter & POS')),
                ],
                onChanged: (val) => setState(() => _selectedDepartment = val ?? _selectedDepartment),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _selectedBranchId,
          decoration: const InputDecoration(labelText: 'Assigned Branch Location *'),
          items: const [
            DropdownMenuItem(value: 'BR-001', child: Text('Zaveri Bazaar Main Branch (Mumbai HQ)')),
            DropdownMenuItem(value: 'BR-002', child: Text('Karol Bagh Vault Branch (New Delhi)')),
            DropdownMenuItem(value: 'BR-003', child: Text('Commercial Street Branch (Bengaluru)')),
          ],
          onChanged: (val) {
            setState(() {
              _selectedBranchId = val ?? 'BR-001';
              if (_selectedBranchId == 'BR-001') _selectedBranchName = 'Zaveri Bazaar Main Branch';
              if (_selectedBranchId == 'BR-002') _selectedBranchName = 'Karol Bagh Vault Branch';
              if (_selectedBranchId == 'BR-003') _selectedBranchName = 'Commercial Street Branch';
            });
          },
        ),
      ],
    );
  }

  Widget _buildStep2RoleAssignment() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 2 — Assign System Role & Persona', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        const Text('Select an operational role. Permissions associated with the selected role will be automatically granted.', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 20),
        ref.watch(rolesListProvider).when(
              loading: () => const CircularProgressIndicator(),
              error: (e, s) => Text('Error loading roles: $e'),
              data: (roles) {
                return Column(
                  children: roles.map((role) {
                    final isSelected = _selectedRole == role.code;
                    return Card(
                      elevation: isSelected ? 2 : 0,
                      margin: const EdgeInsets.only(bottom: 10),
                      color: isSelected ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3) : Theme.of(context).colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outlineVariant,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: RadioListTile<String>(
                        title: Row(
                          children: [
                            Icon(role.icon, size: 20, color: role.color),
                            const SizedBox(width: 8),
                            Text(role.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: role.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                              child: Text(role.code, style: TextStyle(color: role.color, fontSize: 11, fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                        subtitle: Text(role.description),
                        value: role.code,
                        // ignore: deprecated_member_use
                        groupValue: _selectedRole,
                        // ignore: deprecated_member_use
                        onChanged: (val) => setState(() => _selectedRole = val ?? _selectedRole),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
      ],
    );
  }

  Widget _buildStep3PermissionReview(List<String> defaultPermissions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 3 — Review Role Permissions Scope', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        Text('Review all functional privileges automatically inherited by role $_selectedRole:', style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Granted Scope: ${defaultPermissions.length} Privileges', style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: defaultPermissions.map((p) {
                  return Chip(
                    avatar: const Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF059669)),
                    label: Text(p, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                    backgroundColor: Colors.white,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep4Confirmation(List<String> defaultPermissions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 4 — Final Profile Review & Confirmation', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        ListTile(
          tileColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          leading: CircleAvatar(child: Text(_nameController.text.isNotEmpty ? _nameController.text[0].toUpperCase() : 'S')),
          title: Text(_nameController.text.isEmpty ? 'Staff Member' : _nameController.text, style: const TextStyle(fontWeight: FontWeight.w800)),
          subtitle: Text('${_empIdController.text} • ${_emailController.text} • ${_phoneController.text}'),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
            child: Text(_selectedRole, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w800)),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _infoCard('Department', _selectedDepartment)),
            const SizedBox(width: 12),
            Expanded(child: _infoCard('Assigned Branch', _selectedBranchName)),
            const SizedBox(width: 12),
            Expanded(child: _infoCard('Effective Scope', '${defaultPermissions.length} Permissions')),
          ],
        ),
      ],
    );
  }

  Widget _infoCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ),
    );
  }

  void _saveStaffRecord() async {
    final newStaff = StaffModel(
      id: widget.editStaffId ?? 'STF-${DateTime.now().millisecondsSinceEpoch % 10000}',
      employeeId: _empIdController.text,
      fullName: _nameController.text,
      email: _emailController.text,
      mobile: _phoneController.text,
      avatarUrl: '',
      roleCode: _selectedRole,
      department: _selectedDepartment,
      branchId: _selectedBranchId,
      branchName: _selectedBranchName,
      status: StaffStatus.active,
      joiningDate: DateTime.now(),
      lastActive: DateTime.now(),
      createdAt: DateTime.now(),
    );

    if (widget.editStaffId != null) {
      await ref.read(staffRepositoryProvider).updateStaff(newStaff);
    } else {
      await ref.read(staffRepositoryProvider).createStaff(newStaff);
    }

    ref.invalidate(staffListProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.editStaffId != null ? 'Staff profile updated.' : 'Staff record created for ${_nameController.text}'),
          backgroundColor: const Color(0xFF059669),
        ),
      );
      context.go(AppRoutes.staff);
    }
  }
}
