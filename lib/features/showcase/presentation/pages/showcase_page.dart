import 'package:flutter/material.dart';
import '../../../../core/constants/color_tokens.dart';
import '../../../../core/constants/icon_tokens.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';

import '../../../../shared/components/kc_avatar.dart';

import '../../../../shared/widgets/buttons/kc_outlined_button.dart';
import '../../../../shared/widgets/buttons/kc_primary_button.dart';
import '../../../../shared/widgets/buttons/kc_secondary_button.dart';

import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/cards/kc_document_upload_card.dart';
import '../../../../shared/widgets/cards/kc_metric_card.dart';
import '../../../../shared/widgets/cards/kc_profile_card.dart';
import '../../../../shared/widgets/cards/kc_timeline_card.dart';

import '../../../../shared/widgets/charts/kc_chart_wrapper.dart';
import '../../../../shared/widgets/dialogs/kc_bottom_sheets.dart';
import '../../../../shared/widgets/dialogs/kc_dialogs.dart';
import '../../../../shared/widgets/dialogs/kc_snackbars.dart';

import '../../../../shared/widgets/feedback/kc_empty_state.dart';
import '../../../../shared/widgets/feedback/kc_error_state.dart';
import '../../../../shared/widgets/feedback/kc_loading_widget.dart';
import '../../../../shared/widgets/feedback/kc_skeleton_loader.dart';
import '../../../../shared/widgets/feedback/kc_status_badge.dart';

import '../../../../shared/widgets/inputs/kc_date_picker.dart';
import '../../../../shared/widgets/inputs/kc_dropdown.dart';
import '../../../../shared/widgets/inputs/kc_filters.dart';
import '../../../../shared/widgets/inputs/kc_password_field.dart';
import '../../../../shared/widgets/inputs/kc_search_bar_ui.dart';
import '../../../../shared/widgets/inputs/kc_text_field.dart';

import '../../../../shared/widgets/tables/kc_data_table.dart';
import '../../../../shared/widgets/tables/kc_pagination.dart';

class ShowcasePage extends StatefulWidget {
  const ShowcasePage({super.key});

  @override
  State<ShowcasePage> createState() => _ShowcasePageState();
}

