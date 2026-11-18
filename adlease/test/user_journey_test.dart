import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adlease/providers/ad_provider.dart';
import 'package:adlease/providers/auth_provider.dart';
import 'package:adlease/providers/ownership_provider.dart';
import 'package:adlease/providers/wallet_provider.dart';
import 'package:adlease/services/ad_reward_service.dart';
import 'package:adlease/services/ad_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test(
    'signup, profile, signout, login, phone, ad reward and wallet journey',
    () async {
    final auth = AuthProvider();

    expect(
      await auth.signUp(
        email: 'journey@example.com',
        password: 'Password123!',
        fullName: 'Journey User',
        phoneNumber: '+254700000000',
        country: 'Kenya',
      ),
      isTrue,
    );
    final uid = auth.user!.uid;

    await auth.updateUser(
      auth.user!.copyWith(fullName: 'Journey Updated'),
    );
    expect(auth.user?.fullName, 'Journey Updated');

    await auth.signOut();
    expect(auth.isAuthenticated, isFalse);
    expect(
      await auth.signIn(email: 'journey@example.com', password: 'wrong'),
      isFalse,
    );
    expect(auth.isAuthenticated, isFalse);
    expect(
      await auth.signIn(
        email: 'journey@example.com',
        password: 'Password123!',
      ),
      isTrue,
    );
    expect(auth.user?.uid, uid);

    final ownership = OwnershipProvider();
    await ownership.loadOwnership(uid);
    expect(ownership.availablePhones, isNotEmpty);
    expect(await ownership.selectPhone(uid, ownership.availablePhones.first), isTrue);
    expect(ownership.hasActiveOwnership, isTrue);

    final reward = await AdRewardService().claim(
      userId: uid,
      adId: 'journey-ad-001',
      deviceId: auth.user!.deviceId,
    );
    expect(reward.outcome, AdRewardOutcome.credited);

    await ownership.loadOwnership(uid);
    expect(ownership.currentOwnership?.amountPaid, AdService.rewardPerAd);

    final ads = AdProvider();
    await ads.loadAds(uid);
    expect(ads.adsWatchedToday, 1);
    expect(ads.adsRemainingToday, AdService.maxAdsPerDay - 1);
    expect(ads.availableAds, isNotEmpty);

    final wallet = WalletProvider();
    await wallet.loadWallet(uid);
    expect(wallet.balance, 0);
    expect(wallet.transactions, isEmpty);
  });

  test(
    'duplicate signup is rejected and wrong password cannot authenticate',
    () async {
    final auth = AuthProvider();
    expect(
      await auth.signUp(
        email: 'duplicate@example.com',
        password: 'Password123!',
        fullName: 'First',
        phoneNumber: '+254700000001',
        country: 'Kenya',
      ),
      isTrue,
    );
    await auth.signOut();

    expect(
      await auth.signUp(
        email: 'duplicate@example.com',
        password: 'AnotherPassword!',
        fullName: 'Duplicate',
        phoneNumber: '+254700000002',
        country: 'Kenya',
      ),
      isFalse,
    );
    expect(auth.error, contains('already exists'));
    expect(
      await auth.signIn(email: 'duplicate@example.com', password: 'wrong'),
      isFalse,
    );
    expect(auth.isAuthenticated, isFalse);
    expect(
      await auth.signIn(
        email: 'duplicate@example.com',
        password: 'Password123!',
      ),
      isTrue,
    );
  });

  test('reward without phone credits nothing and does not consume daily cap',
      () async {
    final auth = AuthProvider();
    expect(
      await auth.signUp(
        email: 'no-phone@example.com',
        password: 'Password123!',
        fullName: 'No Phone',
        phoneNumber: '+254700000003',
        country: 'Kenya',
      ),
      isTrue,
    );
    final uid = auth.user!.uid;

    final result = await AdRewardService().claim(
      userId: uid,
      adId: 'no-phone-ad',
      deviceId: '',
    );
    expect(result.outcome, AdRewardOutcome.noActivePhone);
    expect(await AdService().getAdsWatchedToday(uid), 0);
    expect(await AdService().getRemainingAdsToday(uid), AdService.maxAdsPerDay);
  });

  test(
    'reward daily limit blocks the next claim and preserves exact progress',
    () async {
    final auth = AuthProvider();
    expect(
      await auth.signUp(
        email: 'limit@example.com',
        password: 'Password123!',
        fullName: 'Limit User',
        phoneNumber: '+254700000004',
        country: 'Kenya',
      ),
      isTrue,
    );
    final uid = auth.user!.uid;
    final ownership = OwnershipProvider();
    await ownership.loadOwnership(uid);
    expect(await ownership.selectPhone(uid, ownership.availablePhones.first), isTrue);

    final rewards = AdRewardService();
    for (var i = 0; i < AdService.maxAdsPerDay; i++) {
      final result = await rewards.claim(
        userId: uid,
        adId: 'limit-ad-$i',
        deviceId: '',
      );
      expect(result.outcome, AdRewardOutcome.credited);
    }

    final extra = await rewards.claim(
      userId: uid,
      adId: 'limit-ad-extra',
      deviceId: '',
    );
    expect(extra.outcome, AdRewardOutcome.rejected);
    expect(await AdService().getAdsWatchedToday(uid), AdService.maxAdsPerDay);

    await ownership.loadOwnership(uid);
    expect(
      ownership.currentOwnership?.amountPaid,
      AdService.rewardPerAd * AdService.maxAdsPerDay,
    );
  });
}
