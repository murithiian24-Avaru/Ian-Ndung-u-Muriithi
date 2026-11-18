/// Partner-neutral financing data contracts. Values are snapshots supplied by
/// a financing partner; this app must not invent credit terms or underwrite.
class FinancingQuote {
  const FinancingQuote({
    required this.quoteId,
    required this.providerId,
    required this.deviceSku,
    required this.cashPriceMinor,
    required this.currency,
    required this.expiresAt,
  });
  final String quoteId;
  final String providerId;
  final String deviceSku;
  final int cashPriceMinor;
  final String currency;
  final DateTime expiresAt;
}

class FinancingApplication {
  const FinancingApplication({required this.applicationId, required this.providerId, required this.status});
  final String applicationId;
  final String providerId;
  final String status;
}

class FinancingOffer {
  const FinancingOffer({
    required this.offerId,
    required this.providerId,
    required this.totalPayableMinor,
    required this.depositMinor,
    required this.installmentMinor,
    required this.installmentCount,
    required this.currency,
    required this.expiresAt,
  });
  final String offerId;
  final String providerId;
  final int totalPayableMinor;
  final int depositMinor;
  final int installmentMinor;
  final int installmentCount;
  final String currency;
  final DateTime expiresAt;
}

class FinancingContractSnapshot {
  const FinancingContractSnapshot({required this.contractId, required this.providerId, required this.status, required this.totalPayableMinor, required this.outstandingMinor, required this.currency});
  final String contractId;
  final String providerId;
  final String status;
  final int totalPayableMinor;
  final int outstandingMinor;
  final String currency;
}
