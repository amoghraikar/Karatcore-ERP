import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/loan_model.dart';
import 'pledge_repository.dart';

class ApiPledgeRepository implements IPledgeRepository {
  ApiPledgeRepository(this._api);

  final ApiClient _api;

  @override
  Future<PledgeModel?> getPledgeById(String id) async {
    try {
      final dynamic data = await _api.get('${ApiEndpoints.loans}/pledges/$id');
      return _parsePledgeFromJson(data);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<PledgeModel?> getPledgeByLoanId(String loanId) async {
    try {
      final dynamic data = await _api.get('${ApiEndpoints.loans}/$loanId/pledge');
      return _parsePledgeFromJson(data);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<PledgeModel>> getPledgesByCustomerId(String customerId) async {
    final dynamic data = await _api.get('${ApiEndpoints.loans}/customer/$customerId/pledges');
    return _parsePledgesFromJson(data as List);
  }

  @override
  Future<PledgeModel> createPledge(PledgeModel pledge) async {
    final dynamic data = await _api.post(
      '${ApiEndpoints.loans}/${pledge.loanId}/pledge',
      body: _pledgeToJson(pledge),
    );
    return _parsePledgeFromJson(data);
  }

  @override
  Future<PledgeModel> updatePledgeStatus(String pledgeId, PledgeStatus status, {DateTime? releaseDate}) async {
    final dynamic data = await _api.put(
      '${ApiEndpoints.loans}/pledges/$pledgeId/status',
      body: {
        'status': status.name,
        'release_date': releaseDate?.toIso8601String(),
      },
    );
    return _parsePledgeFromJson(data);
  }

  List<PledgeModel> _parsePledgesFromJson(List data) {
    return data.map((json) => _parsePledgeFromJson(json as Map<String, dynamic>)).toList();
  }

  PledgeModel _parsePledgeFromJson(Map<String, dynamic> json) {
    return PledgeModel(
      id: json['id'] as String,
      loanId: json['loan_id'] as String? ?? '',
      customerId: json['customer_id'] as String? ?? '',
      customerName: json['customer_name'] as String? ?? 'Customer',
      ornaments: const [],
      pledgeDate: DateTime.tryParse(json['pledge_date'] as String? ?? '') ?? DateTime.now(),
      branch: json['branch'] as String? ?? 'Main Branch',
      totalValuation: (json['total_valuation'] as num?)?.toDouble() ?? 0.0,
      status: PledgeStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PledgeStatus.active,
      ),
      releaseDate: json['release_date'] != null
          ? DateTime.tryParse(json['release_date'] as String)
          : null,
      officerName: json['officer_name'] as String? ?? 'Admin',
    );
  }

  Map<String, dynamic> _pledgeToJson(PledgeModel pledge) {
    return {
      'id': pledge.id,
      'customer_id': pledge.customerId,
      'loan_id': pledge.loanId,
      'pledge_date': pledge.pledgeDate.toIso8601String(),
      'status': pledge.status.name,
      'release_date': pledge.releaseDate?.toIso8601String(),
    };
  }
}
