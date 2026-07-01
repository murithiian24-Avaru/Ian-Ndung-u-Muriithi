import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:adlease/config/routes.dart';
import 'package:adlease/config/theme.dart';
import 'package:adlease/providers/auth_provider.dart';
import 'package:adlease/providers/theme_provider.dart';
import 'package:adlease/providers/locale_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await Future.wait([
      context.read<ThemeProvider>().loadTheme(),
      context.read<LocaleProvider>().loadLocale(),
      context.read<AuthProvider>().checkAuthState(),
      Future.delayed(const Duration(seconds: 3)),
    ]);

    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    if (auth.isAuthenticated) {
      Navigator.pushReplacementNamed(context, AppRoutes.main);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AdLeaseTheme.primaryGradient,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.phone_android,
                  size: 60,
                  color: AdLeaseTheme.primaryBlue,
                ),
              ),
            )
                .animate()
                .fadeIn(duration: 800.ms)
                .scale(delay: 200.ms, duration: 600.ms),
            const SizedBox(height: 32),
            Text(
              'AdLease',
              style: GoogleFonts.poppins(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            )
                .animate()
                .fadeIn(delay: 400.ms, duration: 800.ms)
                .slideY(begin: 0.3, end: 0),
            const SizedBox(height: 8),
            Text(
              'Watch. Earn. Own.',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w300,
                color: Colors.white.withValues(alpha: 0.9),
                letterSpacing: 4,
              ),
            )
                .animate()
                .fadeIn(delay: 800.ms, duration: 800.ms),
            const SizedBox(height: 60),
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ).animate().fadeIn(delay: 1200.ms, duration: 600.ms),
          ],
        ),
      ),
    );
  }
}
