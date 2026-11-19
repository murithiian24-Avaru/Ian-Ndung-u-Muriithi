import 'package:flutter_test/flutter_test.dart';
import 'package:adlease/services/payments/mock_payment_gateway.dart';
import 'package:adlease/services/payments/payment_models.dart';

void main() {
  const gateway = MockPaymentGateway();

  test('mock gateway cannot create a payment intent', () async {
    await expectLater(
      gateway.createIntent(
        amountMinor: 1000,
        currency: 'KES',
        purpose: 'repayment',
        contractReference: 'demo-contract',
      ),
      throwsA(isA<StateError>()),
    );
  });

  test('mock gateway cannot request customer payment', () async {
    await expectLater(
      gateway.requestCustomerPayment(
        paymentIntentId: 'demo-intent',
        msisdn: '+254700000000',
      ),
      throwsA(isA<StateError>()),
    );
  });

  test('status lookup cannot represent a successful payment', () async {
    final status = await gateway.getStatus(paymentIntentId: 'demo-intent');
    expect(status.status, PaymentStatus.demoDisabled);
    expect(status.amountMinor, 0);
  });
}
