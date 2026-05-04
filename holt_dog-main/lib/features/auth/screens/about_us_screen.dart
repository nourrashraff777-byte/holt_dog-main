import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:holt_dog/core/routes/app_router.dart';
import 'package:holt_dog/features/donation/screens/e_wallet_screen.dart';
import 'package:holt_dog/features/user_side/user_home/screens/user_home_screen.dart';

// ==========================================
// ABOUT US SCREEN
// ==========================================
class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  static const Color primaryPurple = Color(0xFF45207A);
  static const Color primaryPink = Color(0xFFC73693);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              children: [
                ClipPath(
                  clipper: HeaderClipper(),
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryPurple, Color(0xFF7B1FA2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back_ios_new,
                                    color: primaryPurple, size: 18),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                            const Expanded(
                              child: Center(
                                child: Text(
                                  'About Us',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(width: 48),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                                color: Colors.white24, shape: BoxShape.circle),
                            child: const Icon(Icons.pets,
                                color: Colors.white, size: 36),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Holt_Dog',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Our Story', Icons.auto_stories),
                  const SizedBox(height: 14),
                  _storyCard(
                    'It started with a moment we couldn\'t ignore… a stray dog, alone, injured, and unseen. '
                    'From there, we knew we had to do something. We built this project to be their voice.\n\n'
                    'We scan and track stray dogs, understand their condition, and step in when they need help the most. '
                    'Every dog we reach is a story. While we try to change by connecting them to veterinary care and safe shelters. '
                    'Because saving one dog doesn\'t change the world, but it changes their world.',
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 36)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('What We Do', Icons.volunteer_activism),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _whatWeDoCard(Icons.campaign_outlined,
                          'Spread\nAwareness', const Color(0xFFEDE7F6)),
                      _whatWeDoCard(Icons.shield_outlined, 'Dog\nProtection',
                          const Color(0xFFFCE4EC)),
                      _whatWeDoCard(Icons.eco_outlined,
                          'Environmental\nProtection', const Color(0xFFE8F5E9)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 36)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Our Mission', Icons.flag_outlined),
                  const SizedBox(height: 14),
                  _missionCard(),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryPurple, Color(0xFF7B1FA2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Column(
                children: [
                  Icon(Icons.pets, color: Colors.white, size: 32),
                  SizedBox(height: 8),
                  Text('Holt Dog',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2)),
                  SizedBox(height: 4),
                  Text('Every Stray Deserves a Story',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: primaryPink, size: 26),
        const SizedBox(width: 10),
        Text(title,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: primaryPurple)),
      ],
    );
  }

  static Widget _storyCard(String text) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.deepPurple.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6))
        ],
        border: Border.all(color: const Color(0xFFEDE7F6), width: 1.5),
      ),
      child: Text(text,
          style: const TextStyle(
              fontSize: 15, color: Colors.black87, height: 1.75)),
    );
  }

  static Widget _whatWeDoCard(IconData icon, String label, Color bgColor) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white,
              child: Icon(icon, color: primaryPurple, size: 28),
            ),
            const SizedBox(height: 12),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: primaryPurple,
                    height: 1.4)),
          ],
        ),
      ),
    );
  }

  static Widget _missionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7B1FA2), primaryPink],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: primaryPink.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.format_quote, color: Colors.white54, size: 30)
          ]),
          const SizedBox(height: 8),
          const Text(
            'We exist to protect those who can\'t protect themselves.\n\n'
            'Our mission is to rescue stray dogs, connect them with the care they deserve, and create a safer environment for everyone. '
            'Through smart tracking and data collection, we don\'t just help today — we build a better future for animals and our communities.\n\n'
            'Every scan, every rescue, every life… matters.',
            style: TextStyle(fontSize: 15, color: Colors.white, height: 1.75),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(30)),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.pets, color: Colors.white, size: 16),
                  SizedBox(width: 6),
                  Text('Holt_Dog',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
