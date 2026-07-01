import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:adlease/config/theme.dart';
import 'package:adlease/providers/theme_provider.dart';
import 'package:adlease/providers/locale_provider.dart';


class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionTitle('Appearance'),
          _buildThemeToggle(context, isDark),
          const SizedBox(height: 24),
          _buildSectionTitle('Language'),
          _buildLanguageSelector(context, isDark),
          const SizedBox(height: 24),
          _buildSectionTitle('Notifications'),
          _buildNotificationSettings(isDark),
          const SizedBox(height: 24),
          _buildSectionTitle('Security'),
          _buildSecuritySettings(context, isDark),
          const SizedBox(height: 24),
          _buildSectionTitle('About'),
          _buildAboutSection(isDark),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
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
      child: Consumer<ThemeProvider>(
        builder: (_, themeProvider, __) {
          return SwitchListTile(
            title: Text(
              'Dark Mode',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              themeProvider.isDarkMode ? 'Dark theme enabled' : 'Light theme enabled',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
            ),
            secondary: Icon(
              themeProvider.isDarkMode
                  ? Icons.dark_mode
                  : Icons.light_mode,
              color: AdLeaseTheme.primaryBlue,
            ),
            value: themeProvider.isDarkMode,
            onChanged: (value) => themeProvider.setDarkMode(value),
          );
        },
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
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
      child: Consumer<LocaleProvider>(
        builder: (_, localeProvider, __) {
          return Column(
            children: [
              RadioListTile<String>(
                title: Text('English', style: GoogleFonts.poppins()),
                secondary: const Text('🇺🇸'),
                value: 'en',
                groupValue: localeProvider.locale.languageCode,
                onChanged: (value) {
                  localeProvider.setLocale(const Locale('en'));
                },
              ),
              RadioListTile<String>(
                title: Text('Kiswahili', style: GoogleFonts.poppins()),
                secondary: const Text('🇰🇪'),
                value: 'sw',
                groupValue: localeProvider.locale.languageCode,
                onChanged: (value) {
                  localeProvider.setLocale(const Locale('sw'));
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotificationSettings(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
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
          SwitchListTile(
            title: Text(
              'Push Notifications',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            secondary: const Icon(Icons.notifications, color: AdLeaseTheme.primaryBlue),
            value: true,
            onChanged: (_) {},
          ),
          SwitchListTile(
            title: Text(
              'Ad Reminders',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            secondary: const Icon(Icons.alarm, color: AdLeaseTheme.accentGold),
            value: true,
            onChanged: (_) {},
          ),
          SwitchListTile(
            title: Text(
              'Reward Alerts',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            secondary: const Icon(Icons.card_giftcard, color: AdLeaseTheme.successGreen),
            value: true,
            onChanged: (_) {},
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySettings(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
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
          ListTile(
            leading: const Icon(Icons.lock, color: AdLeaseTheme.primaryBlue),
            title: Text(
              'Change Password',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.fingerprint, color: AdLeaseTheme.primaryBlue),
            title: Text(
              'Biometric Login',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.verified_user, color: AdLeaseTheme.primaryBlue),
            title: Text(
              'Two-Factor Authentication',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
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
          ListTile(
            leading: const Icon(Icons.info, color: AdLeaseTheme.primaryBlue),
            title: Text(
              'About AdLease',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              'Version 1.0.0',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.description, color: AdLeaseTheme.primaryBlue),
            title: Text(
              'Terms of Service',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip, color: AdLeaseTheme.primaryBlue),
            title: Text(
              'Privacy Policy',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
