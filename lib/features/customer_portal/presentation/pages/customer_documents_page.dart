import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/feedback/kc_empty_state.dart';
import '../../../../shared/widgets/feedback/kc_toast.dart';
import '../../providers/customer_portal_providers.dart';

class CustomerDocumentsPage extends ConsumerStatefulWidget {
  const CustomerDocumentsPage({super.key});

  @override
  ConsumerState<CustomerDocumentsPage> createState() => _CustomerDocumentsPageState();
}

class _CustomerDocumentsPageState extends ConsumerState<CustomerDocumentsPage> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final loansAsync = ref.watch(customerLoansProvider);
    final paymentsAsync = ref.watch(customerPaymentsProvider);

    final categories = ['All', 'KYC', 'Loan', 'Receipts'];

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(context.pageGutter),
        children: [
          Text(
            'My Documents',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Encrypted digital copies of loan agreements, KYC verification & payment receipts',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 20),

          // Category Chips
          Row(
            children: categories.map((cat) {
              final isSelected = _selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (val) => setState(() => _selectedCategory = cat),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          loansAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, st) => Text('Error loading documents: $err'),
            data: (loans) {
              final docs = <_DocItem>[];

              // Add KYC document
              if (_selectedCategory == 'All' || _selectedCategory == 'KYC') {
                docs.add(_DocItem(
                  title: 'Aadhaar & PAN KYC Document Verification',
                  category: 'KYC',
                  date: DateTime.now().subtract(const Duration(days: 400)),
                  status: 'VERIFIED',
                  icon: Icons.verified_user_rounded,
                ));
              }

              // Add Loan Agreements
              if (_selectedCategory == 'All' || _selectedCategory == 'Loan') {
                for (final l in loans) {
                  docs.add(_DocItem(
                    title: 'Pledge Loan Agreement #${l.id}',
                    category: 'Loan',
                    date: l.pledgeDate,
                    status: 'ACTIVE CONTRACT',
                    icon: Icons.description_rounded,
                  ));
                }
              }

              // Add Payment Receipts
              if (_selectedCategory == 'All' || _selectedCategory == 'Receipts') {
                final payments = paymentsAsync.valueOrNull ?? [];
                for (final p in payments) {
                  docs.add(_DocItem(
                    title: 'Digital Repayment Receipt #${p.receiptNumber}',
                    category: 'Receipts',
                    date: p.paymentDate,
                    status: 'ISSUED',
                    icon: Icons.receipt_long_rounded,
                  ));
                }
              }

              if (docs.isEmpty) {
                return const KcEmptyState(
                  title: 'No Documents Found',
                  subtitle: 'No digital documents match the selected filter category.',
                  icon: Icons.folder_open_outlined,
                );
              }

              return Column(
                children: docs.map((doc) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: KcCard(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(doc.icon, color: const Color(0xFF7C3AED), size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(child: Text(doc.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14))),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF059669).withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(doc.status, style: const TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.w800, fontSize: 9)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text('Category: ${doc.category} • Date: ${KcFormatters.date(doc.date)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.download_rounded, color: Color(0xFF7C3AED)),
                            tooltip: 'Download Document',
                            onPressed: () {
                              KcToast.success(context, 'Downloading ${doc.title}...', title: 'Document Download');
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DocItem {
  _DocItem({
    required this.title,
    required this.category,
    required this.date,
    required this.status,
    required this.icon,
  });

  final String title;
  final String category;
  final DateTime date;
  final String status;
  final IconData icon;
}
