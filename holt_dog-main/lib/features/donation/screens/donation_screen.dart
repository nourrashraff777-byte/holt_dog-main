import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:holt_dog/features/donation/screens/add_card_screen.dart';
import 'package:holt_dog/features/donation/screens/e_wallet_screen.dart';
import 'package:holt_dog/features/other_pages/payment_processing_page.dart';
import 'package:holt_dog/paymob_service.dart';
// ← احذف import الـ PaymentProcessingScreen وأضف دول
import 'package:firebase_auth/firebase_auth.dart';
import 'payment_webview_page.dart'; // الملف اللي هنعمله تحت

class DonationOption {
  final String amount;
  final String subtitle;

  DonationOption({required this.amount, required this.subtitle});
}

class DonationScreen extends StatefulWidget {
  // ← StatefulWidget
  static const String routeName = '/donation';
  final bool isBackButtonVisible;
  const DonationScreen({super.key, this.isBackButtonVisible = false});

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  double? _selectedAmount; // ← المبلغ المختار
  final _customAmountController = TextEditingController();
  bool _isLoading = false;

  List<DonationOption> get donationOptions => [
        DonationOption(amount: "150 EGP", subtitle: "Feeds A Dog For One Week"),
        DonationOption(amount: "250 EGP", subtitle: "Basic Medical Checkup"),
        DonationOption(amount: "300 EGP", subtitle: "Emergency Treatment"),
        DonationOption(amount: "500 EGP", subtitle: "Full Rescue Operation"),
      ];

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }

  // ← استخراج الرقم من النص "150 EGP"
  double _parseAmount(String amountStr) {
    return double.parse(amountStr.replaceAll(RegExp(r'[^0-9.]'), ''));
  }

  Future<void> _startPayment() async {
    // تحديد المبلغ النهائي
    double? finalAmount = _selectedAmount;
    if (_customAmountController.text.isNotEmpty) {
      finalAmount = double.tryParse(_customAmountController.text);
    }

    if (finalAmount == null || finalAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select or enter a donation amount')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;

    final paymentUrl = await PaymobService().getPaymentGatewayUri(
      amount: finalAmount,
      email: user?.email ?? 'donor@holtdog.com',
      firstName: user?.displayName?.split(' ').first ?? 'Donor',
      lastName: user?.displayName?.split(' ').last ?? '.',
      phoneNumber: '+201000000000', // لو عندك رقم اليوزر حطه هنا
    );

    setState(() => _isLoading = false);

    if (paymentUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong, please try again'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentWebViewPage(paymentUrl: paymentUrl),
      ),
    );

    if (success == true && mounted) {
      _showSuccessDialog(finalAmount);
    }
  }

  void _showSuccessDialog(double amount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Thank You! 🎉', textAlign: TextAlign.center),
        content: Text(
          'Your donation of ${amount.toInt()} EGP has been received.\nMay your kindness make a difference! 🐾',
          textAlign: TextAlign.center,
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.pop();
              },
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIntroCard(),
                    const SizedBox(height: 30),
                    const Text("Choose Donation Amount",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 16),
                    _buildResponsiveDonationGrid(), // ← اتغير
                    const SizedBox(height: 24),
                    _buildCustomAmountField(), // ← اتغير
                    const SizedBox(height: 32),
                    const Text("Payment Method",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 16),
                    PaymentMethodButton(
                      icon: Icons.credit_card,
                      label: "Visa / MasterCard",
                      iconColor: Colors.green,
                      onTap: () => context.push(AddCardScreen.routeName),
                    ),
                    const SizedBox(height: 12),
                    PaymentMethodButton(
                      icon: Icons.account_balance_wallet,
                      label: "Smart Wallet",
                      iconColor: Colors.red,
                      onTap: () => context.push(EWalletScreen.routeName),
                    ),
                    const SizedBox(height: 30),
                    _buildSecurityBanner(),
                    const SizedBox(height: 30),
                    Center(
                      child: SizedBox(
                        width: 250,
                        child: ElevatedButton(
                          onPressed:
                              _isLoading ? null : _startPayment, // ← اتغير
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE0E0F8),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.indigo,
                                  ),
                                )
                              : const Text(
                                  "Donate Now",
                                  style: TextStyle(
                                    color: Colors.indigo,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI Helpers (نفس بتاعتك + تعديل بسيط) ---

  Widget _buildHeroSection(BuildContext context) {
    return Stack(children: [
      Container(
        height: 300,
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
                'https://images.unsplash.com/photo-1548199973-03cce0bbc87b?q=80&w=2069&auto=format&fit=crop'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black.withValues(alpha: 0.3), Colors.transparent],
            ),
          ),
        ),
      ),
      widget.isBackButtonVisible
          ? Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6.0, vertical: 40),
              child: IconButton(
                onPressed: () => context.pop(),
                icon: Icon(Icons.arrow_back_ios_new,
                    size: 20.sp, color: Colors.white),
              ),
            )
          : const SizedBox.shrink(),
    ]);
  }

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Text(
        "Every small act of kindness can create a big change. "
        "Your donation no matter how small can bring hope, provide essentials, "
        "and transform lives. Give today. Change a life forever. 💙",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
      ),
    );
  }

  Widget _buildResponsiveDonationGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: donationOptions.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.5,
          ),
          itemBuilder: (context, index) {
            final option = donationOptions[index];
            final amount = _parseAmount(option.amount);
            return DonationItem(
              option: option,
              isSelected: _selectedAmount == amount, // ← هايلايت المختار
              onTap: () {
                setState(() {
                  _selectedAmount = amount;
                  _customAmountController.clear(); // ← امسح الـ custom
                });
              },
            );
          },
        );
      },
    );
  }

  Widget _buildCustomAmountField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF0F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.pink.shade100),
      ),
      child: TextField(
        controller: _customAmountController, // ← ربط الـ controller
        onChanged: (_) =>
            setState(() => _selectedAmount = null), // ← امسح الاختيار
        decoration: const InputDecoration(
          labelText: "Custom Amount",
          prefixText: "EGP  ",
          border: InputBorder.none,
          hintText: "Enter Amount",
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }

  Widget _buildSecurityBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Your payment is secure and encrypted. We never store your data.",
              style: TextStyle(fontSize: 12, color: Colors.green.shade800),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Reusable Widgets ---

class DonationItem extends StatelessWidget {
  final DonationOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const DonationItem({
    super.key,
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.shade50 : Colors.transparent,
          border: Border.all(
              color: isSelected ? Colors.green.shade300 : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(option.amount,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(option.subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class PaymentMethodButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final VoidCallback onTap;

  const PaymentMethodButton({
    super.key,
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
