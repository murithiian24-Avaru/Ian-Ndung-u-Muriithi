import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:adlease/config/theme.dart';
import 'package:adlease/providers/auth_provider.dart';

/// Product landing page while financing and advertising are not live.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Consumer<AuthProvider>(
              builder: (_, auth, __) {
                final name = auth.user?.fullName ?? 'User';
                final firstName = name.split(' ').first;
                return Text(
                  'Hello, $firstName',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            const SizedBox(height: 6),
            Text(
              'Explore device options and financing information.',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: isDark
                    ? AdLeaseTheme.darkGradient
                    : AdLeaseTheme.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.phone_android,
                    color: Colors.white,
                    size: 36,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'AdLease',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A technology platform being prepared to connect customers with handset financing options from an authorised partner.',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _noticeCard(
              cardColor,
              isDark,
              Icons.account_balance_outlined,
              'Financing is not active',
              'No lender is connected. No credit application, offer, repayment schedule or customer contract is created in this demo.',
            ),
            const SizedBox(height: 12),
            _noticeCard(
              cardColor,
              isDark,
              Icons.campaign_outlined,
              'Advertising is not active',
              'Ads are disabled pending policy and privacy review. Ad interactions never create customer money, phone credit or repayment credits.',
            ),
            const SizedBox(height: 12),
            _noticeCard(
              cardColor,
              isDark,
              Icons.payments_outlined,
              'Payments are not active',
              'No customer funds are collected or held in this demo. Payment integrations remain disabled.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _noticeCard(
    Color cardColor,
    bool isDark,
    IconData icon,
    String title,
    String body,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AdLeaseTheme.primaryBlue.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AdLeaseTheme.primaryBlue, size: 26),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
