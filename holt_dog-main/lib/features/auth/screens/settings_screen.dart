import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:holt_dog/core/routes/app_router.dart';
import 'package:holt_dog/features/donation/screens/e_wallet_screen.dart';
import 'package:holt_dog/features/user_side/user_home/screens/user_home_screen.dart';

// ==========================================
// SETTINGS SCREEN
// ==========================================
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _cameraEnabled = true;
  bool _locationEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              ClipPath(
                  clipper: HeaderClipper(),
                  child: Container(
                      height: 180,
                      width: double.infinity,
                      color: const Color(0xFF4A148C))),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                          backgroundColor: Colors.white,
                          child: IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new,
                                  color: Color(0xFF4A148C), size: 18),
                              onPressed: () => Navigator.pop(context))),
                      const Expanded(
                          child: Center(
                              child: Text('Settings & Privacy',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)))),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
              ),
              Positioned(
                  bottom: -40,
                  child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      child: const Icon(Icons.miscellaneous_services,
                          size: 60, color: Colors.white))),
            ],
          ),
          const SizedBox(height: 70),
          _buildToggle('Camera', _cameraEnabled,
              (v) => setState(() => _cameraEnabled = v)),
          _buildToggle('Location', _locationEnabled,
              (v) => setState(() => _locationEnabled = v)),
        ],
      ),
    );
  }

  Widget _buildToggle(String title, bool val, ValueChanged<bool> onChange) {
    return ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: CupertinoSwitch(value: val, onChanged: onChange));
  }
}
