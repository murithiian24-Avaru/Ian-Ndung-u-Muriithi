import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:adlease/config/theme.dart';
import 'package:adlease/providers/theme_provider.dart';
import 'package:adlease/providers/locale_provider.dart';
import 'package:adlease/l10n/app_localizations.dart';
import 'package:adlease/widgets/powered_by_avaru.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
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
          _buildNotificationSettings(context, isDark),
          const SizedBox(height: 24),
          _buildSectionTitle('Security'),
          _buildSecuritySettings(context, isDark),
          const SizedBox(height: 24),
          _buildSectionTitle('About'),
          _buildAboutSection(context, isDark),
          const SizedBox(height: 32),
          const Center(child: PoweredByAvaru()),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context, bool isDark) {
    return _card(
      isDark,
      Consumer<ThemeProvider>(
        builder: (_, themeProvider, __) {
          return SwitchListTile(
            title: Text(
              'Dark Mode',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              themeProvider.isDarkMode
                  ? 'Dark theme enabled'
                  : 'Light theme enabled',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
            ),
            secondary: Icon(
              themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
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
    return _card(
      isDark,
      Consumer<LocaleProvider>(
        builder: (_, localeProvider, __) {
          return RadioGroup<String>(
            groupValue: localeProvider.locale.languageCode,
            onChanged: (value) {
              if (value != null) localeProvider.setLocale(Locale(value));
            },
            child: Column(
              children: [
                RadioListTile<String>(
                  title: Text('English', style: GoogleFonts.poppins()),
                  secondary: const Text('🇺🇸'),
                  value: 'en',
                ),
                RadioListTile<String>(
                  title: Text('Kiswahili', style: GoogleFonts.poppins()),
                  secondary: const Text('🇰🇪'),
                  value: 'sw',
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // AdLease cannot send notifications yet (no notification service is set
  // up), so these switches are shown off and disabled instead of pretending
  // to work.
  Widget _buildNotificationSettings(BuildContext context, bool isDark) {
    final l = AppLocalizations.of(context)!;
    Widget tile(String title, IconData icon, Color color) => SwitchListTile(
      title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
      subtitle: Text(
        l.notAvailableYet,
        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
      ),
      secondary: Icon(icon, color: color),
      value: false,
      onChanged: null,
    );
    return _card(
      isDark,
      Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              l.notificationsNotAvailable,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
            ),
          ),
          tile('Push Notifications', Icons.notifications, AdLeaseTheme.primaryBlue),
          tile('Ad Reminders', Icons.alarm, AdLeaseTheme.accentGold),
          tile('Reward Alerts', Icons.card_giftcard, AdLeaseTheme.successGreen),
        ],
      ),
    );
  }

  /// A row for a feature that is not built yet: visibly disabled, with no
  /// arrow, and labelled "Not available yet".
  Widget _unavailableTile(BuildContext context, IconData icon, String title) {
    return ListTile(
      enabled: false,
      leading: Icon(icon),
      title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
      subtitle: Text(
        AppLocalizations.of(context)!.notAvailableYet,
        style: GoogleFonts.poppins(fontSize: 12),
      ),
    );
  }

  /// A settings card. The transparent Material keeps list-tile tap ripples
  /// visible above the card colour (Flutter warns when a ListTile's nearest
  /// Material is underneath a coloured box).
  Widget _card(bool isDark, Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Padding(padding: const EdgeInsets.all(4), child: child),
      ),
    );
  }

  // Password change, biometric login and two-factor authentication need a
  // real authentication backend, which does not exist yet.
  Widget _buildSecuritySettings(BuildContext context, bool isDark) {
    return _card(
      isDark,
      Column(
        children: [
          _unavailableTile(context, Icons.lock, 'Change Password'),
          _unavailableTile(context, Icons.fingerprint, 'Biometric Login'),
          _unavailableTile(
            context,
            Icons.verified_user,
            'Two-Factor Authentication',
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context, bool isDark) {
    return _card(
      isDark,
      Column(
        children: [
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final info = snapshot.data;
              final version = info == null
                  ? null
                  : '${info.version} (${info.buildNumber})';
              return ListTile(
                leading: const Icon(Icons.info, color: AdLeaseTheme.primaryBlue),
                title: Text(
                  'About AdLease',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
                subtitle: version == null
                    ? null
                    : Text(
                        'Version $version',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showAbout(context, version),
              );
            },
          ),
          // No AdLease terms or privacy policy have been published yet.
          _unavailableTile(context, Icons.description, 'Terms of Service'),
          _unavailableTile(context, Icons.privacy_tip, 'Privacy Policy'),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context, String? version) {
    final l = AppLocalizations.of(context)!;
    showAboutDialog(
      context: context,
      applicationName: 'AdLease',
      applicationVersion: version,
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: AdLeaseTheme.primaryGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.phone_android, color: Colors.white),
      ),
      applicationLegalese: '© Avaru Tech Company Limited',
      children: [
        const SizedBox(height: 16),
        Text(l.demoVersionNotice, style: GoogleFonts.poppins(fontSize: 13)),
        const SizedBox(height: 16),
        const PoweredByAvaru(),
      ],
    );
  }
}
