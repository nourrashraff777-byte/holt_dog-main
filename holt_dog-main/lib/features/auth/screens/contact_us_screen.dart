import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:holt_dog/core/routes/app_router.dart';
import 'package:holt_dog/features/donation/screens/e_wallet_screen.dart';
import 'package:holt_dog/features/user_side/user_home/screens/user_home_screen.dart';

// ==========================================
// CONTACT US SCREEN
// ==========================================
class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFFC02A95);
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
              bottom: 0,
              right: 0,
              child: ClipPath(
                  clipper: BottomRightClipper(),
                  child: Container(width: 150, height: 150, color: primary))),
          SingleChildScrollView(
            child: Column(
              children: [
                ClipPath(
                    clipper: TopDiagonalClipper(),
                    child: Container(
                        height: 200,
                        width: double.infinity,
                        color: primary,
                        child: const Center(
                            child: Icon(Icons.mail_outline,
                                size: 50, color: Colors.white)))),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context)),
                      const Text('Contact Us',
                          style: TextStyle(
                              fontSize: 26, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      _field('Name'),
                      _field('Email'),
                      _field('Message', lines: 4),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ThankYouPage()));
                        },
                        child: const Text('Submit'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(String hint, {int lines = 1}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
      child: TextField(
          maxLines: lines,
          decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(12))),
    );
  }
}

class TopDiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height * 0.4);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(old) => false;
}

class BottomRightClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(old) => false;
}


// ==========================================
// THANK YOU PAGE (Contact Us)
// ==========================================
class ThankYouPage extends StatelessWidget {
  const ThankYouPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFC73693);
    return const Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.pets,
                  size: 100,
                  color: Colors.white,
                ),
                SizedBox(height: 40),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  children: [
                    Text(
                      'Thank You !',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(Icons.favorite, color: Colors.white, size: 28),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  'We Received Your Message\nAnd We Will Contact To You\nSoon !',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 60),
                // ConstrainedBox(
                //   constraints: const BoxConstraints(maxWidth: 320),
                //   child: SizedBox(
                //     width: double.infinity,
                //     height: 56,
                //     child: ElevatedButton(
                //       onPressed: () {
                //         context.push(BaseScreen.routeName);
                //       },
                //       style: ElevatedButton.styleFrom(
                //         backgroundColor: Colors.white,
                //         foregroundColor: Colors.black,
                //         elevation: 0,
                //         shape: RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(12),
                //         ),
                //       ),
                //       child: const Text(
                //         'Go Home',
                //         style: TextStyle(
                //           fontSize: 18,
                //           fontWeight: FontWeight.bold,
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}