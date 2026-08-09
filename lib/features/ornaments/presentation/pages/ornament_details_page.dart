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

import '../../models/ornament_model.dart';
import '../../providers/inventory_providers.dart';
import '../../widgets/barcode_qr_dialog.dart';
import '../../widgets/ornament_status_chip.dart';
import '../../widgets/transfer_ornament_dialog.dart';

class OrnamentDetailsPage extends ConsumerStatefulWidget {
  const OrnamentDetailsPage({super.key, this.id});

  final String? id;

  @override
  ConsumerState<OrnamentDetailsPage> createState() => _OrnamentDetailsPageState();
}

class _OrnamentDetailsPageState extends ConsumerState<OrnamentDetailsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this);
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
    return 'KC-ORN-000101';
  }

  @override
  Widget build(BuildContext context) {
    final id = _getTargetId();
    final ornamentAsync = ref.watch(ornamentDetailProvider(id));
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: ornamentAsync.when(
        loading: () => ListView(
          padding: EdgeInsets.all(context.pageGutter),
          children: const [KcSkeletonLoader(height: 120), SizedBox(height: 20), KcSkeletonLoader(height: 500)],
        ),
        error: (err, st) => KcErrorState(
          message: 'Unable to load ornament details: ${err.toString()}',
          onRetry: () => ref.invalidate(ornamentDetailProvider(id)),
        ),
        data: (ornament) {
          if (ornament == null) {
            return KcEmptyState(
              title: 'Ornament Not Found',
              subtitle: 'No inventory record for ID "$id".',
              action: KcPrimaryButton(
                label: 'Return to Inventory',
                onPressed: () => context.go(AppRoutes.ornaments),
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
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(image: NetworkImage(ornament.imageUrl), fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(ornament.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                              const SizedBox(width: 12),
                              OrnamentStatusChip(status: ornament.status),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ID: ${ornament.id} • Category: ${ornament.category.label} • ${ornament.metalType.label} ${ornament.purity.label} • Barcode: ${ornament.barcode}',
                            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      children: [
                        KcOutlinedButton(
                          label: 'Barcode Tag',
                          icon: Icons.qr_code_2_rounded,
                          onPressed: () => showBarcodeQrDialog(context, ornament),
                        ),
                        KcPrimaryButton(
                          label: 'Vault Transfer',
                          icon: Icons.sync_alt_rounded,
                          onPressed: () => showTransferOrnamentDialog(context, ornament),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 8 Responsive Tabs Header
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Specifications'),
                  Tab(text: 'Valuation'),
                  Tab(text: 'Ownership & KYC'),
                  Tab(text: 'Location'),
                  Tab(text: 'Documents'),
                  Tab(text: 'Images Gallery'),
                  Tab(text: 'History & Movements'),
                ],
              ),
              const SizedBox(height: 16),

              // Tab View Content
              SizedBox(
                height: 520,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(ornament),
                    _buildSpecificationsTab(ornament),
                    _buildValuationTab(ornament),
                    _buildOwnershipTab(ornament),
                    _buildLocationTab(ornament),
                    _buildDocumentsTab(ornament),
                    _buildImagesTab(ornament),
                    _buildHistoryTab(ornament),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverviewTab(OrnamentModel o) {
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
                    Text('Ornament Identity Overview', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    _buildRow('Ornament ID', o.id),
                    _buildRow('Category', o.category.label),
                    _buildRow('Metal Type', o.metalType.label),
                    _buildRow('Purity Standard', o.purity.label),
                    _buildRow('Gross Weight', '${o.weight.grossWeight} g'),
                    _buildRow('Stones Weight', '${o.weight.stoneWeight} g'),
                    _buildRow('Other Weight', '${o.weight.otherWeight} g'),
                    _buildRow('Net Metal Weight', '${o.weight.netMetalWeight} g'),
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
                    Text('Financial & Location Summary', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    _buildRow('Estimated Value', KcFormatters.inr(o.valuation.totalEstimatedValue)),
                    _buildRow('Metal Rate', '${KcFormatters.inr(o.valuation.metalRate)} / g'),
                    _buildRow('Ownership Type', o.ownershipType.label),
                    _buildRow('Owner Name', o.ownerCustomerName ?? 'Shop Inventory'),
                    _buildRow('Branch Vault', o.location.branch),
                    _buildRow('Locker & Tray', '${o.location.locker} • ${o.location.tray}'),
                    _buildRow('Date Created', KcFormatters.date(o.createdAt)),
                    _buildRow('Last Audit Update', KcFormatters.relativeTime(o.updatedAt)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSpecificationsTab(OrnamentModel o) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      children: [
        KcCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Detailed Craftsmanship & Stone Specifications', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              _buildRow('Subcategory Style', o.subcategory),
              _buildRow('Design Pattern', 'Heritage Antique Filigree'),
              _buildRow('Stone Type', 'Ruby & Cubic Zirconia'),
              _buildRow('Stones Count', '14 Gems'),
              _buildRow('Stones Weight', '${o.weight.stoneWeight} g'),
              _buildRow('BIS Hallmarked', 'Yes — Certified 916'),
              _buildRow('Description', o.description),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildValuationTab(OrnamentModel o) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      children: [
        KcCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Real-Time Valuation Breakdown (Mock)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              _buildRow('Metal Rate / g', KcFormatters.inr(o.valuation.metalRate)),
              _buildRow('Net Metal Weight', '${o.weight.netMetalWeight} g'),
              _buildRow('Calculated Metal Value', KcFormatters.inr(o.valuation.metalValue)),
              _buildRow('Making Charges', KcFormatters.inr(o.valuation.makingCharges)),
              _buildRow('Stones Value', KcFormatters.inr(o.valuation.stoneValue)),
              _buildRow('Other Charges', KcFormatters.inr(o.valuation.otherCharges)),
              const Divider(height: 24),
              _buildRow('Total Estimated Value', KcFormatters.inr(o.valuation.totalEstimatedValue)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOwnershipTab(OrnamentModel o) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      children: [
        KcCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Asset Ownership & KYC Integration', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              _buildRow('Ownership Type', o.ownershipType.label),
              if (o.ownerCustomerName != null) ...[
                _buildRow('Customer Name', o.ownerCustomerName!),
                _buildRow('Customer ID', o.ownerCustomerId!),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('KYC Verification Status:', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    KcStatusBadge(label: o.ownerKycStatus, statusColor: const Color(0xFF059669), icon: Icons.verified_rounded),
                  ],
                ),
                if (o.pledgeLoanId != null) ...[
                  _buildRow('Pledge Gold Loan ID', o.pledgeLoanId!),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      KcOutlinedButton(
                        label: 'View Customer Profile',
                        icon: Icons.person_rounded,
                        onPressed: () => context.go('/customers/${o.ownerCustomerId}'),
                      ),
                      const SizedBox(width: 12),
                      KcPrimaryButton(
                        label: 'View Gold Loan Account',
                        icon: Icons.account_balance_rounded,
                        onPressed: () => context.go('/loans/${o.pledgeLoanId}'),
                      ),
                    ],
                  ),
                ] else ...[
                  const SizedBox(height: 16),
                  KcOutlinedButton(
                    label: 'View Customer Profile',
                    icon: Icons.person_rounded,
                    onPressed: () => context.go('/customers/${o.ownerCustomerId}'),
                  ),
                ],
              ] else
                const Text('This ornament is currently owned by Shop Store Inventory.'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationTab(OrnamentModel o) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      children: [
        KcCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Vault Storage Location Hierarchy', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              _buildRow('Branch Store', o.location.branch),
              _buildRow('Storage Area', o.location.storageArea),
              _buildRow('Vault Locker', o.location.locker),
              _buildRow('Shelf Number', o.location.shelf),
              _buildRow('Tray Number', o.location.tray),
              const SizedBox(height: 16),
              KcPrimaryButton(
                label: 'Transfer Vault Location',
                icon: Icons.sync_alt_rounded,
                onPressed: () => showTransferOrnamentDialog(context, o),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentsTab(OrnamentModel o) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      children: [
        KcCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Attached Certificates & Documents', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              if (o.documents.isEmpty)
                const Text('No documents attached.')
              else
                ...o.documents.map((doc) => ListTile(
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

  Widget _buildImagesTab(OrnamentModel o) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      children: [
        KcCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Product Photography Gallery', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Container(
                height: 240,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(image: NetworkImage(o.imageUrl), fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Primary high-resolution vault photo. Sealed and timestamped.'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryTab(OrnamentModel o) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      children: [
        KcCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Movement History & Audit Log', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              if (o.movements.isEmpty)
                const Text('No movements recorded.')
              else
                ...o.movements.map((mov) => ListTile(
                      leading: CircleAvatar(backgroundColor: Theme.of(context).colorScheme.primaryContainer, child: Icon(mov.type.icon, size: 18)),
                      title: Text(mov.type.label, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text('From: ${mov.fromLocation} → To: ${mov.toLocation}\nBy: ${mov.actorName} • Reason: ${mov.reason}'),
                      trailing: Text(KcFormatters.date(mov.date), style: const TextStyle(fontSize: 11)),
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
