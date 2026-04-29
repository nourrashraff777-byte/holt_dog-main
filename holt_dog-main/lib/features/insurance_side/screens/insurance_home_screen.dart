import 'package:flutter/material.dart';
import 'package:holt_dog/features/insurance_side/screens/insurance_results_screen.dart';
import '../widgets/insurance_nav_bar.dart';

class InsuranceHomeScreen extends StatefulWidget {
  static const String routeName = '/insuranceHome';
  const InsuranceHomeScreen({super.key});

  @override
  State<InsuranceHomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<InsuranceHomeScreen> {
  int _currentIndex = 0; // Default to Home (Center tab)

  final List<Widget> _screens = [
    const InsuranceResultsScreen(), // Extracted main content
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      backgroundColor: Colors.white,
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: InsuranceNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
