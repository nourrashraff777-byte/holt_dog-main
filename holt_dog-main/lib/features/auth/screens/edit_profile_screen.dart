import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:holt_dog/core/routes/app_router.dart';
import 'package:holt_dog/core/widgets/header_clipper.dart';
import 'package:holt_dog/features/auth/cubit/auth_cubit.dart';
import 'package:holt_dog/features/auth/cubit/auth_state.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize fields with current user data
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      _nameController.text = authState.user.name;
      _phoneController.text = authState.user.phone;
      _emailController.text = authState.user.email;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().updateProfile(
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF4A148C);
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is Authenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
          Navigator.pop(context); // Go back after successful update
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          body: SingleChildScrollView(
            child: Form(
              key: _formKey,
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
                      // const Positioned(
                      //     bottom: 0,
                      //     right: 0,
                      //     child: CircleAvatar(
                      //         radius: 18,
                      //         backgroundColor: primary,
                      //         child: Icon(Icons.camera_alt,
                      //             size: 16, color: Colors.white))),
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
                  _buildField('Full Name', Icons.person_outline, controller: _nameController),
                  _buildField('Email', Icons.email_outlined, controller: _emailController, readOnly: true),
                  _buildField('Phone Number', Icons.phone_outlined, controller: _phoneController),
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
                      onPressed: isLoading ? null : _handleSave,
                      child: isLoading 
                          ? const SizedBox(
                              height: 20, 
                              width: 20, 
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                            )
                          : const Text('Save Changes',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
},
);
}

  Widget _buildField(String label, IconData icon, {bool isPassword = false, TextEditingController? controller, bool readOnly = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
          color: readOnly ? Colors.grey[200] : Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)]),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && _obscurePassword,
        readOnly: readOnly,
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