class _ShowcasePageState extends State<ShowcasePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentPage = 1;
  int _itemsPerPage = 10;
  String _selectedFilter = 'all';
  DateTime? _selectedDate = DateTime.now();

  final List<Map<String, String>> _tableData = [
    {'id': 'LOAN-901', 'client': 'Aarav Mehta', 'weight': '145.2 g', 'amount': '₹8,45,000', 'status': 'ACTIVE'},
    {'id': 'LOAN-902', 'client': 'Priya Sharma', 'weight': '88.5 g', 'amount': '₹4,90,000', 'status': 'ACTIVE'},
    {'id': 'LOAN-903', 'client': 'Vikram Singhania', 'weight': '320.0 g', 'amount': '₹19,20,000', 'status': 'AUDITED'},
    {'id': 'LOAN-904', 'client': 'Neha Verma', 'weight': '64.0 g', 'amount': '₹3,50,000', 'status': 'PENDING'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(context.pageGutter),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KaratCore Design System & UI Kit',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Production-grade reusable component library & design tokens preview',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              const KcStatusBadge(
                label: 'UI KIT COMPLETED',
                type: KcStatusType.success,
              ),
            ],
          ),
          const SizedBox(height: 20),
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: const [
              Tab(text: 'Design Tokens'),
              Tab(text: 'Buttons & Inputs'),
              Tab(text: 'Cards & Displays'),
              Tab(text: 'Tables & Charts'),
              Tab(text: 'Overlays & Feedback'),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 900,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDesignTokensSection(context, isDark),
                _buildButtonsAndInputsSection(context),
                _buildCardsAndDisplaysSection(context),
                _buildTablesAndChartsSection(context),
                _buildOverlaysAndFeedbackSection(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesignTokensSection(BuildContext context, bool isDark) {
    return ListView(
      children: [
        Text(
          'Monochromatic Swiss Palette',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        const Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _ColorTile(name: 'Pitch Black', color: KcColors.pitchBlack),
            _ColorTile(name: 'Carbon 950', color: KcColors.carbon950),
            _ColorTile(name: 'Carbon 800', color: KcColors.carbon800),
            _ColorTile(name: 'Carbon 500', color: KcColors.carbon500),
            _ColorTile(name: 'Carbon 200', color: KcColors.carbon200),
            _ColorTile(name: 'Pure White', color: KcColors.pureWhite),
            _ColorTile(name: 'Signal Orange', color: KcColors.signalOrange),
            _ColorTile(name: 'Signal Green', color: KcColors.signalGreen),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Typography Scale (Space Grotesk & Inter)',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        KcCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Display Large — 48pt Bold', style: Theme.of(context).textTheme.displayLarge),
              const SizedBox(height: 8),
              Text('Headline Medium — 22pt Bold', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text('Title Large — 17pt SemiBold', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('Body Medium — 13pt Regular Inter text', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildButtonsAndInputsSection(BuildContext context) {
    return ListView(
      children: [
        Text(
          'Button System',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            KcPrimaryButton(label: 'Primary Button', onPressed: () {}),
            KcSecondaryButton(label: 'Secondary Button', onPressed: () {}),
            KcOutlinedButton(label: 'Outlined Button', onPressed: () {}),
            KcPrimaryButton(label: 'Loading...', isLoading: true, onPressed: () {}),
            KcPrimaryButton(label: 'Icon Action', icon: KcIcons.add, onPressed: () {}),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Form Inputs & Controls',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        KcCard(
          child: Column(
            children: [
              const KcTextField(label: 'Full Name', hintText: 'Enter customer name'),
              const SizedBox(height: 14),
              const KcPasswordField(label: 'Master Password'),
              const SizedBox(height: 14),
              KcDropdown<String>(
                label: 'Ornament Purity',
                value: '22K',
                onChanged: (val) {},
                items: const [
                  DropdownMenuItem(value: '24K', child: Text('24K (99.9% Pure)')),
                  DropdownMenuItem(value: '22K', child: Text('22K (91.6% Hallmark)')),
                  DropdownMenuItem(value: '18K', child: Text('18K (75.0% Gold)')),
                ],
              ),
              const SizedBox(height: 14),
              KcDatePicker(
                label: 'Audit Due Date',
                selectedDate: _selectedDate,
                onDateSelected: (dt) => setState(() => _selectedDate = dt),
              ),
              const SizedBox(height: 14),
              KcFilterGroup<String>(
                options: const [
                  KcFilterOption(label: 'All Portfolio', value: 'all'),
                  KcFilterOption(label: 'Active Loans', value: 'active'),
                  KcFilterOption(label: 'Audit Pending', value: 'pending'),
                ],
                selectedValue: _selectedFilter,
                onSelected: (val) => setState(() => _selectedFilter = val),
              ),
              const SizedBox(height: 14),
              const KcSearchBarUI(
                hintText: 'Search customer ledger or loan receipt...',
                suggestions: ['Mehta Jewellers', 'Gold Loan #901', 'Purity Audit 2026'],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCardsAndDisplaysSection(BuildContext context) {
    return ListView(
      children: [
        Text(
          'Executive Cards & Uploaders',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Expanded(
              child: KcMetricCard(
                title: 'Total Bullion Stock',
                value: '12.4 Kg',
                trend: '+4.2% verified',
                icon: KcIcons.ornaments,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: KcMetricCard(
                title: 'Daily Cash Revenue',
                value: KcFormatters.currency(1450000),
                trend: '+18% growth',
                icon: KcIcons.income,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Row(
          children: [
            Expanded(
              child: KcProfileCard(
                name: 'Aarav Mehta',
                email: 'aarav@mehtajewellers.in',
                role: 'Senior Bullion Dealer',
                initials: 'AM',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: KcTimelineCard(
                title: 'Hallmark Audit Completed',
                subtitle: 'BIS Certification #901 verified by Inspector',
                time: '10:45 AM',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: KcDocumentUploadCard(
                title: 'Upload Customer Aadhar KYC',
                onUploadTap: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: KcDocumentUploadCard(
                title: 'Purity Certificate #8841.pdf',
                status: KcUploadStatus.completed,
                fileSize: '2.4 MB',
                onRemoveTap: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTablesAndChartsSection(BuildContext context) {
    return ListView(
      children: [
        Text(
          'Data Table & Pagination',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        KcCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              KcDataTable<Map<String, String>>(
                columns: [
                  KcTableColumn(header: 'Receipt ID', cellBuilder: (item) => Text(item['id']!)),
                  KcTableColumn(header: 'Client Name', cellBuilder: (item) => Text(item['client']!)),
                  KcTableColumn(header: 'Gross Weight', cellBuilder: (item) => Text(item['weight']!)),
                  KcTableColumn(header: 'Loan Amount', cellBuilder: (item) => Text(item['amount']!)),
                  KcTableColumn(
                    header: 'Status',
                    cellBuilder: (item) => KcStatusBadge(
                      label: item['status']!,
                      type: item['status'] == 'ACTIVE' ? KcStatusType.success : KcStatusType.warning,
                    ),
                  ),
                ],
                items: _tableData,
              ),
              KcPagination(
                currentPage: _currentPage,
                totalPages: 4,
                totalItems: 40,
                itemsPerPage: _itemsPerPage,
                onPageChanged: (page) => setState(() => _currentPage = page),
                onItemsPerPageChanged: (size) => setState(() => _itemsPerPage = size),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Charts Library (fl_chart Wrapper)',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: KcCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Gold Rate Trend', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 12),
                    KcChartWrapper.lineChart(
                      context: context,
                      data: const [
                        KcChartDataPoint(xLabel: 'Mon', value: 7200),
                        KcChartDataPoint(xLabel: 'Tue', value: 7350),
                        KcChartDataPoint(xLabel: 'Wed', value: 7300),
                        KcChartDataPoint(xLabel: 'Thu', value: 7450),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: KcCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Inventory Purity Split', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 12),
                    KcChartWrapper.donutChart(
                      context: context,
                      data: const [
                        KcDonutDataPoint(label: '24K Fine Gold', value: 50, color: KcColors.signalOrange),
                        KcDonutDataPoint(label: '22K Hallmark', value: 35, color: KcColors.signalGreen),
                        KcDonutDataPoint(label: '18K Diamond', value: 15, color: KcColors.signalBlue),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOverlaysAndFeedbackSection(BuildContext context) {
    return ListView(
      children: [
        Text(
          'Avatars & Badges',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        const Wrap(
          spacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            KcAvatar(initials: 'AM'),
            KcAvatar(initials: 'PS', status: KcAvatarStatus.online),
            KcAvatar(initials: 'VS', status: KcAvatarStatus.busy),
            KcAvatarGroup(
              avatars: [
                KcAvatar(initials: 'A1'),
                KcAvatar(initials: 'B2'),
                KcAvatar(initials: 'C3'),
                KcAvatar(initials: 'D4'),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Loading & Feedback States',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        const Row(
          children: [
            Expanded(child: KcSkeletonLoader(height: 80)),
            SizedBox(width: 12),
            Expanded(child: KcLoadingWidget(message: 'Verifying Purity...')),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: KcCard(
                child: KcEmptyState(
                  title: 'No Active Vault Audits',
                  subtitle: 'Start a new audit to verify ornament weight.',
                  action: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Create Audit'),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: KcCard(
                child: KcErrorState(
                  message: 'Vault connection interrupted',
                  onRetry: () {},
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Dialogs, Bottom Sheets & Snackbars',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: [
            KcPrimaryButton(
              label: 'Trigger Dialog',
              onPressed: () => KcDialogs.confirm(
                context: context,
                title: 'Confirm Loan Settlement',
                message: 'Are you sure you want to close Gold Loan #901?',
              ),
            ),
            KcSecondaryButton(
              label: 'Trigger Bottom Sheet',
              onPressed: () => KcBottomSheets.show(
                context: context,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Quick Filter Options', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      const KcTextField(label: 'Custom Loan Range'),
                    ],
                  ),
                ),
              ),
            ),
            KcOutlinedButton(
              label: 'Trigger Snackbar',
              onPressed: () => KcSnackbars.success(context, 'Purity certificate updated!'),
            ),
          ],
        ),
      ],
    );
  }
}

class _ColorTile extends StatelessWidget {
  const _ColorTile({required this.name, required this.color});
  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 11,
              color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
            ),
          ),
          Text(
            '#${(color.a * 255).toInt().toRadixString(16).padLeft(2, '0')}${(color.r * 255).toInt().toRadixString(16).padLeft(2, '0')}${(color.g * 255).toInt().toRadixString(16).padLeft(2, '0')}${(color.b * 255).toInt().toRadixString(16).padLeft(2, '0')}',
            style: TextStyle(
              fontSize: 9,
              color: color.computeLuminance() > 0.5 ? Colors.black54 : Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
