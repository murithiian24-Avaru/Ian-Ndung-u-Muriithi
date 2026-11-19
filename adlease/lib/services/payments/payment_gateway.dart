import 'payment_models.dart';

/// Client-facing contract for a backend payment adapter. Secrets, callbacks,
/// provider verification and ledger mutations remain server-side only.
abstract interface class PaymentGateway {
  String get providerId;
  Future<PaymentIntent> createIntent({
    required int amountMinor,
    required String currency,
    required String purpose,
    required String contractReference,
  });
  Future<PaymentIntent> requestCustomerPayment({
    required String paymentIntentId,
    required String msisdn,
  });
  Future<PaymentIntent> getStatus({required String paymentIntentId});
}
