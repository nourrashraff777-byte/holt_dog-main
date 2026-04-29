import 'package:flutter/material.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF42217A), // Deep purple background
      body: Center(
        child: ConstrainedBox(
          // Makes it responsive: looks like a mobile app on desktop web
          constraints: const BoxConstraints(maxWidth: 450), 
          child: Column(
            children: [
              // --- Top Section (Purple) ---
              Expanded(
                flex: 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Custom Checkmark Icon
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 6),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 70,
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Payment Successful',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // --- Bottom Section (White Card) ---
              Expanded(
                flex: 4,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Using emojis to approximate the 3D asset in the image
                      const Text(
                        '🤲💖',
                        style: TextStyle(fontSize: 45),
                      ),
                      
                      const Text(
                        'Your donation made a difference .',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'sans-serif', // Reverting to sans for body text
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontFamily: 'sans-serif',
                          ),
                          children: [
                            TextSpan(
                              text: 'Thank you! ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold, 
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(text: 'for your kindness'),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 10),
                      
                      // Light Green "Go Home" Button
                      ElevatedButton(
                        onPressed: () {
                          // Add navigation logic here
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE4F9D4), // Light pale green
                          elevation: 0, // Removes default drop shadow
                          side: const BorderSide(color: Colors.black, width: 2.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 50, 
                            vertical: 18
                          ),
                        ),
                        child: const Text(
                          'Go Home',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}