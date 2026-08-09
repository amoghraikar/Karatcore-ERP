import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../shared/components/kc_avatar.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/feedback/kc_status_badge.dart';
import '../models/customer_model.dart';
import 'customer_quick_actions_menu.dart';

class CustomerDataTable extends StatelessWidget {
  const CustomerDataTable({
    super.key,
    required this.customers,
  });

  final List<CustomerModel> customers;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return KcCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
              border: Border(bottom: BorderSide(color: scheme.outline.withValues(alpha: 0.3))),
            ),
            child: const Row(
              children: [
                Expanded(flex: 3, child: Text('Customer', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
                Expanded(flex: 2, child: Text('Contact', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
                Expanded(flex: 2, child: Text('KYC & Status', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
                Expanded(flex: 2, child: Text('Active Loans', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
                Expanded(flex: 2, child: Text('Outstanding', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
                Expanded(flex: 2, child: Text('Risk Level', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
                SizedBox(width: 50, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13), textAlign: TextAlign.center)),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: customers.length,
            separatorBuilder: (context, index) => Divider(height: 1, color: scheme.outline.withValues(alpha: 0.15)),
            itemBuilder: (context, index) {
              final c = customers[index];
              return InkWell(
                onTap: () => context.go('/customers/${c.id}'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            KcAvatar(initials: c.initials, imageUrl: c.avatarUrl, size: 38),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c.fullName,
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'ID: ${c.id}',
                                    style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.mobile, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text(c.city, style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            KcStatusBadge(
                              label: c.kycStatus.label,
                              statusColor: c.kycStatus.color,
                              icon: c.kycStatus.icon,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              c.customerStatus.label,
                              style: TextStyle(fontSize: 11, color: c.customerStatus.color, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${c.activeLoansCount} Active',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: c.activeLoansCount > 0 ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          KcFormatters.currency(c.totalOutstandingAmount),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: c.totalOutstandingAmount > 0 ? scheme.primary : scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: KcStatusBadge(
                          label: c.riskStatus.label,
                          statusColor: c.riskStatus.color,
                          icon: c.riskStatus.icon,
                        ),
                      ),
                      SizedBox(
                        width: 50,
                        child: Center(
                          child: CustomerQuickActionsMenu(customer: c),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
