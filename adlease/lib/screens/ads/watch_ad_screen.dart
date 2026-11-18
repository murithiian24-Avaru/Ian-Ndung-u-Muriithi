import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:adlease/config/theme.dart';

/// Legacy route retained so old deep links cannot start a simulated ad/reward.
class WatchAdScreen extends StatelessWidget {
  const WatchAdScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Advertising', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.pause_circle_outline, size: 64, color: AdLeaseTheme.primaryBlue),
              const SizedBox(height: 16),
              Text('Ad viewing is currently unavailable', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text('No reward is offered for advertising activity. You can continue using the rest of AdLease.', textAlign: TextAlign.center, style: GoogleFonts.poppins(color: Colors.grey)),
              const SizedBox(height: 24),
              OutlinedButton(onPressed: () => Navigator.of(context).maybePop(), child: const Text('Go back')),
            ],
          ),
        ),
      ),
    );
  }
}
