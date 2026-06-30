import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:adlease/config/routes.dart';
import 'package:adlease/config/theme.dart';
import 'package:adlease/providers/auth_provider.dart';
import 'package:adlease/providers/wallet_provider.dart';
import 'package:adlease/providers/ownership_provider.dart';
import 'package:adlease/providers/ad_provider.dart';
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
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
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, AppRoutes.editProfile),
              child: CircleAvatar(
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
          ],
        );
      },
    );
  }

  Widget _buildBalanceCard(BuildContext context, bool isDark) {
    return Consumer<WalletProvider>(
      builder: (_, wallet, __) {
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
                'AdLease Balance',
                style: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '\$${wallet.balance.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildBalanceStat(
                    'Total Earned',
                    '\$${wallet.wallet?.totalEarnings.toStringAsFixed(2) ?? "0.00"}',
                  ),
                  _buildBalanceStat(
                    'Withdrawn',
                    '\$${wallet.wallet?.totalWithdrawn.toStringAsFixed(2) ?? "0.00"}',
                  ),
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
        final phoneName = ownership.currentOwnership?.phoneName ?? 'No phone selected';
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
              Row(
                children: [
                  CircularPercentIndicator(
                    radius: 50,
                    lineWidth: 10,
                    percent: progress.clamp(0.0, 1.0),
                    center: Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AdLeaseTheme.primaryBlue,
                      ),
                    ),
                    progressColor: AdLeaseTheme.primaryBlue,
                    backgroundColor: AdLeaseTheme.primaryBlue.withValues(alpha: 0.1),
                    circularStrokeCap: CircularStrokeCap.round,
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
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
                        _buildProgressRow('Phone Value', '\$${phonePrice.toStringAsFixed(0)}'),
                        _buildProgressRow('Paid', '\$${amountPaid.toStringAsFixed(2)}'),
                        _buildProgressRow(
                          'Remaining',
                          '\$${(phonePrice - amountPaid).clamp(0, phonePrice).toStringAsFixed(2)}',
                        ),
                      ],
                    ),
                  ),
                ],
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

  Widget _buildStatsGrid(BuildContext context) {
    return Consumer<AdProvider>(
      builder: (_, adProvider, __) {
        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [
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
            Consumer<WalletProvider>(
              builder: (_, wallet, __) => StatsCard(
                title: 'Total Earned',
                value: '\$${wallet.wallet?.totalEarnings.toStringAsFixed(2) ?? "0.00"}',
                icon: Icons.monetization_on,
                color: AdLeaseTheme.warningOrange,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
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
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
