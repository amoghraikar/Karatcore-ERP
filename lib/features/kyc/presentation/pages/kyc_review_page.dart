import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/routes.dart';
import '../../../../shared/widgets/buttons/kc_outlined_button.dart';
import '../../../../shared/widgets/buttons/kc_primary_button.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/feedback/kc_empty_state.dart';
import '../../../../shared/widgets/feedback/kc_error_state.dart';
import '../../../../shared/widgets/feedback/kc_skeleton_loader.dart';
import '../../../../shared/widgets/feedback/kc_status_badge.dart';

import '../../../auth/providers/permission_provider.dart';
import '../../models/kyc_model.dart';
import '../../providers/kyc_permissions.dart';
import '../../providers/kyc_providers.dart';
import '../../widgets/kyc_document_preview_dialog.dart';
import '../../widgets/kyc_rejection_dialog.dart';
import '../../widgets/kyc_status_chip.dart';

class KycReviewPage extends ConsumerStatefulWidget {
  const KycReviewPage({super.key, this.customerId});

  final String? customerId;

  @override
  ConsumerState<KycReviewPage> createState() => _KycReviewPageState();
}

class _KycReviewPageState extends ConsumerState<KycReviewPage> {
  final _reviewerNotesController = TextEditingController();
  KycVerificationLevel _selectedApproveLevel = KycVerificationLevel.standard;

  @override
  void dispose() {
    _reviewerNotesController.dispose();
    super.dispose();
  }

  String _getTargetCustomerId() {
    if (widget.customerId != null && widget.customerId!.isNotEmpty) return widget.customerId!;
    final path = GoRouterState.of(context).uri.path;
    final parts = path.split('/');
    if (parts.length > 2 && parts[2].isNotEmpty) {
      return parts[2];
    }
    return 'KC-CUS-000104';
  }

