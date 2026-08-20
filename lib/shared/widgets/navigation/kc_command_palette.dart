import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/color_tokens.dart';
import '../../../core/routing/routes.dart';
import '../../../features/customers/providers/customer_providers.dart';
import '../../../features/loans/providers/loan_providers.dart';

class KcCommandItem {
  const KcCommandItem({
    required this.title,
    required this.subtitle,
    required this.category,
    required this.icon,
    required this.onSelect,
  });

  final String title;
  final String subtitle;
  final String category;
  final IconData icon;
  final VoidCallback onSelect;
}

class KcCommandPalette extends ConsumerStatefulWidget {
  const KcCommandPalette({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) => const KcCommandPalette(),
    );
  }

  @override
  ConsumerState<KcCommandPalette> createState() => _KcCommandPaletteState();
}

class _KcCommandPaletteState extends ConsumerState<KcCommandPalette> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<KcCommandItem> _buildCommands(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final List<KcCommandItem> allItems = [];

    // Core Quick Actions
    allItems.add(
      KcCommandItem(
        title: 'Create New Customer',
        subtitle: 'Onboard a new client with Aadhaar & KYC verification',
        category: 'ACTIONS',
        icon: Icons.person_add_alt_1_outlined,
        onSelect: () => context.go(AppRoutes.customerCreate),
      ),
    );
    allItems.add(
      KcCommandItem(
        title: 'New Gold Pledge Loan',
        subtitle: 'Issue a gold loan receipt against pledged ornaments',
        category: 'ACTIONS',
        icon: Icons.add_circle_outline_rounded,
        onSelect: () => context.go(AppRoutes.loanCreate),
      ),
    );
    allItems.add(
      KcCommandItem(
        title: 'Add New Ornament',
        subtitle: 'Register new jewellery piece into inventory vault',
        category: 'ACTIONS',
        icon: Icons.inventory_2_outlined,
        onSelect: () => context.go(AppRoutes.ornamentCreate),
      ),
    );

    // Primary Pages
    allItems.add(
      KcCommandItem(
        title: 'Dashboard',
        subtitle: 'Overview of revenue, active loans, and daily tasks',
        category: 'NAVIGATION',
        icon: Icons.dashboard_outlined,
        onSelect: () => context.go(AppRoutes.dashboard),
      ),
    );
    allItems.add(
      KcCommandItem(
        title: 'Customer Directory',
        subtitle: 'View registered customers and KYC profiles',
        category: 'NAVIGATION',
        icon: Icons.people_outline_rounded,
        onSelect: () => context.go(AppRoutes.customers),
      ),
    );
    allItems.add(
      KcCommandItem(
        title: 'Gold Loans Ledger',
        subtitle: 'Manage active, overdue, and closed loan receipts',
        category: 'NAVIGATION',
        icon: Icons.account_balance_outlined,
        onSelect: () => context.go(AppRoutes.loans),
      ),
    );
    allItems.add(
      KcCommandItem(
        title: 'Ornaments Inventory',
        subtitle: 'Jewellery vault catalog, purity, and weights',
        category: 'NAVIGATION',
        icon: Icons.diamond_outlined,
        onSelect: () => context.go(AppRoutes.ornaments),
      ),
    );
    allItems.add(
      KcCommandItem(
        title: 'Accounting & Ledger',
        subtitle: 'Cash book, bank transactions, Day Book, and P&L',
        category: 'NAVIGATION',
        icon: Icons.menu_book_rounded,
        onSelect: () => context.go(AppRoutes.accounting),
      ),
    );
    allItems.add(
      KcCommandItem(
        title: 'Executive Financial Reports',
        subtitle: 'Generate monthly performance & profitability intelligence',
        category: 'REPORTS',
        icon: Icons.bar_chart_rounded,
        onSelect: () => context.go(AppRoutes.reports),
      ),
    );
    allItems.add(
      KcCommandItem(
        title: 'System Settings',
        subtitle: 'Store profile, interest rates, and security options',
        category: 'SETTINGS',
        icon: Icons.settings_outlined,
        onSelect: () => context.go(AppRoutes.settings),
      ),
    );

    // Dynamic search matching customers
    final customers = ref.watch(customerListProvider).valueOrNull ?? [];
    for (final c in customers) {
      if (query.isNotEmpty && (c.fullName.toLowerCase().contains(query) || c.mobile.contains(query))) {
        allItems.add(
          KcCommandItem(
            title: c.fullName,
            subtitle: 'Customer • ${c.mobile} • Status: ${c.customerStatus.name}',
            category: 'CUSTOMERS',
            icon: Icons.person_outline_rounded,
            onSelect: () => context.go('/customers/${c.id}'),
          ),
        );
      }
    }

    // Dynamic search matching loans
    final loans = ref.watch(loanListProvider).valueOrNull ?? [];
    for (final l in loans) {
      if (query.isNotEmpty && (l.id.toLowerCase().contains(query) || l.customerName.toLowerCase().contains(query))) {
        allItems.add(
          KcCommandItem(
            title: 'Loan Receipt #${l.id}',
            subtitle: '${l.customerName} • ${l.collateralNetWeightGrams}g • ${l.status.name}',
            category: 'LOANS',
            icon: Icons.receipt_long_outlined,
            onSelect: () => context.go('/loans/${l.id}'),
          ),
        );
      }
    }

    if (query.isEmpty) {
      return allItems;
    }

    return allItems.where((item) {
      return item.title.toLowerCase().contains(query) ||
          item.subtitle.toLowerCase().contains(query) ||
          item.category.toLowerCase().contains(query);
    }).toList();
  }

  void _handleKeyEvent(KeyEvent event, List<KcCommandItem> items) {
    if (event is! KeyDownEvent) return;

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (items.isNotEmpty) {
        setState(() {
          _selectedIndex = (_selectedIndex + 1) % items.length;
        });
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (items.isNotEmpty) {
        setState(() {
          _selectedIndex = (_selectedIndex - 1 + items.length) % items.length;
        });
      }
    } else if (event.logicalKey == LogicalKeyboardKey.enter) {
      if (items.isNotEmpty && _selectedIndex < items.length) {
        Navigator.pop(context);
        items[_selectedIndex].onSelect();
      }
    } else if (event.logicalKey == LogicalKeyboardKey.escape) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = _buildCommands(context);

    if (_selectedIndex >= items.length && items.isNotEmpty) {
      _selectedIndex = 0;
    }

    final cardBg = isDark ? KcColors.surfaceDark : KcColors.surfaceLight;
    final borderColor = isDark ? KcColors.borderDark : KcColors.borderLight;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (evt) => _handleKeyEvent(evt, items),
        child: Container(
          width: 640,
          constraints: const BoxConstraints(maxHeight: 520),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.15),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search Input Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
                child: Row(
                  children: [
                    Icon(
                      Icons.search_rounded,
                      size: 22,
                      color: isDark ? KcColors.textSecondaryDark : KcColors.textSecondaryLight,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _focusNode,
                        onChanged: (_) => setState(() => _selectedIndex = 0),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isDark ? KcColors.textPrimaryDark : KcColors.textPrimaryLight,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search customers, loans, ornaments, accounting, or pages...',
                          hintStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            color: isDark ? KcColors.textMutedDark : KcColors.textMutedLight,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          fillColor: Colors.transparent,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0x1FA0A0A0) : const Color(0x0F111214),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'ESC',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isDark ? KcColors.textMutedDark : KcColors.textMutedLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: borderColor),
              // Results List
              Flexible(
                child: items.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 36,
                              color: isDark ? KcColors.textMutedDark : KcColors.textMutedLight,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No matching commands found',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isDark ? KcColors.textPrimaryDark : KcColors.textPrimaryLight,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Try searching for customer names, loan IDs, or system modules.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: isDark ? KcColors.textSecondaryDark : KcColors.textSecondaryLight,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        shrinkWrap: true,
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final isSelected = index == _selectedIndex;

                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                item.onSelect();
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? (isDark ? const Color(0x1FFFFFFF) : const Color(0x0A111214))
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? KcColors.goldSubdued
                                            : (isDark ? const Color(0x0AFFFFFF) : const Color(0x05111214)),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        item.icon,
                                        size: 18,
                                        color: isSelected
                                            ? KcColors.goldAccent
                                            : (isDark ? KcColors.textSecondaryDark : KcColors.textSecondaryLight),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.title,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 14,
                                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                              color: isDark ? KcColors.textPrimaryDark : KcColors.textPrimaryLight,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            item.subtitle,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              color: isDark ? KcColors.textSecondaryDark : KcColors.textSecondaryLight,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0x1FA0A0A0) : const Color(0x0A111214),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        item.category,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.8,
                                          color: isDark ? KcColors.textMutedDark : KcColors.textMutedLight,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Divider(height: 1, color: borderColor),
              // Keyboard Navigation Hint Footer
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                child: Row(
                  children: [
                    Text(
                      'Use ',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, color: isDark ? KcColors.textMutedDark : KcColors.textMutedLight),
                    ),
                    const _KbdChip('↑'),
                    const _KbdChip('↓'),
                    Text(
                      ' to navigate, ',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, color: isDark ? KcColors.textMutedDark : KcColors.textMutedLight),
                    ),
                    const _KbdChip('↵'),
                    Text(
                      ' to select',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, color: isDark ? KcColors.textMutedDark : KcColors.textMutedLight),
                    ),
                    const Spacer(),
                    Text(
                      'KARATCORE COMMAND',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color: KcColors.goldAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KbdChip extends StatelessWidget {
  const _KbdChip(this.char);
  final String char;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? const Color(0x1FA0A0A0) : const Color(0x0F111214),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        char,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: isDark ? KcColors.textPrimaryDark : KcColors.textPrimaryLight,
        ),
      ),
    );
  }
}
