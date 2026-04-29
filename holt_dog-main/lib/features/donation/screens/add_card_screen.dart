import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddCardScreen extends StatelessWidget {
  static const String routeName = '/addCardScreen';
  const AddCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Custom Curved Header
            Stack(
              children: [
                ClipPath(
                  clipper: HeaderCurveClipper(),
                  child: Container(
                    height: 280,
                    width: double.infinity,
                    color: const Color(0xFF4A148C), // Deep Purple
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 50),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () => context.pop(),
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.white, size: 30),
                            ),
                            const Icon(Icons.pets,
                                color: Colors.white,
                                size: 28), // Dog icon placeholder
                          ],
                        ),
                        const Spacer(),
                        const Text(
                          "Add Card",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ),
                // Decorative Paw Prints
                const Positioned(
                    top: 100,
                    right: 60,
                    child: Icon(Icons.pets, color: Colors.white24, size: 40)),
                const Positioned(
                    top: 180,
                    right: 110,
                    child:
                        Icon(Icons.favorite, color: Colors.white24, size: 35)),
              ],
            ),

            // Responsive Form Content
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                    maxWidth: 500), // Keeps form centered on web
                child: Column(
                  children: [
                    _buildInputField("Card Number", "    /    /    /    "),
                    const SizedBox(height: 20),
                    _buildInputField("Cvv", ""),
                    const SizedBox(height: 20),
                    _buildInputField("Expiration Day", "mm / yy"),
                    const SizedBox(height: 50),

                    // Responsive Confirm Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A148C),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 5,
                        ),
                        child: const Text(
                          "Confirm",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
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
    );
  }

  // Helper to build the styled text fields from the image
  Widget _buildInputField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF9F9F9),
            border: Border.all(color: Colors.grey.shade500, width: 2),
            borderRadius: BorderRadius.circular(15),
          ),
          child: TextField(
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(color: Colors.grey, fontSize: 16),
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 18),
              border: InputBorder.none,
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
          ),
        ),
      ],
    );
  }
}

// Custom Clipper for the wave/curve effect
class HeaderCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 80);

    var firstControlPoint = Offset(size.width / 2, size.height);
    var firstEndPoint = Offset(size.width, size.height - 80);

    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
