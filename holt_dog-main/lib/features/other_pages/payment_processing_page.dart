import 'package:flutter/material.dart';
import 'dart:math' as math;


class PaymentProcessingScreen extends StatelessWidget {
  const PaymentProcessingScreen({super.key});

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
              color: const Color(0xFFC23B9B), // Pinkish-Purple
              child: const Stack(
                children: [
                  Positioned(
                    top: 40,
                    right: 30,
                    child: Icon(Icons.pets, color: Colors.white, size: 40), // Fixed: Using standard pets icon
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text(
                        "Payment Processing ...",
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
                      color: Colors.black.withValues(alpha:0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: const Text(
                  "Please don't close the\napp while we confirm\nyour payment",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF1A237E), // Deep Blue
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
              child: const Icon(Icons.favorite, color: Colors.white, size: 50),
            ),
          ),
        ],
      ),
    );
  }
}

// --- CUSTOM CLIPPERS ---

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
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// --- ANIMATED SPINNER ---

class LoadingSpinner extends StatefulWidget {
  const LoadingSpinner({super.key});

  @override
  State<LoadingSpinner> createState() => _LoadingSpinnerState();
}

class _LoadingSpinnerState extends State<LoadingSpinner> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
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
        Icons.autorenew, // Standard material icon for loading
        size: 50,
        color: Colors.black87,
      ),
    );
  }
}