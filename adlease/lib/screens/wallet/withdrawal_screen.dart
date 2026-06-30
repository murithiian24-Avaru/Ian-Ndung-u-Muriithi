import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:adlease/config/theme.dart';
import 'package:adlease/providers/auth_provider.dart';
import 'package:adlease/providers/wallet_provider.dart';
import 'package:adlease/widgets/gradient_button.dart';
import 'package:adlease/widgets/custom_text_field.dart';

class WithdrawalScreen extends StatefulWidget {
  const WithdrawalScreen({super.key});

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _detailsController = TextEditingController();
  String _paymentMethod = 'M-Pesa';
  bool _isProcessing = false;

  final List<Map<String, dynamic>> _paymentMethods = [
    {'name': 'M-Pesa', 'icon': Icons.phone_android, 'hint': 'Phone number'},
    {'name': 'Bank Transfer', 'icon': Icons.account_balance, 'hint': 'Account number'},
    {'name': 'PayPal', 'icon': Icons.payment, 'hint': 'PayPal email'},
    {'name': 'Airtel Money', 'icon': Icons.phone, 'hint': 'Phone number'},
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _submitWithdrawal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    final success = await context.read<WalletProvider>().requestWithdrawal(
          userId: user.uid,
          amount: double.parse(_amountController.text),
          paymentMethod: _paymentMethod,
          paymentDetails: _detailsController.text.trim(),
        );

    setState(() => _isProcessing = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Withdrawal request submitted successfully!'),
          backgroundColor: AdLeaseTheme.successGreen,
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      final error = context.read<WalletProvider>().error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to process withdrawal'),
          backgroundColor: AdLeaseTheme.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Withdraw',
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer<WalletProvider>(
                  builder: (_, wallet, __) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AdLeaseTheme.primaryBlue.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AdLeaseTheme.primaryBlue.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Available Balance',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            '\$${wallet.balance.toStringAsFixed(2)}',
                            style: GoogleFonts.poppins(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AdLeaseTheme.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                Text(
                  'Payment Method',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ..._paymentMethods.map(
                  (method) => RadioListTile<String>(
                    title: Row(
                      children: [
                        Icon(method['icon'] as IconData, size: 22),
                        const SizedBox(width: 12),
                        Text(
                          method['name'] as String,
                          style: GoogleFonts.poppins(),
                        ),
                      ],
                    ),
                    value: method['name'] as String,
                    groupValue: _paymentMethod,
                    onChanged: (value) {
                      setState(() => _paymentMethod = value!);
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _amountController,
                  label: 'Amount (\$)',
                  hint: 'Enter amount to withdraw',
                  prefixIcon: Icons.attach_money,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Please enter a valid amount';
                    }
                    if (amount < 1) {
                      return 'Minimum withdrawal is \$1.00';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _detailsController,
                  label: 'Payment Details',
                  hint: _paymentMethods
                      .firstWhere((m) => m['name'] == _paymentMethod)['hint'] as String,
                  prefixIcon: Icons.info_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter payment details';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                GradientButton(
                  text: 'Submit Withdrawal',
                  isLoading: _isProcessing,
                  onPressed: _submitWithdrawal,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
