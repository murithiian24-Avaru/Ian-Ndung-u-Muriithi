import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:adlease/config/routes.dart';
import 'package:adlease/config/theme.dart';
import 'package:adlease/providers/auth_provider.dart';
import 'package:adlease/providers/ownership_provider.dart';
import 'package:adlease/screens/settings/settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildProfileHeader(context, isDark),
              const SizedBox(height: 24),
              _buildProfileInfo(context, isDark),
              const SizedBox(height: 16),
              _buildMenuItems(context, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, bool isDark) {
    return Consumer<AuthProvider>(
      builder: (_, auth, __) {
        final user = auth.user;
        if (user == null) return const SizedBox.shrink();

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: isDark
                ? AdLeaseTheme.darkGradient
                : AdLeaseTheme.primaryGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 45,
                backgroundColor: Colors.white,
                child: Text(
                  user.fullName.isNotEmpty
                      ? user.fullName[0].toUpperCase()
                      : 'U',
                  style: GoogleFonts.poppins(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AdLeaseTheme.primaryBlue,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user.fullName,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                user.email,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  user.isVerified ? 'Verified' : 'Unverified',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileInfo(BuildContext context, bool isDark) {
    return Consumer2<AuthProvider, OwnershipProvider>(
      builder: (_, auth, ownership, __) {
        final user = auth.user;
        if (user == null) return const SizedBox.shrink();

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            children: [
              _buildInfoRow(Icons.phone, 'Phone', user.phoneNumber),
              const Divider(height: 24),
              _buildInfoRow(Icons.public, 'Country', user.country),
              const Divider(height: 24),
              _buildInfoRow(
                Icons.phone_android,
                'Phone Linked',
                ownership.currentOwnership?.phoneName ?? 'None',
              ),
              const Divider(height: 24),
              _buildInfoRow(
                Icons.trending_up,
                'Ownership Status',
                ownership.hasActiveOwnership
                    ? '${ownership.progressPercentage.toStringAsFixed(1)}%'
                    : 'No active plan',
              ),
              const Divider(height: 24),
              _buildInfoRow(
                Icons.card_giftcard,
                'Referral Code',
                user.referralCode,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AdLeaseTheme.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AdLeaseTheme.primaryBlue, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItems(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(
            Icons.edit,
            'Edit Profile',
            () => Navigator.pushNamed(context, AppRoutes.editProfile),
          ),
          _buildMenuItem(
            Icons.people,
            'Referral Program',
            () => Navigator.pushNamed(context, AppRoutes.referral),
          ),
          _buildMenuItem(
            Icons.settings,
            'Settings',
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SettingsScreen(),
              ),
            ),
          ),
          _buildMenuItem(
            Icons.logout,
            'Logout',
            () => _showLogoutDialog(context),
            color: AdLeaseTheme.errorRed,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AdLeaseTheme.primaryBlue),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: color ?? Colors.grey,
      ),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Logout',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<AuthProvider>().signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.welcome,
                  (route) => false,
                );
              }
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: AdLeaseTheme.errorRed),
            ),
          ),
        ],
      ),
    );
  }
}
