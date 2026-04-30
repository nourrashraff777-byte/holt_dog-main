import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'payment_failed_page.dart';
import 'payment_success_page.dart';

class PaymentProcessingScreen extends StatefulWidget {
  static const String routeName = '/paymentProcessing';
  const PaymentProcessingScreen({super.key});

  @override
  State<PaymentProcessingScreen> createState() =>
      _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState extends State<PaymentProcessingScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate a 3-second payment check, then go to success or failed.
    // Replace the random result with your real payment API call.
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      // TODO: Replace with actual result from your payment gateway.
      final bool paymentSuccess = true;
      if (paymentSuccess) {
        context.go(PaymentSuccessScreen.routeName);
      } else {
        context.go(PaymentFailedScreen.routeName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top Curved Header
          ClipPath(
            clipper: HeaderArcClipper(),
            child: Container(
              height: 220,
              width: double.infinity,
              color: const Color(0xFFC23B9B),
              child: const Stack(
                children: [
                  Positioned(
                    top: 40,
                    right: 30,
                    child: Icon(Icons.pets, color: Colors.white, size: 40),
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text(
                        'Payment Processing ...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          // Central Message Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade400),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: const Text(
                  "Please don't close the\napp while we confirm\nyour payment",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF1A237E),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Custom Loading Spinner
          const LoadingSpinner(),

          const Spacer(),

          // Bottom Curved Footer
          ClipPath(
            clipper: FooterWaveClipper(),
            child: Container(
              height: 180,
              width: double.infinity,
              color: const Color(0xFFC23B9B),
              alignment: Alignment.bottomLeft,
              padding: const EdgeInsets.all(30),
              child:
                  const Icon(Icons.favorite, color: Colors.white, size: 50),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom Clippers
// ─────────────────────────────────────────────────────────────────────────────

class HeaderArcClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 60);
    path.arcToPoint(
      Offset(size.width, size.height - 60),
      radius: Radius.elliptical(size.width, 100),
      clockwise: false,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class FooterWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, 40);
    var firstControlPoint = Offset(size.width * 0.4, 0);
    var firstEndPoint = Offset(size.width, size.height);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated Spinner
// ─────────────────────────────────────────────────────────────────────────────

class LoadingSpinner extends StatefulWidget {
  const LoadingSpinner({super.key});

  @override
  State<LoadingSpinner> createState() => _LoadingSpinnerState();
}

class _LoadingSpinnerState extends State<LoadingSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * math.pi,
          child: child,
        );
      },
      child: const Icon(
        Icons.autorenew,
        size: 50,
        color: Colors.black87,
      ),
    );
  }
}