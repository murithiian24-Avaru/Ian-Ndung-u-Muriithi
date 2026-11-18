import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:adlease/config/features.dart';
import 'package:adlease/config/theme.dart';

/// Advertising is intentionally unavailable until policy, privacy and QA review.
/// This screen contains no simulated viewing flow and no reward/claim action.
class AdsScreen extends StatelessWidget {
  const AdsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Advertising', style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('AdLease may display clearly identified advertisements in a future release.', style: GoogleFonts.poppins(color: Colors.grey)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AdLeaseTheme.primaryBlue.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.campaign_outlined, size: 52, color: AdLeaseTheme.primaryBlue),
                  const SizedBox(height: 16),
                  Text('Advertising is not available yet', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(
                    AppFeatures.advertisingEnabled
                      ? 'Advertising availability is controlled by the approved app configuration.'
                      : 'We are completing advertising policy and privacy reviews. You do not need to watch or interact with ads to use AdLease.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Text('Advertisements do not create money, wallet credit, phone credit, discounts or repayment credits.', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
