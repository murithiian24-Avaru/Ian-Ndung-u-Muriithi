import 'payment_gateway.dart';
import 'payment_models.dart';

/// No-money mock. It never creates a payable intent, requests a PIN or marks
/// a transaction successful. Daraja sandbox integration is a separate gate.
class MockPaymentGateway implements PaymentGateway {
  const MockPaymentGateway();
  @override
  String get providerId => 'mock-disabled';

  @override
  Future<PaymentIntent> createIntent({
    required int amountMinor,
    required String currency,
    required String purpose,
    required String contractReference,
  }) async => throw StateError('Payment collection is disabled.');

  @override
  Future<PaymentIntent> requestCustomerPayment({
    required String paymentIntentId,
    required String msisdn,
  }) async => throw StateError('Payment collection is disabled.');

  @override
  Future<PaymentIntent> getStatus({required String paymentIntentId}) async =>
      PaymentIntent(
        paymentIntentId: paymentIntentId,
        providerId: providerId,
        amountMinor: 0,
        currency: 'KES',
        purpose: 'demo_only',
        status: PaymentStatus.demoDisabled,
      );
}
