import 'package:flutter/material.dart';


class PaymentFailedScreen extends StatelessWidget {
  const PaymentFailedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Determine screen width to handle the curved header gracefully on web/mobile
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF6A0DAD), // Deep purple background
      body: Center(
        child: ConstrainedBox(
          // Restrict width for web to maintain the mobile layout look
          constraints: const BoxConstraints(maxWidth: 450),
          child: Stack(
            children: [
              // White curved header at the top
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 220,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.elliptical(
                        screenWidth > 450 ? 450 : screenWidth, 
                        120,
                      ),
                    ),
                  ),
                ),
              ),
              
              // Main content
              SafeArea(
                child: Column(
                  children: [
                    // Back button
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16.0, top: 16.0),
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new, 
                              color: Colors.white, 
                              size: 18,
                            ),
                            onPressed: () {
                              // Handle back action
                            },
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 10),
                    
                    // Header Text
                    const Text(
                      'Oops!',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Georgia', // Using a serif font to match the image
                        color: Colors.black,
                      ),
                    ),
                    
                    const Spacer(flex: 2),
                    
                    // Center Image 
                    // Note: Replace the Container below with your actual asset:
                    // Image.asset('assets/crying_dog.png', height: 150)
                    Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text(
                          '🐶', 
                          style: TextStyle(fontSize: 80),
                        ),
                      ),
                    ),
                    
                    const Spacer(flex: 1),
                    
                    // Error Message Card
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6D7FF), // Light lilac color
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'Payment Failed\nplease check your\ndetails , and try\nagain',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                    ),
                    
                    const Spacer(flex: 2),
                    
                    // Try Again Button
                    ElevatedButton(
                      onPressed: () {
                        // Handle try again action
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD9D9D9), // Light grey button
                        foregroundColor: Colors.black,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        'Try Again',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                    const Spacer(flex: 1),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}