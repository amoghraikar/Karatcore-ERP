import '../models/reports_model.dart';
import 'reports_repository.dart';

class MockReportsRepository implements IReportsRepository {
  MockReportsRepository() {
    _initData();
  }

  final List<SavedReportView> _savedViews = [];
  final List<UnifiedActivityItem> _activities = [];
  final List<StaffPerformanceItem> _staffPerformance = [];

  void _initData() {
    final now = DateTime.now();

    _savedViews.addAll([
      SavedReportView(id: 'VIEW-01', title: 'My Overdue Loans', category: ReportCategory.loans, filterPreset: DateFilterPreset.thisMonth, isFavorite: true, isPinned: true, lastViewedAt: now.subtract(const Duration(hours: 2))),
      SavedReportView(id: 'VIEW-02', title: 'My Monthly Collections', category: ReportCategory.payments, filterPreset: DateFilterPreset.thisMonth, isFavorite: true, isPinned: false, lastViewedAt: now.subtract(const Duration(days: 1))),
      SavedReportView(id: 'VIEW-03', title: 'Gold Inventory Valuation', category: ReportCategory.inventory, filterPreset: DateFilterPreset.thisQuarter, isFavorite: true, isPinned: true, lastViewedAt: now.subtract(const Duration(days: 2))),
      SavedReportView(id: 'VIEW-04', title: 'Pending KYC Submissions', category: ReportCategory.kyc, filterPreset: DateFilterPreset.thisWeek, isFavorite: false, isPinned: false, lastViewedAt: now.subtract(const Duration(days: 3))),
      SavedReportView(id: 'VIEW-05', title: 'High Exposure Customers', category: ReportCategory.risk, filterPreset: DateFilterPreset.financialYear, isFavorite: true, isPinned: false, lastViewedAt: now.subtract(const Duration(days: 4))),
    ]);

    _activities.addAll([
      UnifiedActivityItem(id: 'ACT-101', timestamp: now.subtract(const Duration(minutes: 12)), module: 'LOAN', actor: 'Rahul Manager', action: 'LOAN_APPROVED', recordId: 'KC-LN-10022', description: 'Gold loan pledge approved for ₹1,85,000 against 42.5g 22K Bangle', route: '/loans/KC-LN-10022'),
      UnifiedActivityItem(id: 'ACT-102', timestamp: now.subtract(const Duration(minutes: 45)), module: 'PAYMENT', actor: 'Priya Cashier', action: 'PAYMENT_RECEIVED', recordId: 'KC-PAY-8802', description: 'Interest collection payment of ₹4,250 received via UPI for KC-LN-10005', route: '/loans/KC-LN-10005'),
      UnifiedActivityItem(id: 'ACT-103', timestamp: now.subtract(const Duration(hours: 2)), module: 'KYC', actor: 'Manager Vikram', action: 'KYC_VERIFIED', recordId: 'KC-CUS-000105', description: 'Aadhaar DigiLocker & PAN verified for Ramesh Chand', route: '/kyc/KC-CUS-000105'),
      UnifiedActivityItem(id: 'ACT-104', timestamp: now.subtract(const Duration(hours: 3)), module: 'INVENTORY', actor: 'Store Auditor', action: 'ORNAMENT_ADDED', recordId: 'KC-ORN-2026-088', description: '22K Heavy Bridal Gold Necklace (58.4g) added to Vault Vault 1', route: '/ornaments'),
      UnifiedActivityItem(id: 'ACT-105', timestamp: now.subtract(const Duration(hours: 5)), module: 'ACCOUNTING', actor: 'Senior Accountant', action: 'JOURNAL_POSTED', recordId: 'KC-JNL-1004', description: 'Manual double-entry voucher posted for Store Lease Rent (₹45,000)', route: '/accounting/journal'),
      UnifiedActivityItem(id: 'ACT-106', timestamp: now.subtract(const Duration(hours: 8)), module: 'CUSTOMER', actor: 'Staff Swati', action: 'CUSTOMER_CREATED', recordId: 'KC-CUS-000122', description: 'New customer onboarding completed for Sunita Devi', route: '/customers/KC-CUS-000122'),
    ]);

    _staffPerformance.addAll([
      const StaffPerformanceItem(staffName: 'Vikram Singh', role: 'Branch Manager', loansProcessed: 28, kycReviews: 45, customersAdded: 14, paymentsRecorded: 62, inventoryMovements: 34, avgProcessingTimeMinutes: 12.5),
      const StaffPerformanceItem(staffName: 'Priya Sharma', role: 'Loan Officer & Cashier', loansProcessed: 42, kycReviews: 12, customersAdded: 25, paymentsRecorded: 110, inventoryMovements: 58, avgProcessingTimeMinutes: 8.4),
      const StaffPerformanceItem(staffName: 'Rahul Verma', role: 'Valuer & Inspector', loansProcessed: 35, kycReviews: 8, customersAdded: 9, paymentsRecorded: 22, inventoryMovements: 85, avgProcessingTimeMinutes: 14.0),
      const StaffPerformanceItem(staffName: 'Swati Patel', role: 'Front Desk Associate', loansProcessed: 12, kycReviews: 30, customersAdded: 32, paymentsRecorded: 48, inventoryMovements: 18, avgProcessingTimeMinutes: 10.2),
    ]);
  }

  @override
  Future<List<SavedReportView>> getSavedReportViews() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_savedViews);
  }

  @override
  Future<void> toggleFavorite(String viewId) async {
    final idx = _savedViews.indexWhere((v) => v.id == viewId);
    if (idx != -1) {
      _savedViews[idx] = _savedViews[idx].copyWith(isFavorite: !_savedViews[idx].isFavorite);
    }
  }

  @override
  Future<void> togglePinned(String viewId) async {
    final idx = _savedViews.indexWhere((v) => v.id == viewId);
    if (idx != -1) {
      _savedViews[idx] = _savedViews[idx].copyWith(isPinned: !_savedViews[idx].isPinned);
    }
  }

  @override
  Future<List<UnifiedActivityItem>> getUnifiedActivityFeed() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_activities);
  }

  @override
  Future<List<StaffPerformanceItem>> getStaffPerformance() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_staffPerformance);
  }

  @override
  Future<SavedReportView?> getSavedReportById(String viewId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final idx = _savedViews.indexWhere((v) => v.id == viewId);
    if (idx != -1) return _savedViews[idx];
    return null;
  }
}
