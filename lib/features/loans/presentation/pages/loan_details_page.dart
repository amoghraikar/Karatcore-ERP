import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/buttons/kc_outlined_button.dart';
import '../../../../shared/widgets/buttons/kc_primary_button.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/feedback/kc_empty_state.dart';
import '../../../../shared/widgets/feedback/kc_error_state.dart';
import '../../../../shared/widgets/feedback/kc_skeleton_loader.dart';
import '../../../../shared/widgets/feedback/kc_status_badge.dart';

import '../../../ornaments/models/ornament_model.dart';
import '../../models/loan_model.dart';
import '../../providers/loan_providers.dart';
import '../../widgets/loan_status_chip.dart';
import '../../widgets/receipt_preview_dialog.dart';

class LoanDetailsPage extends ConsumerStatefulWidget {
  const LoanDetailsPage({super.key, this.id});

  final String? id;

  @override
  ConsumerState<LoanDetailsPage> createState() => _LoanDetailsPageState();
}

class _LoanDetailsPageState extends ConsumerState<LoanDetailsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 9, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getTargetId() {
    if (widget.id != null && widget.id!.isNotEmpty) return widget.id!;
    final path = GoRouterState.of(context).uri.path;
    final parts = path.split('/');
    if (parts.length > 2 && parts[2].isNotEmpty) {
      return parts[2];
    }
    return 'KC-LN-9481';
  }

  @override
  Widget build(BuildContext context) {
    final id = _getTargetId();
    final loanAsync = ref.watch(loanDetailProvider(id));
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: loanAsync.when(
        loading: () => ListView(
          padding: EdgeInsets.all(context.pageGutter),
          children: const [KcSkeletonLoader(height: 120), SizedBox(height: 20), KcSkeletonLoader(height: 500)],
        ),
        error: (err, st) => KcErrorState(
          message: 'Unable to load loan details: ${err.toString()}',
          onRetry: () => ref.invalidate(loanDetailProvider(id)),
        ),
        data: (loan) {
          if (loan == null) {
            return KcEmptyState(
              title: 'Loan Account Not Found',
              subtitle: 'No gold/silver loan record found for ID "$id".',
              action: KcPrimaryButton(
                label: 'Return to Loans List',
                onPressed: () => context.go(AppRoutes.loans),
              ),
            );
          }

          return ListView(
            padding: EdgeInsets.all(context.pageGutter),
            children: [
              // Header Card
              KcCard(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.account_balance_rounded, size: 32, color: scheme.primary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(loan.id, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                              const SizedBox(width: 12),
                              LoanStatusChip(status: loan.status),
                              const SizedBox(width: 8),
                              LoanRiskChip(risk: loan.riskStatus),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Customer: ${loan.customerName} (${loan.customerId}) • Pledge ID: ${loan.pledgeId} • Branch: ${loan.branch}',
                            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      children: [
                        KcOutlinedButton(
                          label: 'Accounting Entries',
                          icon: Icons.receipt_long_rounded,
                          onPressed: () => context.go(AppRoutes.accountingTransactions),
                        ),
                        if (loan.status == LoanStatus.active || loan.status == LoanStatus.dueSoon || loan.status == LoanStatus.overdue || loan.status == LoanStatus.partiallyRepaid) ...[
                          KcOutlinedButton(
                            label: 'Record Payment',
                            icon: Icons.payments_rounded,
                            onPressed: () => context.go('/loans/${loan.id}/payments'),
                          ),
                          KcOutlinedButton(
                            label: 'Full Settlement',
                            icon: Icons.lock_clock_rounded,
                            onPressed: () => context.go('/loans/${loan.id}/settlement'),
                          ),
                        ],
                        if (loan.status == LoanStatus.closed && loan.collateralOrnaments.any((o) => o.status != OrnamentStatus.available))
                          KcPrimaryButton(
                            label: 'Release Collateral',
                            icon: Icons.key_rounded,
                            onPressed: () => context.go('/loans/${loan.id}/release'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 9 Responsive Tabs Header
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Customer'),
                  Tab(text: 'Collateral'),
                  Tab(text: 'Financials'),
                  Tab(text: 'Payment Schedule'),
                  Tab(text: 'Payments'),
                  Tab(text: 'Documents'),
                  Tab(text: 'Activity Timeline'),
                  Tab(text: 'Audit Trail'),
                ],
              ),
              const SizedBox(height: 16),

              // Tab Content Area
              SizedBox(
                height: 540,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(loan),
                    _buildCustomerTab(loan),
                    _buildCollateralTab(loan),
                    _buildFinancialsTab(loan),
                    _buildScheduleTab(loan),
                    _buildPaymentsTab(loan),
                    _buildDocumentsTab(loan),
                    _buildActivityTab(loan),
                    _buildAuditTab(loan),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverviewTab(LoanModel l) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      children: [
        Row(
          children: [
            Expanded(
              child: KcCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Loan Account Overview', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    _buildRow('Loan Account ID', l.id),
                    _buildRow('Pledge Reference ID', l.pledgeId),
                    _buildRow('Sanctioned Principal', KcFormatters.inr(l.principalAmount)),
                    _buildRow('Outstanding Principal', KcFormatters.inr(l.outstandingPrincipal)),
                    _buildRow('Accrued Interest Due', KcFormatters.inr(l.accruedInterest)),
                    _buildRow('Annual Interest Rate', '${l.interestRatePercentage}% p.a.'),
                    _buildRow('Next Due Date', KcFormatters.date(l.nextDueDate)),
                    _buildRow('Loan Maturity Date', KcFormatters.date(l.maturityDate)),
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
                    Text('Collateral & Branch Summary', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    _buildRow('Pledged Items Count', '${l.collateralOrnaments.length} Items'),
                    _buildRow('Total Collateral Valuation', KcFormatters.inr(l.collateralTotalValue)),
                    _buildRow('Total Net Metal Weight', '${l.collateralNetWeightGrams.toStringAsFixed(2)} g'),
                    _buildRow('LTV Ratio', '${l.ltvPercentage.toStringAsFixed(1)}% LTV'),
                    _buildRow('Store Branch', l.branch),
                    _buildRow('Assigned Officer', l.loanOfficer),
                    _buildRow('Pledge Date', KcFormatters.date(l.pledgeDate)),
                    _buildRow('Last Account Audit', KcFormatters.relativeTime(l.updatedAt)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomerTab(LoanModel l) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      children: [
        KcCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Customer Relationship & KYC Integration', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              _buildRow('Customer Name', l.customerName),
              _buildRow('Customer ID', l.customerId),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('KYC Verification Status:', style: TextStyle(fontSize: 13, color: Colors.grey)),
                  KcStatusBadge(
                    label: l.customerKycStatus,
                    statusColor: l.customerKycStatus == 'Verified' ? const Color(0xFF059669) : const Color(0xFFD97706),
                    icon: l.customerKycStatus == 'Verified' ? Icons.verified_rounded : Icons.warning_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildRow('Risk Classification', l.customerRisk),
              const SizedBox(height: 16),
              KcOutlinedButton(
                label: 'View Full Customer Profile',
                icon: Icons.person_rounded,
                onPressed: () => context.go('/customers/${l.customerId}'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCollateralTab(LoanModel l) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      children: [
        KcCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pledged Ornaments (${l.collateralOrnaments.length})', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              ...l.collateralOrnaments.map((orn) => ListTile(
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(image: NetworkImage(orn.imageUrl), fit: BoxFit.cover),
                      ),
                    ),
                    title: Text(orn.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text('${orn.id} • ${orn.metalType.label} ${orn.purity.label} • Gross: ${orn.weight.grossWeight}g | Net: ${orn.weight.netMetalWeight}g'),
                    trailing: OutlinedButton(
                      onPressed: () => context.go('/inventory/${orn.id}'),
                      child: const Text('View Inventory Record'),
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialsTab(LoanModel l) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      children: [
        KcCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Financial Ledger Breakdown', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              _buildRow('Sanctioned Principal Amount', KcFormatters.inr(l.principalAmount)),
              _buildRow('Outstanding Principal Balance', KcFormatters.inr(l.outstandingPrincipal)),
              _buildRow('Accrued Interest Due', KcFormatters.inr(l.accruedInterest)),
              _buildRow('Interest Collected to Date', KcFormatters.inr(l.interestPaid)),
              _buildRow('Principal Repaid to Date', KcFormatters.inr(l.principalPaid)),
              _buildRow('Processing Fee (Configured)', KcFormatters.inr(l.processingFee)),
              const Divider(height: 24),
              _buildRow('Total Current Outstanding (Principal + Interest)', KcFormatters.inr(l.totalOutstanding)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleTab(LoanModel l) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      children: [
        KcCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Repayment Installment Schedule (${l.schedule.length} Months)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              if (l.schedule.isEmpty)
                const Text('No repayment schedule configured.')
              else
                ...l.schedule.map((item) => ListTile(
                      leading: CircleAvatar(radius: 14, child: Text('#${item.installmentNumber}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                      title: Text('Due: ${KcFormatters.date(item.dueDate)}', style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text('Interest Due: ${KcFormatters.inr(item.interestComponent)}'),
                      trailing: KcStatusBadge(
                        label: item.status,
                        statusColor: item.status == 'Paid' ? const Color(0xFF059669) : const Color(0xFF2563EB),
                      ),
                    )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentsTab(LoanModel l) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      children: [
        KcCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Recorded Payments Log (${l.payments.length})', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              if (l.payments.isEmpty)
                const Text('No payments recorded yet for this account.')
              else
                ...l.payments.map((p) => ListTile(
                      leading: CircleAvatar(backgroundColor: Theme.of(context).colorScheme.primaryContainer, child: Icon(p.method.icon, size: 18)),
                      title: Text('${KcFormatters.inr(p.amount)} (${p.method.label})', style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text('Receipt #${p.receiptNumber} • Recorded by ${p.recordedBy}\nInterest: ${KcFormatters.inr(p.interestComponent)} | Principal: ${KcFormatters.inr(p.principalComponent)}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.receipt_long_rounded),
                        tooltip: 'View Receipt',
                        onPressed: () {
                          showReceiptPreviewDialog(
                            context: context,
                            receiptTitle: 'Payment Receipt',
                            receiptNumber: p.receiptNumber,
                            loan: l,
                            customerName: l.customerName,
                            amount: p.amount,
                            paymentMethod: p.method.label,
                            date: p.paymentDate,
                            staffName: p.recordedBy,
                          );
                        },
                      ),
                    )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentsTab(LoanModel l) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      children: [
        KcCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Loan Documents & Sanction Certificates', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              ...l.documents.map((doc) => ListTile(
                    leading: const Icon(Icons.description_rounded, color: Colors.blue),
                    title: Text(doc.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text('${doc.type} • Uploaded ${KcFormatters.date(doc.uploadDate)} by ${doc.uploadedBy}'),
                    trailing: const Icon(Icons.download_rounded),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityTab(LoanModel l) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      children: [
        KcCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Activity Timeline Log', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              ...l.activities.map((act) => ListTile(
                    leading: CircleAvatar(radius: 16, backgroundColor: Theme.of(context).colorScheme.primaryContainer, child: const Icon(Icons.history_rounded, size: 16)),
                    title: Text(act.action, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text('${act.description}\nActor: ${act.actorName} (${act.role})'),
                    trailing: Text(KcFormatters.dateTime(act.timestamp), style: const TextStyle(fontSize: 11)),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAuditTab(LoanModel l) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      children: [
        KcCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Immutable System Audit Trail', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              ...l.auditLogs.map((aud) => ListTile(
                    leading: const Icon(Icons.shield_rounded, color: Color(0xFF059669)),
                    title: Text(aud.action, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text('${aud.description}\nPrevious State: ${aud.previousState} → New State: ${aud.newState}'),
                    trailing: Text(KcFormatters.dateTime(aud.timestamp), style: const TextStyle(fontSize: 11)),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRow(String title, String val) {
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
}
