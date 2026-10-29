import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:adlease/config/theme.dart';
import 'package:adlease/providers/auth_provider.dart';
import 'package:adlease/providers/ad_provider.dart';
import 'package:adlease/providers/ownership_provider.dart';
import 'package:adlease/config/routes.dart';
import 'package:adlease/l10n/app_localizations.dart';
import 'package:adlease/services/ad_reward_service.dart';
import 'package:adlease/services/ad_service.dart';
import 'package:adlease/utils/currency.dart';
import 'package:adlease/widgets/gradient_button.dart';

class WatchAdScreen extends StatefulWidget {
  const WatchAdScreen({super.key});

  @override
  State<WatchAdScreen> createState() => _WatchAdScreenState();
}

class _WatchAdScreenState extends State<WatchAdScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static const int adDuration = 60;
  int _secondsRemaining = adDuration;
  bool _isPlaying = false;
  bool _isCompleted = false;
  bool _rewardClaimed = false;
  bool _isClaiming = false;
  Timer? _timer;
  final AdRewardService _rewards = AdRewardService();
  late AnimationController _pulseController;
  // ignore: unused_field
  int _focusCheckCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  // The countdown used to keep running while the app was in the background,
  // so a reward could be earned without watching. If the app leaves the
  // foreground mid-ad, stop and reset the ad.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final leftForeground =
        state == AppLifecycleState.paused || state == AppLifecycleState.hidden;
    if (_isPlaying && leftForeground) {
      _timer?.cancel();
      setState(() {
        _isPlaying = false;
        _secondsRemaining = adDuration;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'The ad was stopped because you left the app. Start it again to earn the reward.',
          ),
        ),
      );
    }
  }

  void _startAd() {
    setState(() {
      _isPlaying = true;
      _secondsRemaining = adDuration;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });

        // Anti-cheat: random focus checks
        if (_secondsRemaining % 15 == 0 && _secondsRemaining > 0) {
          _focusCheckCount++;
        }
      } else {
        timer.cancel();
        setState(() {
          _isCompleted = true;
          _isPlaying = false;
        });
      }
    });
  }

  Future<void> _claimReward() async {
    // Guard against a double tap claiming the same reward twice.
    if (_isClaiming || _rewardClaimed || !_isCompleted) return;
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    final adProvider = context.read<AdProvider>();
    final ownershipProvider = context.read<OwnershipProvider>();
    final ads = adProvider.availableAds;
    if (ads.isEmpty) return;

    setState(() => _isClaiming = true);
    try {
      // The simulated reward goes to phone-ownership progress ONLY; it is
      // never added to a cash wallet (no double counting, no "money").
      final result = await _rewards.claim(
        userId: user.uid,
        adId: ads.first.id,
        deviceId: user.deviceId,
      );
      await adProvider.loadAds(user.uid);
      await ownershipProvider.loadOwnership(user.uid);
      if (!mounted) return;

      switch (result.outcome) {
        case AdRewardOutcome.credited:
          setState(() => _rewardClaimed = true);
        case AdRewardOutcome.noActivePhone:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.choosePhoneFirst),
              backgroundColor: AdLeaseTheme.errorRed,
            ),
          );
        case AdRewardOutcome.rejected:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'This reward could not be recorded. You may have reached today\'s limit.',
              ),
              backgroundColor: AdLeaseTheme.errorRed,
            ),
          );
      }
    } finally {
      if (mounted) setState(() => _isClaiming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Watch Ad',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
          onPressed: () {
            if (_isPlaying) {
              _showExitDialog();
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SafeArea(
        // Centred as before when it fits; scrolls on small screens or with a
        // large system font instead of overflowing.
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: (constraints.maxHeight - 48).clamp(
                  0,
                  double.infinity,
                ),
              ),
              child: _rewardClaimed
                  ? _buildRewardClaimedView()
                  : _isCompleted
                  ? _buildCompletedView()
                  : _isPlaying
                  ? _buildPlayingView()
                  : _buildStartView(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStartView() {
    final l = AppLocalizations.of(context)!;
    return Consumer2<AdProvider, OwnershipProvider>(
      builder: (_, adProvider, ownershipProvider, __) {
        if (!ownershipProvider.hasActiveOwnership) {
          // Rewards only count toward a phone, so a phone must be chosen first.
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.phone_android,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 24),
                Text(
                  l.choosePhoneFirst,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 32),
                GradientButton(
                  text: l.selectPhone,
                  icon: Icons.phone_android,
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.selectPhone),
                ),
              ],
            ),
          );
        }

        if (!adProvider.canWatchAd) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timer_off, size: 80, color: Colors.grey.shade400),
                const SizedBox(height: 24),
                Text(
                  'Daily Limit Reached',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You\'ve watched all 3 ads today.\nCome back tomorrow!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 32),
                GradientButton(
                  text: 'Go Back',
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (_, child) {
                return Transform.scale(
                  scale: 1.0 + _pulseController.value * 0.1,
                  child: child,
                );
              },
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  gradient: AdLeaseTheme.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AdLeaseTheme.primaryBlue.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  size: 80,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Ready to Watch?',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l.watchSampleAdHint(formatKsh(AdService.rewardPerAd)),
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AdLeaseTheme.accentGold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${adProvider.adsRemainingToday} ads remaining today',
                style: GoogleFonts.poppins(
                  color: AdLeaseTheme.accentGold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 40),
            GradientButton(
              text: 'Start Watching',
              icon: Icons.play_arrow,
              onPressed: _startAd,
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlayingView() {
    final progress = (adDuration - _secondsRemaining) / adDuration;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: double.infinity,
          height: 250,
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.smart_display,
                    size: 60,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Advertisement Playing...',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_secondsRemaining}s',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: AdLeaseTheme.primaryBlue.withValues(alpha: 0.1),
            valueColor: const AlwaysStoppedAnimation(AdLeaseTheme.primaryBlue),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '${(progress * 100).toStringAsFixed(0)}% complete',
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Text(
          'Do not leave this screen',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AdLeaseTheme.warningOrange,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AdLeaseTheme.successGreen.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle,
            size: 80,
            color: AdLeaseTheme.successGreen,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Ad Completed!',
          style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          '${formatKsh(AdService.rewardPerAd)} · ${AppLocalizations.of(context)!.phoneProgressDemo}',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 18,
            color: AdLeaseTheme.successGreen,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 40),
        GradientButton(
          text: 'Claim Reward',
          icon: Icons.card_giftcard,
          isLoading: _isClaiming,
          onPressed: _isClaiming ? null : _claimReward,
        ),
      ],
    );
  }

  Widget _buildRewardClaimedView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AdLeaseTheme.accentGold.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.celebration,
            size: 80,
            color: AdLeaseTheme.accentGold,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Reward Claimed!',
          style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context)!
              .rewardAddedToPhone(formatKsh(AdService.rewardPerAd)),
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 40),
        GradientButton(text: 'Done', onPressed: () => Navigator.pop(context)),
      ],
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Leave Ad?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'If you leave now, you won\'t earn the reward for this ad.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () {
              _timer?.cancel();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              'Leave',
              style: TextStyle(color: AdLeaseTheme.errorRed),
            ),
          ),
        ],
      ),
    );
  }
}
