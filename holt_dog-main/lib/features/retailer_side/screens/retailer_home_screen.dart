import 'package:flutter/material.dart';
import 'package:holt_dog/features/charity_side/screens/marketplace_screen.dart';
import 'package:holt_dog/features/user_side/user_home/screens/custom_drawer.dart';
import 'package:holt_dog/features/retailer_side/screens/retailer_orders_screen.dart';
import '../widgets/retailer_nav_bar.dart';

class RetailerHomeScreen extends StatefulWidget {
  static const String routeName = '/retailerHome';
  const RetailerHomeScreen({super.key});

  @override
  State<RetailerHomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<RetailerHomeScreen> {
  int _currentIndex = 0; // Default to Home (Center tab)

  final List<Widget> _screens = [
    const MarketplaceScreen(),
    const RetailerOrdersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      backgroundColor: Colors.white,
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: RetailerNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

