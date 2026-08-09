import '../models/loan_model.dart';
import 'pledge_repository.dart';

class MockPledgeRepository implements IPledgeRepository {
  final List<PledgeModel> _pledges = [];

  @override
  Future<PledgeModel?> getPledgeById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _pledges.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<PledgeModel?> getPledgeByLoanId(String loanId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _pledges.firstWhere((p) => p.loanId == loanId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<PledgeModel>> getPledgesByCustomerId(String customerId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _pledges.where((p) => p.customerId == customerId).toList();
  }

  @override
  Future<PledgeModel> createPledge(PledgeModel pledge) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _pledges.insert(0, pledge);
    return pledge;
  }

  @override
  Future<PledgeModel> updatePledgeStatus(String pledgeId, PledgeStatus status, {DateTime? releaseDate}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _pledges.indexWhere((p) => p.id == pledgeId);
    if (index != -1) {
      final existing = _pledges[index];
      final updated = PledgeModel(
        id: existing.id,
        loanId: existing.loanId,
        customerId: existing.customerId,
        customerName: existing.customerName,
        ornaments: existing.ornaments,
        pledgeDate: existing.pledgeDate,
        branch: existing.branch,
        totalValuation: existing.totalValuation,
        status: status,
        releaseDate: releaseDate ?? existing.releaseDate,
        officerName: existing.officerName,
        history: List.from(existing.history)..add('Status updated to ${status.label} on ${DateTime.now()}'),
      );
      _pledges[index] = updated;
      return updated;
    }
    throw Exception('Pledge not found');
  }
}
