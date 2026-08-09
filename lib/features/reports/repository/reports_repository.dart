import '../models/reports_model.dart';

abstract class IReportsRepository {
  Future<List<SavedReportView>> getSavedReportViews();

  Future<void> toggleFavorite(String viewId);

  Future<void> togglePinned(String viewId);

  Future<List<UnifiedActivityItem>> getUnifiedActivityFeed();

  Future<List<StaffPerformanceItem>> getStaffPerformance();

  Future<SavedReportView?> getSavedReportById(String viewId);
}
