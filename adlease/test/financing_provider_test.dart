import 'package:flutter_test/flutter_test.dart';
import 'package:adlease/services/financing/mock_financing_provider.dart';

void main() {
  const provider = MockFinancingProvider();

  test(
    'mock provider identifies itself as demo-only and supplies no live quotes',
    () async {
      expect(provider.providerId, 'mock-demo-only');
      expect(await provider.getQuotes(deviceSku: 'sample-device'), isEmpty);
    },
  );

  test('mock application is explicitly not submitted', () async {
    final application = await provider.submitApplication(
      quoteId: 'quote-demo',
      consentVersion: 'demo-v1',
    );
    expect(application.providerId, 'mock-demo-only');
    expect(application.status, 'demo_not_submitted');
  });

  test('mock provider cannot issue a financing offer or contract', () async {
    await expectLater(
      provider.getOffer(offerId: 'offer-demo'),
      throwsA(isA<StateError>()),
    );
    await expectLater(
      provider.getContract(contractId: 'contract-demo'),
      throwsA(isA<StateError>()),
    );
  });
}
