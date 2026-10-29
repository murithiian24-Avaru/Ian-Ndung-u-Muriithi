import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:adlease/config/features.dart';
import 'package:adlease/config/routes.dart';
import 'package:adlease/config/theme.dart';
import 'package:adlease/providers/auth_provider.dart';
import 'package:adlease/providers/wallet_provider.dart';
import 'package:adlease/providers/ownership_provider.dart';
import 'package:adlease/providers/ad_provider.dart';
import 'package:adlease/l10n/app_localizations.dart';
import 'package:adlease/utils/currency.dart';
import 'package:adlease/widgets/stats_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            final user = context.read<AuthProvider>().user;
            if (user != null) {
              await Future.wait([
                context.read<WalletProvider>().loadWallet(user.uid),
                context.read<OwnershipProvider>().loadOwnership(user.uid),
                context.read<AdProvider>().loadAds(user.uid),
              ]);
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, isDark),
                const SizedBox(height: 24),
                _buildBalanceCard(context, isDark),
                const SizedBox(height: 20),
                _buildOwnershipProgress(context, isDark),
                const SizedBox(height: 20),
                _buildStatsGrid(context),
                const SizedBox(height: 20),
                _buildQuickActions(context, isDark),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Consumer<AuthProvider>(
      builder: (_, auth, __) {
        final name = auth.user?.fullName ?? 'User';
        final firstName = name.split(' ').first;
        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, $firstName! 👋',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Watch. Earn. Own.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Semantics(
              button: true,
              label: 'Edit Profile',
              excludeSemantics: true,
              child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, AppRoutes.editProfile),
              child: CircleAvatar(
                // Tapping the avatar opens Edit Profile.
                radius: 24,
                backgroundColor: AdLeaseTheme.primaryBlue,
                child: Text(
                  firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ),
          ],
        );
      },
    );
  }

  // Shows simulated phone-ownership progress. There is no cash balance:
  // ad rewards count only toward the phone, and withdrawals are hidden.
  Widget _buildBalanceCard(BuildContext context, bool isDark) {
    final l = AppLocalizations.of(context)!;
    return Consumer<OwnershipProvider>(
      builder: (_, ownership, __) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: isDark
                ? AdLeaseTheme.darkGradient
                : AdLeaseTheme.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AdLeaseTheme.primaryBlue.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.phoneProgressDemo,
                style: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  formatKsh(ownership.currentOwnership?.amountPaid ?? 0),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Side by side when they fit, otherwise one above the other
              // (never split mid-word).
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 24,
                runSpacing: 12,
                children: [
                  _buildBalanceStat(
                    l.remaining,
                    formatKsh(ownership.remainingAmount),
                  ),
                  _buildBalanceStat(l.balance, l.notAvailable),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBalanceStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildOwnershipProgress(BuildContext context, bool isDark) {
    return Consumer<OwnershipProvider>(
      builder: (_, ownership, __) {
        final progress = ownership.progressPercentage / 100;
        final phoneName =
            ownership.currentOwnership?.phoneName ?? 'No phone selected';
        final phonePrice = ownership.currentOwnership?.phonePrice ?? 0;
        final amountPaid = ownership.currentOwnership?.amountPaid ?? 0;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ownership Progress',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final textScale =
                      MediaQuery.textScalerOf(context).scale(16) / 16;
                  final indicator = CircularPercentIndicator(
                    radius: 50,
                    lineWidth: 10,
                    percent: progress.clamp(0.0, 1.0),
                    center: Padding(
                      padding: const EdgeInsets.all(14),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '${(progress * 100).toStringAsFixed(0)}%',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AdLeaseTheme.primaryBlue,
                          ),
                        ),
                      ),
                    ),
                    progressColor: AdLeaseTheme.primaryBlue,
                    backgroundColor: AdLeaseTheme.primaryBlue.withValues(
                      alpha: 0.1,
                    ),
                    circularStrokeCap: CircularStrokeCap.round,
                  );
                  final details = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        phoneName,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildProgressRow(
                        'Phone Value',
                        formatKsh(phonePrice, decimals: 0),
                      ),
                      _buildProgressRow('Paid', formatKsh(amountPaid)),
                      _buildProgressRow(
                        'Remaining',
                        formatKsh(
                          (phonePrice - amountPaid).clamp(0, phonePrice),
                        ),
                      ),
                    ],
                  );
                  // Ring (100) + gap (24) beside the details needs room for
                  // about 140 logical pixels of text at the current scale.
                  final sideBySide =
                      constraints.maxWidth - 124 >= 140 * textScale;
                  if (!sideBySide) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(child: indicator),
                        const SizedBox(height: 16),
                        details,
                      ],
                    );
                  }
                  return Row(
                    children: [
                      indicator,
                      const SizedBox(width: 24),
                      Expanded(child: details),
                    ],
                  );
                },
              ),
              if (!ownership.hasActiveOwnership) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.selectPhone);
                    },
                    icon: const Icon(Icons.phone_android),
                    label: const Text('Select a Phone'),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      // Label and value on one line when they fit, otherwise the value
      // moves under the label.
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        spacing: 8,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // The four statistic cards. They used to sit in a GridView with a fixed
  // aspect ratio, which cut their height below what the content needs
  // (visible as "BOTTOM OVERFLOWED BY 20 / 5.3 PIXELS" on phones). Each row
  // now takes the height of its tallest card, and the cards stack in one
  // column when the screen is narrow or the system font is very large.
  Widget _buildStatsGrid(BuildContext context) {
    return Consumer2<AdProvider, OwnershipProvider>(
      builder: (_, adProvider, ownership, __) {
        final cards = <Widget>[
          StatsCard(
            title: 'Ads Watched Today',
            value: '${adProvider.adsWatchedToday}',
            icon: Icons.play_circle,
            color: AdLeaseTheme.primaryBlue,
            subtitle: '${adProvider.adsRemainingToday} remaining',
          ),
          StatsCard(
            title: 'Ads Remaining',
            value: '${adProvider.adsRemainingToday}',
            icon: Icons.timer,
            color: AdLeaseTheme.accentGold,
          ),
          StatsCard(
            title: 'Total Views',
            value: '${adProvider.viewHistory.length}',
            icon: Icons.visibility,
            color: AdLeaseTheme.successGreen,
          ),
          StatsCard(
            title: AppLocalizations.of(context)!.appliedToPhone,
            value: formatKsh(ownership.currentOwnership?.amountPaid ?? 0),
            icon: Icons.monetization_on,
            color: AdLeaseTheme.warningOrange,
          ),
        ];
        return LayoutBuilder(
          builder: (context, constraints) {
            final textScale = MediaQuery.textScalerOf(context).scale(16) / 16;
            final twoColumns = constraints.maxWidth / textScale >= 240;
            if (!twoColumns) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < cards.length; i++) ...[
                    if (i > 0) const SizedBox(height: 12),
                    cards[i],
                  ],
                ],
              );
            }
            return Column(
              children: [
                _buildStatsRow(cards[0], cards[1]),
                const SizedBox(height: 12),
                _buildStatsRow(cards[2], cards[3]),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatsRow(Widget left, Widget right) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: left),
          const SizedBox(width: 12),
          Expanded(child: right),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                'Watch Ad',
                Icons.play_arrow,
                AdLeaseTheme.primaryBlue,
                () => Navigator.pushNamed(context, AppRoutes.watchAd),
                isDark,
              ),
            ),
            if (AppFeatures.withdrawalsEnabled) ...[
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  context,
                  'Withdraw',
                  Icons.account_balance,
                  AdLeaseTheme.successGreen,
                  () => Navigator.pushNamed(context, AppRoutes.withdrawal),
                  isDark,
                ),
              ),
            ],
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                context,
                'Refer',
                Icons.share,
                AdLeaseTheme.accentGold,
                () => Navigator.pushNamed(context, AppRoutes.referral),
                isDark,
              ),
            ),
          ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
    bool isDark,
  ) {
    final cardColor = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
