import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:adlease/config/theme.dart';
import 'package:adlease/providers/auth_provider.dart';
import 'package:adlease/widgets/gradient_button.dart';
import 'package:adlease/widgets/custom_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late String _selectedCountry;
  bool _isSaving = false;

  final List<String> _countries = [
    'Kenya', 'Nigeria', 'South Africa', 'Ghana', 'Tanzania',
    'Uganda', 'Rwanda', 'Ethiopia', 'Egypt', 'Morocco',
    'Senegal', 'Cameroon', 'Other',
  ];

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameController = TextEditingController(text: user?.fullName ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    _selectedCountry = user?.country ?? 'Kenya';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final auth = context.read<AuthProvider>();
    if (auth.user != null) {
      final updatedUser = auth.user!.copyWith(
        fullName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        country: _selectedCountry,
      );
      await auth.updateUser(updatedUser);
    }

    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: AdLeaseTheme.successGreen,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Consumer<AuthProvider>(
                  builder: (_, auth, __) {
                    return CircleAvatar(
                      radius: 50,
                      backgroundColor: AdLeaseTheme.primaryBlue,
                      child: Text(
                        auth.user?.fullName.isNotEmpty == true
                            ? auth.user!.fullName[0].toUpperCase()
                            : 'U',
                        style: GoogleFonts.poppins(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Consumer<AuthProvider>(
                  builder: (_, auth, __) {
                    return TextFormField(
                      initialValue: auth.user?.email ?? '',
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCountry,
                  decoration: const InputDecoration(
                    labelText: 'Country',
                    prefixIcon: Icon(Icons.public),
                  ),
                  items: _countries.map((country) {
                    return DropdownMenuItem(
                      value: country,
                      child: Text(country),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedCountry = value!);
                  },
                ),
                const SizedBox(height: 32),
                GradientButton(
                  text: 'Save Changes',
                  isLoading: _isSaving,
                  onPressed: _saveProfile,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
