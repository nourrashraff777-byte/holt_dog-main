import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes/app_router.dart';

class PaymentSuccessScreen extends StatelessWidget {
  static const String routeName = '/paymentSuccess';
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF42217A),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: Column(
            children: [
              // ── Top Purple Section ──────────────────────────────────────
              Expanded(
                flex: 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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

              // ── Bottom White Card ───────────────────────────────────────
              Expanded(
                flex: 4,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32.0, vertical: 24.0),
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
                      const Text(
                        '🤲💖',
                        style: TextStyle(fontSize: 45),
                      ),
                      const Text(
                        'Your donation made a difference.',
                        style: TextStyle(
                          fontSize: 16,
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

                      // ── Go Home button ──────────────────────────────────
                      ElevatedButton(
                        onPressed: () {
                          // Clear the entire back-stack and go to user home
                          context.go(AppRouter.userHome);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFFE4F9D4), // light green
                          elevation: 0,
                          side: const BorderSide(
                              color: Colors.black, width: 2.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 18),
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