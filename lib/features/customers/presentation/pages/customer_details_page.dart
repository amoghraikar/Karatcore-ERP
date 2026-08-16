import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/components/kc_avatar.dart';
import '../../../../shared/widgets/buttons/kc_outlined_button.dart';
import '../../../../shared/widgets/buttons/kc_primary_button.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/cards/kc_metric_card.dart';
import '../../../../shared/widgets/feedback/kc_empty_state.dart';
import '../../../../shared/widgets/feedback/kc_error_state.dart';
import '../../../../shared/widgets/feedback/kc_skeleton_loader.dart';
import '../../../../shared/widgets/feedback/kc_status_badge.dart';
import '../../../../shared/widgets/dialogs/kc_document_viewer_dialog.dart';

import '../../models/customer_model.dart';
import '../../providers/customer_providers.dart';
import '../../../loans/providers/loan_providers.dart';
import '../../../ornaments/providers/inventory_providers.dart';
import '../../widgets/customer_quick_actions_menu.dart';

class CustomerDetailsPage extends ConsumerStatefulWidget {
  const CustomerDetailsPage({super.key, this.id});

  final String? id;

  @override
  ConsumerState<CustomerDetailsPage> createState() => _CustomerDetailsPageState();
}

class _CustomerDetailsPageState extends ConsumerState<CustomerDetailsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _noteInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _noteInputController.dispose();
    super.dispose();
  }

  String _getCustomerIdFromRoute() {
    if (widget.id != null && widget.id!.isNotEmpty) return widget.id!;
    final path = GoRouterState.of(context).uri.path;
    final parts = path.split('/');
    if (parts.length > 2 && parts[2].isNotEmpty) {
      return parts[2];
    }
    return 'KC-CUS-000101'; // Default fallback
  }

  @override
  Widget build(BuildContext context) {
    final customerId = _getCustomerIdFromRoute();
    final customerAsync = ref.watch(customerDetailProvider(customerId));
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: customerAsync.when(
        loading: () => ListView(
          padding: EdgeInsets.all(context.pageGutter),
          children: const [
            KcSkeletonLoader(height: 140),
            SizedBox(height: 20),
            KcSkeletonLoader(height: 400),
          ],
        ),
        error: (err, st) => KcErrorState(
          message: 'Unable to load customer profile details: ${err.toString()}',
          onRetry: () => ref.invalidate(customerDetailProvider(customerId)),
        ),
        data: (customer) {
          if (customer == null) {
            return KcEmptyState(
              title: 'Customer Not Found',
              subtitle: 'No customer account registered with ID "$customerId".',
              action: KcPrimaryButton(
                label: 'Return to Customer Directory',
                onPressed: () => context.go(AppRoutes.customers),
              ),
            );
          }

          return ListView(
            padding: EdgeInsets.all(context.pageGutter),
            children: [
              // Navigation Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => context.go(AppRoutes.customers),
                  ),
                  const SizedBox(width: 8),
                  Text('Customer Profile', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 16),

              // Hero Profile Header Card
              KcCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        KcAvatar(
                          initials: customer.initials,
                          imageUrl: customer.avatarUrl,
                          size: 64,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      customer.fullName,
                                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  KcStatusBadge(
                                    label: customer.customerStatus.label,
                                    statusColor: customer.customerStatus.color,
                                    icon: customer.customerStatus.icon,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${customer.id} • ${customer.mobile} • ${customer.email}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  KcStatusBadge(label: 'KYC: ${customer.kycStatus.label}', statusColor: customer.kycStatus.color, icon: customer.kycStatus.icon),
                                  KcStatusBadge(label: customer.riskStatus.label, statusColor: customer.riskStatus.color, icon: customer.riskStatus.icon),
                                  ...customer.tags.map((t) => Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(color: scheme.primaryContainer.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(4)),
                                        child: Text('#$t', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                                      )),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (context.isDesktop)
                          Wrap(
                            spacing: 8,
                            children: [
                              KcOutlinedButton(
                                label: 'New Loan',
                                icon: Icons.add_card_rounded,
                                onPressed: () => context.go(AppRoutes.loans),
                              ),
                              KcOutlinedButton(
                                label: 'Add Ornament',
                                icon: Icons.diamond_outlined,
                                onPressed: () => context.go(AppRoutes.ornaments),
                              ),
                              CustomerQuickActionsMenu(customer: customer, iconOnly: false),
                            ],
                          )
                        else
                          CustomerQuickActionsMenu(customer: customer),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Tab Bar Header
              Card(
                elevation: 0,
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: const [
                    Tab(text: 'Overview', icon: Icon(Icons.dashboard_rounded, size: 18)),
                    Tab(text: 'KYC', icon: Icon(Icons.verified_user_rounded, size: 18)),
                    Tab(text: 'Loans', icon: Icon(Icons.account_balance_rounded, size: 18)),
                    Tab(text: 'Ornaments', icon: Icon(Icons.diamond_rounded, size: 18)),
                    Tab(text: 'Payments', icon: Icon(Icons.receipt_rounded, size: 18)),
                    Tab(text: 'Documents', icon: Icon(Icons.folder_rounded, size: 18)),
                    Tab(text: 'Activity', icon: Icon(Icons.history_rounded, size: 18)),
                    Tab(text: 'Notes', icon: Icon(Icons.sticky_note_2_rounded, size: 18)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Tab Content Views Container
              SizedBox(
                height: 600,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(customer),
                    _buildKycTab(customer),
                    _buildLoansTab(customer),
                    _buildOrnamentsTab(customer),
                    _buildPaymentsTab(customer),
                    _buildDocumentsTab(customer),
                    _buildActivityTab(customer),
                    _buildNotesTab(customer),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // 1. Overview Tab
  Widget _buildOverviewTab(CustomerModel customer) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      children: [
        Row(
          children: [
            Expanded(
              child: KcMetricCard(
                title: 'Active Loans',
                value: '${customer.activeLoansCount} Active Pledges',
                trend: '${customer.closedLoansCount} Closed Loans',
                icon: Icons.account_balance_rounded,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: KcMetricCard(
                title: 'Outstanding Principal',
                value: KcFormatters.currency(customer.totalOutstandingAmount),
                trend: 'Current Balance',
                icon: Icons.account_balance_wallet_rounded,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: KcMetricCard(
                title: 'Total Interest Paid',
                value: KcFormatters.currency(customer.totalInterestPaid),
                trend: 'Lifetime Revenue',
                icon: Icons.payments_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: KcCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Contact & Identity Summary', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 14),
                    _buildInfoRow('Full Name', customer.fullName),
                    _buildInfoRow('Mobile Number', customer.mobile),
                    _buildInfoRow('Alternate Mobile', customer.alternateMobile.isEmpty ? 'N/A' : customer.alternateMobile),
                    _buildInfoRow('Email Address', customer.email),
                    _buildInfoRow('Occupation', customer.occupation),
                    _buildInfoRow('Annual Income', customer.annualIncome),
                    _buildInfoRow('PAN Card (Placeholder)', customer.panNumberPlaceholder.isEmpty ? 'ABCPS1234F' : customer.panNumberPlaceholder),
                    _buildInfoRow('Aadhaar (Placeholder)', customer.aadhaarNumberPlaceholder.isEmpty ? 'XXXX-XXXX-8821' : customer.aadhaarNumberPlaceholder),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: KcCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Address & Account Metrics', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 14),
                    _buildInfoRow('Address Line', customer.addressLine),
                    _buildInfoRow('City / State', '${customer.city}, ${customer.state}'),
                    _buildInfoRow('Pincode / Country', '${customer.pincode}, ${customer.country}'),
                    _buildInfoRow('Customer Since', KcFormatters.date(customer.createdAt)),
                    _buildInfoRow('Last Store Activity', KcFormatters.relativeTime(customer.lastActivityAt)),
                    _buildInfoRow('Customer Type', customer.customerType.label),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }



  // 2. KYC Tab
  Widget _buildKycTab(CustomerModel customer) {
    final docs = customer.documents;

    return ListView(
      physics: const ClampingScrollPhysics(),
      children: [
        KcCard(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: customer.kycStatus.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(customer.kycStatus.icon, color: customer.kycStatus.color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('KYC Status: ', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                        KcStatusBadge(
                          label: customer.kycStatus.label,
                          statusColor: customer.kycStatus.color,
                          icon: customer.kycStatus.icon,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      customer.kycStatus == CustomerKycStatus.verified
                          ? 'Level 2 Standard Aadhaar / PAN Verification Approved.'
                          : 'KYC Verification Pending. Please initiate identity verification.',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Wrap(
                spacing: 8,
                children: [
                  KcPrimaryButton(
                    label: 'Start KYC Wizard',
                    icon: Icons.play_arrow_rounded,
                    onPressed: () => context.go('/kyc/${customer.id}/start'),
                  ),
                  KcOutlinedButton(
                    label: 'Review KYC',
                    icon: Icons.rate_review_rounded,
                    onPressed: () => context.go('/kyc/${customer.id}/review'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        KcCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Submitted Verification Vault Documents', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              if (docs.isEmpty)
                KcEmptyState(
                  title: 'No Verification Vault Documents Uploaded',
                  subtitle: 'KYC has not been initiated for customer "${customer.fullName}". Click below to upload and verify documents.',
                  action: KcPrimaryButton(
                    label: 'Initiate Customer KYC',
                    icon: Icons.upload_file_rounded,
                    onPressed: () => context.go('/kyc/${customer.id}/start'),
                  ),
                )
              else
                ...docs.map((doc) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        onTap: () => KcDocumentViewerDialog.show(
                          context,
                          customerName: customer.fullName,
                          customerId: customer.id,
                          document: doc,
                        ),
                        leading: Icon(doc.isVerified ? Icons.verified_rounded : Icons.pending_actions_rounded, color: doc.isVerified ? const Color(0xFF059669) : Colors.orange),
                        title: Text(doc.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text('${doc.documentType} • ${doc.documentNumber} • ${KcFormatters.date(doc.uploadDate)}'),
                        trailing: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          children: [
                            KcStatusBadge(
                              label: doc.isVerified ? 'Verified' : 'Pending Review',
                              statusColor: doc.isVerified ? const Color(0xFF059669) : Colors.orange,
                              icon: doc.isVerified ? Icons.check_circle_rounded : Icons.hourglass_top_rounded,
                            ),
                            KcOutlinedButton(
                              label: 'View Scan',
                              icon: Icons.visibility_rounded,
                              onPressed: () => KcDocumentViewerDialog.show(
                                context,
                                customerName: customer.fullName,
                                customerId: customer.id,
                                document: doc,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
            ],
          ),
        ),
      ],
    );
  }

  // 3. Loans Tab
  Widget _buildLoansTab(CustomerModel customer) {
    final loansAsync = ref.watch(customerLoansProvider(customer.id));

    return loansAsync.when(
      loading: () => const KcSkeletonLoader(height: 300),
      error: (err, st) => KcErrorState(message: 'Unable to load customer loans: ${err.toString()}'),
      data: (loans) {
        if (loans.isEmpty) {
          return KcEmptyState(
            title: 'No Loans Registered',
            subtitle: 'Customer "${customer.id}" has no active or past gold loan pledges.',
            action: KcPrimaryButton(
              label: 'Create New Gold Loan',
              onPressed: () => context.go(AppRoutes.loanCreate),
            ),
          );
        }

        return ListView(
          physics: const ClampingScrollPhysics(),
          children: loans.map((loan) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: KcCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Icon(Icons.account_balance_rounded, color: Theme.of(context).colorScheme.primary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(loan.id, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                          const SizedBox(height: 2),
                          Text('Pledged: ${KcFormatters.date(loan.pledgeDate)} • Due: ${KcFormatters.date(loan.nextDueDate)}', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(KcFormatters.inr(loan.outstandingPrincipal), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFFDC2626))),
                        const SizedBox(height: 2),
                        Text('${loan.interestRatePercentage}% Interest Rate', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      ],
                    ),
                    const SizedBox(width: 16),
                    KcOutlinedButton(
                      label: 'View Loan',
                      onPressed: () => context.go('/loans/${loan.id}'),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // 4. Ornaments Tab
  Widget _buildOrnamentsTab(CustomerModel customer) {
    final ornamentsAsync = ref.watch(customerOrnamentsProvider(customer.id));

    return ornamentsAsync.when(
      loading: () => const KcSkeletonLoader(height: 300),
      error: (err, st) => KcErrorState(message: 'Unable to load customer ornaments: ${err.toString()}'),
      data: (items) {
        if (items.isEmpty) {
          return KcEmptyState(
            title: 'No Ornaments Deposited',
            subtitle: 'No pledged jewellery or bullion items associated with customer profile "${customer.id}".',
            action: KcPrimaryButton(
              label: 'Add Ornament Wizard',
              onPressed: () => context.go(AppRoutes.ornamentCreate),
            ),
          );
        }

        return ListView(
          physics: const ClampingScrollPhysics(),
          children: items.map((orn) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: KcCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(image: NetworkImage(orn.imageUrl), fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(orn.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                          const SizedBox(height: 2),
                          Text('${orn.id} • ${orn.purity.label} • Gross: ${orn.weight.grossWeight}g | Net: ${orn.weight.netMetalWeight}g', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        KcStatusBadge(label: orn.status.label, statusColor: orn.status.color, icon: orn.status.icon),
                        const SizedBox(height: 4),
                        Text(KcFormatters.inr(orn.valuation.totalEstimatedValue), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // 5. Payments Tab
  Widget _buildPaymentsTab(CustomerModel customer) {
    if (customer.payments.isEmpty) {
      return const KcEmptyState(
        title: 'No Payments Recorded',
        subtitle: 'No receipt payments have been logged for this customer.',
      );
    }

    return ListView(
      physics: const ClampingScrollPhysics(),
      children: [
        KcCard(
          padding: EdgeInsets.zero,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: customer.payments.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final p = customer.payments[index];
              return ListTile(
                leading: const CircleAvatar(backgroundColor: Color(0xFFECFDF5), child: Icon(Icons.receipt_long_rounded, color: Color(0xFF059669))),
                title: Text(p.receiptNo, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text('${p.paymentMethod} • Loan ${p.loanId} • ${KcFormatters.date(p.date)}'),
                trailing: Text(KcFormatters.currency(p.amount), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              );
            },
          ),
        ),
      ],
    );
  }

  // 6. Documents Tab
  Widget _buildDocumentsTab(CustomerModel customer) {
    final docs = customer.documents;

    return ListView(
      physics: const ClampingScrollPhysics(),
      children: [
        KcCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Document Vault', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  KcOutlinedButton(
                    label: 'Upload Document',
                    icon: Icons.upload_file_rounded,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Document Vault upload dialog opened.')));
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (docs.isEmpty)
                KcEmptyState(
                  title: 'No Documents Uploaded',
                  subtitle: 'No identity, proof of address, or vault documents uploaded for customer "${customer.fullName}".',
                  action: KcPrimaryButton(
                    label: 'Upload Document',
                    icon: Icons.upload_file_rounded,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Document Vault upload dialog opened.')));
                    },
                  ),
                )
              else
                ...docs.map((doc) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        onTap: () => KcDocumentViewerDialog.show(
                          context,
                          customerName: customer.fullName,
                          customerId: customer.id,
                          document: doc,
                        ),
                        leading: const Icon(Icons.description_rounded, color: Colors.blue),
                        title: Text(doc.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text('${doc.documentType} • ${doc.fileSize} • ${KcFormatters.date(doc.uploadDate)}'),
                        trailing: Wrap(
                          spacing: 8,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.visibility_outlined, size: 20),
                              onPressed: () => KcDocumentViewerDialog.show(
                                context,
                                customerName: customer.fullName,
                                customerId: customer.id,
                                document: doc,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.download_outlined, size: 20),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Downloading ${doc.name}...')),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    )),
            ],
          ),
        ),
      ],
    );
  }

  // 7. Activity Tab
  Widget _buildActivityTab(CustomerModel customer) {
    if (customer.activities.isEmpty) {
      return const KcEmptyState(
        title: 'No Activity History',
        subtitle: 'No actions logged for this customer yet.',
      );
    }

    return ListView(
      physics: const ClampingScrollPhysics(),
      children: [
        KcCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: customer.activities.map((act) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(radius: 16, backgroundColor: Theme.of(context).colorScheme.primaryContainer, child: Icon(act.icon, size: 16)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(act.eventType, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                          const SizedBox(height: 2),
                          Text(act.description, style: const TextStyle(fontSize: 13)),
                          const SizedBox(height: 4),
                          Text('${KcFormatters.relativeTime(act.timestamp)} by ${act.actor}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // 8. Notes Tab
  Widget _buildNotesTab(CustomerModel customer) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      children: [
        KcCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.lock_rounded, size: 16, color: Colors.orange),
                  const SizedBox(width: 6),
                  Text('INTERNAL STAFF NOTES', style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800, color: Colors.orange)),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _noteInputController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Add internal confidential note regarding this customer...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: KcPrimaryButton(
                  label: 'Save Note',
                  icon: Icons.add_comment_rounded,
                  onPressed: () async {
                    if (_noteInputController.text.trim().isNotEmpty) {
                      await ref.read(customerListProvider.notifier).addNote(customer.id, _noteInputController.text.trim(), 'Current Staff');
                      _noteInputController.clear();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (customer.notes.isEmpty)
          const KcEmptyState(title: 'No Staff Notes', subtitle: 'No internal notes added for this customer.')
        else
          ...customer.notes.map((note) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: KcCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(note.authorName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(note.isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined, size: 18, color: note.isPinned ? Colors.amber : Colors.grey),
                              onPressed: () => ref.read(customerListProvider.notifier).togglePinNote(customer.id, note.id),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                              onPressed: () => ref.read(customerListProvider.notifier).deleteNote(customer.id, note.id),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(note.content, style: const TextStyle(fontSize: 13)),
                    const SizedBox(height: 6),
                    Text(KcFormatters.relativeTime(note.createdAt), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13)),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
