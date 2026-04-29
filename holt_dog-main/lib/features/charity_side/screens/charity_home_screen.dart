import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:holt_dog/features/charity_side/screens/marketplace_screen.dart';
import 'package:holt_dog/features/insurance_side/screens/insurance_results_screen.dart';
import 'package:holt_dog/features/donation/screens/donation_screen.dart';
import 'package:holt_dog/features/user_side/user_home/screens/custom_drawer.dart';
import '../widgets/charity_quick_actions_widgets.dart';
import '../widgets/home_widgets.dart';
import '../widgets/charity_nav_bar.dart';
import '../models/report_model.dart';

class CharityHomeScreen extends StatefulWidget {
  static const String routeName = '/charityHome';
  const CharityHomeScreen({super.key});

  @override
  State<CharityHomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<CharityHomeScreen> {
  int _currentIndex = 1; // Default to Home (Center tab)
  int _marketCartCount = 0;

  late final List<Widget> _screens = [
    const DonationScreen(),
    const _HomeBody(),
    const InsuranceResultsScreen(),
    MarketplaceScreen(
      onCartItemCountChanged: (count) =>
          setState(() => _marketCartCount = count),
    ),
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
      bottomNavigationBar: CharityNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        marketCartBadgeCount: _marketCartCount,
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    // Mock Data for UI testing during development
    final List<Report> mockReports = [
      Report(
        id: '1',
        title: 'Recovered after treatment',
        location: 'Maadi',
        date: '1 day ago',
        imageUrl: 'https://images.unsplash.com/photo-1543466835-00a7907e9de1',
        status: ReportStatus.solved,
      ),
      Report(
        id: '2',
        title: 'Injured leg, needs urgent care',
        location: 'Maadi',
        date: '2 hours ago',
        imageUrl: 'https://images.unsplash.com/photo-1548199973-03cce0bbc87b',
        status: ReportStatus.missing,
      ),
      Report(
        id: '3',
        title: 'Weak puppy, not eating well',
        location: 'Giza',
        date: '4 days ago',
        imageUrl:
            'https://images.unsplash.com/photo-1583337130417-3346a1be7dee',
        status: ReportStatus.pending,
      ),
    ];

    return SingleChildScrollView(
      child: Column(
        children: [
          const CharityQuickActionHeader(userName: '', showSearch: true),
          ...mockReports.map((report) => Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: ReportCard(report: report),
              )),
          SizedBox(height: 100.h),
        ],
      ),
    );
  }
}
