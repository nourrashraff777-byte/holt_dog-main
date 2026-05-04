import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:holt_dog/core/routes/app_router.dart';
import 'package:holt_dog/features/donation/screens/e_wallet_screen.dart';
import 'package:holt_dog/features/user_side/user_home/screens/user_home_screen.dart';

// ==========================================
// FEEDBACK PAGE
// ==========================================
class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  int _rating = 4;
  final TextEditingController _commentController = TextEditingController();
  final Color primaryColor = const Color(0xFFC73693);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  Positioned(
                    left: 20,
                    top: 20,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back, color: primaryColor),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  const Center(
                    child: Text('Feedback',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Icon(Icons.favorite,
                      size: 80, color: Color(0xFF4A148C)),
                  const Text('Holt_Dog',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A148C))),
                  const Text('Every Stray Deserves a Story',
                      style: TextStyle(fontSize: 12)),
                  const SizedBox(height: 40),
                  const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('How Was Our Service ?',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600))),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        onPressed: () => setState(() => _rating = index + 1),
                        icon: Icon(
                            index < _rating ? Icons.star : Icons.star_border,
                            size: 45,
                            color: const Color(0xFF4A148C)),
                      );
                    }),
                  ),
                  const SizedBox(height: 30),
                  const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Comment',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600))),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _commentController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Type Text Here',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 40),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const FeedbackSuccessPage()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text('Submit Feedback',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// FEEDBACK SUCCESS PAGE
// ==========================================
class FeedbackSuccessPage extends StatelessWidget {
  const FeedbackSuccessPage({super.key});

  // ✅ FIX: changed from instance fields to static const
  static const Color primaryPurple = Color(0xFF4A148C);
  static const Color lightGreen = Color(0xFFE2F9D6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryPurple,
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 8),
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 80),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Submit Successful',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(40),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(60),
                topRight: Radius.circular(60),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🫶', style: TextStyle(fontSize: 50)),
                const SizedBox(height: 20),
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(color: Colors.black, fontSize: 22),
                    children: [
                      TextSpan(
                          text: 'Thank you! ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: 'for your feedback'),
                    ],
                  ),
                ),
                // const SizedBox(height: 40),
                // ConstrainedBox(
                //   constraints: const BoxConstraints(maxWidth: 300),
                //   child: SizedBox(
                //     width: double.infinity,
                //     height: 55,
                //     child: OutlinedButton(
                //       onPressed: () {
                //         context.push(DoctorHomeScreen.routeName);
                //       },
                //       style: OutlinedButton.styleFrom(
                //         backgroundColor: lightGreen,
                //         side: const BorderSide(color: Colors.black, width: 2.5),
                //         shape: RoundedRectangleBorder(
                //             borderRadius: BorderRadius.circular(30)),
                //         elevation: 4,
                //         shadowColor: Colors.black54,
                //       ),
                //       child: const Text(
                //         'Go Home',
                //         style: TextStyle(
                //             color: Colors.black,
                //             fontSize: 20,
                //             fontWeight: FontWeight.bold),
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
