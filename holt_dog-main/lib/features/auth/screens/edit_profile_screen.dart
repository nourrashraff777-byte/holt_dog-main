import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:holt_dog/core/routes/app_router.dart';
import 'package:holt_dog/features/donation/screens/e_wallet_screen.dart';
import 'package:holt_dog/features/user_side/user_home/screens/user_home_screen.dart';

// ==========================================
// EDIT PROFILE SCREEN
// ==========================================
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF4A148C);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                ClipPath(
                    clipper: HeaderClipper(),
                    child: Container(
                        height: 180, width: double.infinity, color: primary)),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                            backgroundColor: Colors.white,
                            child: IconButton(
                                icon: const Icon(Icons.arrow_back_ios_new,
                                    color: primary, size: 18),
                                onPressed: () => Navigator.pop(context))),
                        const Text('Edit Profile',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: -40,
                  child: Stack(
                    children: [
                      CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[300],
                          child: const Icon(Icons.person,
                              size: 60, color: Colors.white)),
                      const Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                              radius: 18,
                              backgroundColor: primary,
                              child: Icon(Icons.camera_alt,
                                  size: 16, color: Colors.white))),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 70),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  _buildField('Username', Icons.alternate_email),
                  _buildField('Full Name', Icons.person_outline),
                  _buildField('Email', Icons.email_outlined),
                  _buildField('Password', Icons.lock_outline, isPassword: true),
                  _buildField('Phone Number', Icons.phone_outlined),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30))),
                      onPressed: () {},
                      child: const Text('Save Changes',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, IconData icon, {bool isPassword = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)]),
      child: TextFormField(
        obscureText: isPassword && _obscurePassword,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF4A148C)),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(_obscurePassword
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword))
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}
