import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:adlease/config/theme.dart';
import 'package:adlease/providers/auth_provider.dart';
import 'package:adlease/providers/ownership_provider.dart';
import 'package:adlease/models/phone_model.dart';
import 'package:adlease/widgets/gradient_button.dart';

class SelectPhoneScreen extends StatelessWidget {
  const SelectPhoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select Phone',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<OwnershipProvider>(
        builder: (_, ownership, __) {
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: ownership.availablePhones.length,
            itemBuilder: (context, index) {
              return _buildPhoneCard(
                context,
                ownership.availablePhones[index],
                isDark,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPhoneCard(
    BuildContext context,
    PhoneModel phone,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AdLeaseTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.phone_android,
                  size: 35,
                  color: AdLeaseTheme.primaryBlue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      phone.fullName,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      phone.description,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: phone.specs.entries.map((entry) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${entry.key}: ${entry.value}',
                  style: GoogleFonts.poppins(fontSize: 11),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Price',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    '\$${phone.price.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AdLeaseTheme.primaryBlue,
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: 150,
                child: GradientButton(
                  text: 'Select',
                  onPressed: () => _selectPhone(context, phone),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _selectPhone(BuildContext context, PhoneModel phone) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Confirm Selection',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Start your ownership journey for ${phone.fullName} at \$${phone.price.toStringAsFixed(0)}?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final user = context.read<AuthProvider>().user;
              if (user != null) {
                final success = await context
                    .read<OwnershipProvider>()
                    .selectPhone(user.uid, phone);
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${phone.fullName} selected!'),
                      backgroundColor: AdLeaseTheme.successGreen,
                    ),
                  );
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
