import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:adlease/config/routes.dart';
import 'package:adlease/config/theme.dart';
import 'package:adlease/widgets/gradient_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AdLeaseTheme.primaryGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Spacer(flex: 2),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.phone_android,
                    size: 50,
                    color: AdLeaseTheme.primaryBlue,
                  ),
                ).animate().fadeIn(duration: 600.ms).scale(delay: 200.ms),
                const SizedBox(height: 32),
                Text(
                  'Welcome to\nAdLease',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
                const SizedBox(height: 16),
                Text(
                  'The smart way to own your dream phone.\nWatch ads, earn rewards, and own it!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.5,
                  ),
                ).animate().fadeIn(delay: 500.ms),
                const SizedBox(height: 48),
                _buildFeatureRow(
                  Icons.play_circle_outline,
                  'Watch short ads daily',
                ).animate().fadeIn(delay: 700.ms).slideX(begin: -0.2),
                const SizedBox(height: 16),
                _buildFeatureRow(
                  Icons.account_balance_wallet_outlined,
                  'Earn real money rewards',
                ).animate().fadeIn(delay: 800.ms).slideX(begin: -0.2),
                const SizedBox(height: 16),
                _buildFeatureRow(
                  Icons.smartphone,
                  'Own your phone over time',
                ).animate().fadeIn(delay: 900.ms).slideX(begin: -0.2),
                const Spacer(flex: 3),
                GradientButton(
                  text: 'Get Started',
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.register);
                  },
                ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.3),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.login);
                  },
                  child: Text(
                    'Already have an account? Login',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ).animate().fadeIn(delay: 1100.ms),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
