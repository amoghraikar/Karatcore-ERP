import '../models/loan_model.dart';

abstract class IPledgeRepository {
  Future<PledgeModel?> getPledgeById(String id);
  Future<PledgeModel?> getPledgeByLoanId(String loanId);
  Future<List<PledgeModel>> getPledgesByCustomerId(String customerId);
  Future<PledgeModel> createPledge(PledgeModel pledge);
  Future<PledgeModel> updatePledgeStatus(String pledgeId, PledgeStatus status, {DateTime? releaseDate});
}
