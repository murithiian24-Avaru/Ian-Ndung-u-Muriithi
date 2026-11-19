import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:adlease/config/theme.dart';

/// Legacy route retained for navigation compatibility. No sample catalogue
/// selection can create a financing application or ownership record.
class SelectPhoneScreen extends StatelessWidget {
  const SelectPhoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Device options', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 24),
            const Icon(Icons.phone_android, size: 64, color: AdLeaseTheme.primaryBlue),
            const SizedBox(height: 16),
            Text('Device catalogue is being prepared', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('A device can only be selected after an approved financing partner supplies a valid quote and the customer reviews the full terms. No application is submitted here.', textAlign: TextAlign.center, style: GoogleFonts.poppins(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.phone_android, size: 64, color: AdLeaseTheme.primaryBlue),
              const SizedBox(height: 16),
              Text('Device catalogue is being prepared', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text('A device can only be selected after an approved financing partner supplies a valid quote and the customer reviews the full terms. No application is submitted here.', textAlign: TextAlign.center, style: GoogleFonts.poppins(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
