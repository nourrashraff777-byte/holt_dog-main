import 'package:flutter/material.dart';

class EWalletScreen extends StatefulWidget {
  static const String routeName = '/eWalletScreen';
  const EWalletScreen({super.key});

  @override
  State<EWalletScreen> createState() => _EWalletScreenState();
}

class _EWalletScreenState extends State<EWalletScreen> {
  // Track the selected payment method
  String? _selectedMethod;

  // Data for the unified menu
  final List<Map<String, dynamic>> _paymentMethods = [
    {'name': 'Etisalat Cash', 'color': Colors.red, 'icon': 'e&'},
    {'name': 'We Pay', 'color': Colors.deepPurple, 'icon': 'we'},
    {'name': 'Vodafone Cash', 'color': Colors.redAccent, 'icon': 'V'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // --- UNIFIED DROPDOWN MENU ---
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedMethod,
                            hint: const Text("Select Payment Method",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            isExpanded: true,
                            decoration:
                                const InputDecoration(border: InputBorder.none),
                            items: _paymentMethods.map((method) {
                              return DropdownMenuItem<String>(
                                value: method['name'],
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 25,
                                      decoration: BoxDecoration(
                                        color: method['color'],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Center(
                                        child: Text(method['icon'],
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontFamily: 'sans-serif')),
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Text(method['name']),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (val) =>
                                setState(() => _selectedMethod = val),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // --- RESPONSIVE INPUT FIELD ---
                      // Only shows or enables if a method is selected
                      AnimatedOpacity(
                        opacity: _selectedMethod == null ? 0.5 : 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          height: 45,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            border:
                                Border.all(color: Colors.black87, width: 1.5),
                          ),
                          child: TextField(
                            enabled: _selectedMethod != null,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              hintText: _selectedMethod == null
                                  ? 'select a provider first'
                                  : 'enter your ${_selectedMethod ?? ''} number',
                              hintStyle:
                                  const TextStyle(fontStyle: FontStyle.italic),
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  // Reuse the header and footer logic from previous response
  Widget _buildHeader() {
    return ClipPath(
      clipper: HeaderClipper(),
      child: Container(
        height: 230,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient:
              LinearGradient(colors: [Color(0xFFEBC1FF), Color(0xFFC471ED)]),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  },
                  icon:
                      const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Smart Wallet',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        gradient:
            LinearGradient(colors: [Color(0xFF8A2BE2), Color(0xFFB565D6)]),
        borderRadius: BorderRadius.only(
            topLeft: Radius.elliptical(200, 40),
            topRight: Radius.elliptical(200, 40)),
      ),
      child: const Center(
        child: Text('Continue',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height);
    path.quadraticBezierTo(
        size.width * 0.5, size.height - 50, size.width, size.height - 100);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
