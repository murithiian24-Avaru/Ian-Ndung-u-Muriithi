import 'financing_models.dart';

/// Provider-neutral interface. Implementations must call the backend; never
/// trust client-side values as approval, price or proof of payment.
abstract interface class FinancingProvider {
  String get providerId;
  Future<List<FinancingQuote>> getQuotes({required String deviceSku});
  Future<FinancingApplication> submitApplication({
    required String quoteId,
    required String consentVersion,
  });
  Future<FinancingApplication> getApplication({required String applicationId});
  Future<FinancingOffer> getOffer({required String offerId});
  Future<FinancingContractSnapshot> getContract({required String contractId});
}