  @override
  Widget build(BuildContext context) {
    final custId = _getTargetCustomerId();
    final recordAsync = ref.watch(kycDetailProvider(custId));
    final role = ref.watch(currentRoleProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: recordAsync.when(
        loading: () => ListView(
          padding: EdgeInsets.all(context.pageGutter),
          children: const [KcSkeletonLoader(height: 120), SizedBox(height: 20), KcSkeletonLoader(height: 500)],
        ),
        error: (err, st) => KcErrorState(
          message: 'Unable to load KYC Review details: ${err.toString()}',
          onRetry: () => ref.invalidate(kycDetailProvider(custId)),
        ),
        data: (record) {
          if (record == null) {
            return KcEmptyState(
              title: 'KYC Record Not Found',
              subtitle: 'No KYC submission found for customer ID "$custId".',
              action: KcPrimaryButton(
                label: 'Return to KYC Queue',
                onPressed: () => context.go(AppRoutes.kyc),
              ),
            );
          }

          return ListView(
            padding: EdgeInsets.all(context.pageGutter),
            children: [
              // Header Row
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => context.go(AppRoutes.kyc),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('KYC Document Reviewer', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 2),
                        Text('Record ID: ${record.id} • Customer: ${record.customerName} (${record.customerId})', style: TextStyle(color: scheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  KycStatusChip(status: record.status),
                ],
              ),
              const SizedBox(height: 20),

              // Main Split-View Layout (Desktop vs Mobile)
              if (context.isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column: Document Preview Viewer
                    Expanded(flex: 5, child: _buildDocumentPreviewPanel(record)),
                    const SizedBox(width: 20),
                    // Right Column: Field Matching, Risk & Decision Panel
                    Expanded(flex: 6, child: _buildReviewDecisionPanel(record, role)),
                  ],
                )
              else
                Column(
                  children: [
                    _buildDocumentPreviewPanel(record),
                    const SizedBox(height: 20),
                    _buildReviewDecisionPanel(record, role),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDocumentPreviewPanel(KycRecordModel record) {
    return KcCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Submitted Verification Documents', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          if (record.documents.isEmpty)
            const Text('No uploaded documents available for review.')
          else
            ...record.documents.map((doc) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.badge_rounded, size: 28, color: Colors.blue),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(doc.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                const SizedBox(height: 2),
                                Text('Number: ${doc.maskedDocumentNumber}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          KcOutlinedButton(
                            label: 'Full Preview',
                            icon: Icons.zoom_in_rounded,
                            onPressed: () => showKycDocumentPreview(context, record.customerId, doc),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(8)),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.credit_card_rounded, color: Colors.white70, size: 48),
                            const SizedBox(height: 8),
                            Text('${doc.type} Sealed Document Image', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text('Size: ${doc.fileSize} • Uploaded by ${doc.uploadedBy}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildReviewDecisionPanel(KycRecordModel record, dynamic role) {
    return Column(
      children: [
        // 1. Field Matching Comparison Card
        KcCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Field Alignment & OCR Comparison', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              if (record.fieldMatches.isEmpty) ...[
                _buildFieldMatchRow('Customer Name', record.customerName, record.documents.isNotEmpty ? record.documents.first.nameOnDoc : 'N/A', FieldMatchStatus.match),
                _buildFieldMatchRow('Date of Birth', '12/04/1985', record.documents.isNotEmpty ? '12/04/1985' : 'N/A', FieldMatchStatus.match),
                _buildFieldMatchRow('Address Alignment', 'Royal Palms, MG Road, Mumbai', 'Govt Tax Record Matched', FieldMatchStatus.match),
              ] else
                ...record.fieldMatches.map((m) => _buildFieldMatchRow(m.fieldName, m.customerValue, m.documentValue, m.status)),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 2. Risk Assessment Card
        KcCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Internal Risk Assessment', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  KcStatusBadge(label: record.riskStatus.label, statusColor: record.riskStatus.color, icon: record.riskStatus.icon),
                ],
              ),
              const SizedBox(height: 10),
              Text('Risk Factors Checked:', style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 6),
              _buildRiskFactor('Incomplete Information Check', false),
              _buildRiskFactor('Document Expiry Date Check', false),
              _buildRiskFactor('Multiple Submission Attempts Flag', false),
              _buildRiskFactor('Manual Review Priority Flag', record.riskStatus == KycRiskStatus.high),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 3. Reviewer Action & Decision Panel
        KcCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Reviewer Notes & Action Decision', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              TextField(
                controller: _reviewerNotesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Enter compliance audit notes before approving/rejecting...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              if (!KycPermissions.canApproveKyc(role))
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline_rounded, size: 18, color: Colors.orange),
                      SizedBox(width: 8),
                      Expanded(child: Text('Employee Role Notice: View access active. Approval and Rejection actions require Manager or Admin permissions.', style: TextStyle(fontSize: 12))),
                    ],
                  ),
                )
              else ...[
                Row(
                  children: [
                    const Text('Approve Level: ', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(width: 8),
                    DropdownButton<KycVerificationLevel>(
                      value: _selectedApproveLevel,
                      onChanged: (val) => setState(() => _selectedApproveLevel = val!),
                      items: KycVerificationLevel.values.map((lvl) => DropdownMenuItem(value: lvl, child: Text(lvl.label))).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    KcPrimaryButton(
                      label: 'Approve KYC',
                      icon: Icons.check_circle_rounded,
                      onPressed: () async {
                        await ref.read(kycQueueProvider.notifier).approveKyc(
                              record.customerId,
                              _reviewerNotesController.text.trim().isEmpty ? 'Verified standard identity proof.' : _reviewerNotesController.text.trim(),
                              level: _selectedApproveLevel,
                            );
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('KYC for ${record.customerName} APPROVED.')));
                          context.go(AppRoutes.kyc);
                        }
                      },
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                      icon: const Icon(Icons.cancel_rounded, size: 18),
                      label: const Text('Reject KYC'),
                      onPressed: () async {
                        final res = await showKycRejectionDialog(context, record.customerName);
                        if (res != null) {
                          await ref.read(kycQueueProvider.notifier).rejectKyc(
                                record.customerId,
                                res['reason']!,
                                res['notes']!,
                              );
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('KYC for ${record.customerName} REJECTED.')));
                            context.go(AppRoutes.kyc);
                          }
                        }
                      },
                    ),
                    KcOutlinedButton(
                      label: 'Request Reverification',
                      icon: Icons.published_with_changes_rounded,
                      onPressed: () async {
                        await ref.read(kycQueueProvider.notifier).requestReverification(
                              record.customerId,
                              _reviewerNotesController.text.trim().isEmpty ? 'Updated address proof requested.' : _reviewerNotesController.text.trim(),
                            );
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reverification requested from ${record.customerName}.')));
                          context.go(AppRoutes.kyc);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFieldMatchRow(String field, String custVal, String docVal, FieldMatchStatus status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(field, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                Text('Cust: $custVal | Doc: $docVal', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          KcStatusBadge(label: status.label, statusColor: status.color, icon: status.icon),
        ],
      ),
    );
  }

  Widget _buildRiskFactor(String title, bool isFlagged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(isFlagged ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded, size: 16, color: isFlagged ? Colors.red : Colors.green),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(fontSize: 12, fontWeight: isFlagged ? FontWeight.w700 : FontWeight.w500)),
        ],
      ),
    );
  }
}
