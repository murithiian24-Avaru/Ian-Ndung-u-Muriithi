import 'financing_models.dart';
import 'financing_provider.dart';

/// Deterministic mock for UI and contract-shape tests only. It has no lender,
/// credit decision, payment flow, real catalogue or binding commercial terms.
class MockFinancingProvider implements FinancingProvider {
  const MockFinancingProvider();
  @override
  String get providerId => 'mock-demo-only';

  @override
  Future<List<FinancingQuote>> getQuotes({required String deviceSku}) async =>
      const [];

  @override
  Future<FinancingApplication> submitApplication({
    required String quoteId,
    required String consentVersion,
  }) async => const FinancingApplication(
    applicationId: 'mock-application',
    providerId: 'mock-demo-only',
    status: 'demo_not_submitted',
  );

  @override
  Future<FinancingApplication> getApplication({
    required String applicationId,
  }) async => FinancingApplication(
    applicationId: applicationId,
    providerId: providerId,
    status: 'demo_not_submitted',
  );

  @override
  Future<FinancingOffer> getOffer({required String offerId}) => Future.error(
    StateError('Mock provider does not issue financing offers.'),
  );

  @override
  Future<FinancingContractSnapshot> getContract({required String contractId}) =>
      Future.error(
        StateError('Mock provider does not create financing contracts.'),
      );
}
