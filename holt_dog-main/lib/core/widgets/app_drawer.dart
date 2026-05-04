import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:holt_dog/core/routes/app_router.dart';
import 'package:holt_dog/features/auth/cubit/auth_cubit.dart';
import 'package:holt_dog/features/auth/models/user_model.dart';
import 'package:holt_dog/features/auth/screens/about_us_screen.dart';
import 'package:holt_dog/features/auth/screens/contact_us_screen.dart';
import 'package:holt_dog/features/auth/screens/edit_profile_screen.dart';
import 'package:holt_dog/features/auth/screens/feed_back_screen.dart';
import 'package:holt_dog/features/auth/screens/settings_screen.dart';

/// A role-agnostic drawer shared by every home screen.
/// Pass the currently authenticated [user] so that the header
/// always shows real name and e-mail from Firestore.
class AppDrawer extends StatefulWidget {
  final UserModel user;

  const AppDrawer({super.key, required this.user});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF45207A),
      child: SafeArea(
        child: Column(
          children: [
            _DrawerHeader(user: widget.user),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Divider(color: Colors.white54, thickness: 1),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  _DrawerMenuItem(
                    icon: Icons.person_outline,
                    title: 'My Profile',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditProfileScreen(),
                        ),
                      );
                    },
                  ),
                  _DrawerMenuItem(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                  _DrawerMenuItem(
                    icon: Icons.people_outline,
                    title: 'Contact Us',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ContactUsScreen(),
                        ),
                      );
                    },
                  ),
                  _DrawerMenuItem(
                    icon: Icons.notifications_none,
                    title: 'Notification',
                    trailing: Switch(
                      value: _notificationsEnabled,
                      onChanged: (bool value) =>
                          setState(() => _notificationsEnabled = value),
                      activeThumbColor: Colors.green,
                    ),
                    onTap: () {},
                  ),
                  const SizedBox(height: 20),
                  _DrawerMenuItem(
                    icon: Icons.info_outline,
                    title: 'About Us',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AboutUsScreen(),
                        ),
                      );
                    },
                  ),
                  _DrawerMenuItem(
                    icon: Icons.notes,
                    title: 'FeedBack',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FeedbackPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _DrawerMenuItem(
                icon: Icons.power_settings_new,
                title: 'Logout',
                iconColor: Colors.redAccent,
                trailing: const SizedBox.shrink(),
                onTap: () {
                  context.read<AuthCubit>().logout();
                  context.go(AppRouter.login);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Drawer header — shows real user name & email ──────────────────────────────

class _DrawerHeader extends StatelessWidget {
  final UserModel user;

  const _DrawerHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    final String displayName = user.name.isEmpty ? 'User' : user.name;
    final String displayEmail = user.email;

    return InkWell(
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EditProfileScreen()),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 35,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 50, color: Color(0xFF45207A)),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    displayEmail,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.keyboard_double_arrow_left,
              color: Colors.white,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable menu item ────────────────────────────────────────────────────────

class _DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color iconColor;
  final Widget? trailing;

  const _DrawerMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor = Colors.white,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white12,
            borderRadius: BorderRadius.circular(15),
          ),
          padding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              trailing ??
                  const Icon(
                    Icons.chevron_right,
                    color: Colors.white54,
                    size: 16,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
