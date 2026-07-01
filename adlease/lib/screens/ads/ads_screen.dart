import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:adlease/config/routes.dart';
import 'package:adlease/config/theme.dart';
import 'package:adlease/providers/ad_provider.dart';
import 'package:adlease/models/ad_model.dart';

class AdsScreen extends StatelessWidget {
  const AdsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Watch Ads',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Earn rewards by watching advertisements',
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              _buildAdStats(context, isDark),
              const SizedBox(height: 24),
              _buildAvailableAds(context, isDark),
              const SizedBox(height: 24),
              _buildViewHistory(context, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdStats(BuildContext context, bool isDark) {
    return Consumer<AdProvider>(
      builder: (_, adProvider, __) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: isDark
                ? AdLeaseTheme.darkGradient
                : AdLeaseTheme.primaryGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn(
                '${adProvider.adsWatchedToday}',
                'Watched\nToday',
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              _buildStatColumn(
                '${adProvider.adsRemainingToday}',
                'Remaining\nToday',
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              _buildStatColumn(
                '\$2.50',
                'Per Ad\nReward',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildAvailableAds(BuildContext context, bool isDark) {
    return Consumer<AdProvider>(
      builder: (_, adProvider, __) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available Ads',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            if (adProvider.canWatchAd)
              ...adProvider.availableAds.take(3).map(
                    (ad) => _buildAdCard(context, ad, isDark),
                  )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.timer_off,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Daily Limit Reached',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Come back tomorrow for more ads!',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildAdCard(BuildContext context, AdModel ad, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AdLeaseTheme.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.play_circle,
              color: AdLeaseTheme.primaryBlue,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ad.title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'by ${ad.advertiserName}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  '${ad.durationSeconds}s • \$${ad.rewardAmount.toStringAsFixed(2)} reward',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AdLeaseTheme.successGreen,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.watchAd),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: AdLeaseTheme.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Watch',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewHistory(BuildContext context, bool isDark) {
    return Consumer<AdProvider>(
      builder: (_, adProvider, __) {
        if (adProvider.viewHistory.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent History',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...adProvider.viewHistory.take(5).map(
                  (record) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E2E) : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          record.completedFully
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: record.completedFully
                              ? AdLeaseTheme.successGreen
                              : AdLeaseTheme.errorRed,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Ad viewed on ${_formatDate(record.viewedAt)}',
                            style: GoogleFonts.poppins(fontSize: 13),
                          ),
                        ),
                        Text(
                          '+\$${record.rewardEarned.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AdLeaseTheme.successGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
