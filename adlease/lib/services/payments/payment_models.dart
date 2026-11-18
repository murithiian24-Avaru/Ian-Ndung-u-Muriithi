enum PaymentStatus { created, pending, succeeded, failed, reversed, refunded, demoDisabled }

class PaymentIntent {
  const PaymentIntent({
    required this.paymentIntentId,
    required this.providerId,
    required this.amountMinor,
    required this.currency,
    required this.purpose,
    required this.status,
  });
  final String paymentIntentId;
  final String providerId;
  final int amountMinor;
  final String currency;
  final String purpose;
  final PaymentStatus status;
}
