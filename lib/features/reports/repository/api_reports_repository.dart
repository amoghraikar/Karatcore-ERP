import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/reports_model.dart';
import 'reports_repository.dart';

class ApiReportsRepository implements IReportsRepository {
  ApiReportsRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<SavedReportView>> getSavedReportViews() async {
    try {
      final dynamic data = await _api.get('${ApiEndpoints.reports}/saved-views');
      if (data is List) {
        return data.map((json) => _parseSavedViewFromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<SavedReportView?> getSavedReportById(String viewId) async {
    try {
      final dynamic data = await _api.get('${ApiEndpoints.reports}/saved-views/$viewId');
      return _parseSavedViewFromJson(data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> toggleFavorite(String viewId) async {
    await _api.post('${ApiEndpoints.reports}/saved-views/$viewId/favorite', body: {});
  }

  @override
  Future<void> togglePinned(String viewId) async {
    await _api.post('${ApiEndpoints.reports}/saved-views/$viewId/pin', body: {});
  }

  @override
  Future<List<UnifiedActivityItem>> getUnifiedActivityFeed() async {
    try {
      final dynamic data = await _api.get('${ApiEndpoints.reports}/activity-feed');
      if (data is List) {
        return data.map((json) => _parseActivityFromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<StaffPerformanceItem>> getStaffPerformance() async {
    try {
      final dynamic data = await _api.get('${ApiEndpoints.reports}/staff-performance');
      if (data is List) {
        return data.map((json) => _parseStaffFromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  SavedReportView _parseSavedViewFromJson(Map<String, dynamic> json) {
    return SavedReportView(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      category: ReportCategory.values.firstWhere((e) => e.name == json['category'], orElse: () => ReportCategory.executive),
      filterPreset: DateFilterPreset.values.firstWhere((e) => e.name == json['preset'], orElse: () => DateFilterPreset.thisMonth),
      isFavorite: json['is_favorite'] as bool? ?? false,
      isPinned: json['is_pinned'] as bool? ?? false,
      lastViewedAt: DateTime.tryParse(json['last_viewed_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  UnifiedActivityItem _parseActivityFromJson(Map<String, dynamic> json) {
    return UnifiedActivityItem(
      id: json['id'] as String,
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
      module: json['module'] as String? ?? '',
      actor: json['actor'] as String? ?? '',
      action: json['action'] as String? ?? '',
      recordId: json['record_id'] as String? ?? '',
      description: json['description'] as String? ?? '',
      route: json['route'] as String? ?? '',
    );
  }

  StaffPerformanceItem _parseStaffFromJson(Map<String, dynamic> json) {
    return StaffPerformanceItem(
      staffName: json['staff_name'] as String? ?? '',
      role: json['role'] as String? ?? '',
      loansProcessed: (json['loans_processed'] as num? ?? 0).toInt(),
      kycReviews: (json['kyc_reviews'] as num? ?? 0).toInt(),
      customersAdded: (json['customers_added'] as num? ?? 0).toInt(),
      paymentsRecorded: (json['payments_recorded'] as num? ?? 0).toInt(),
      inventoryMovements: (json['inventory_movements'] as num? ?? 0).toInt(),
      avgProcessingTimeMinutes: (json['avg_processing_time_minutes'] as num? ?? 0.0).toDouble(),
    );
  }
}
