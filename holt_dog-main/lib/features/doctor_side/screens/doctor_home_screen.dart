import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:holt_dog/features/charity_side/screens/results_screen.dart';
import 'package:holt_dog/features/donation/screens/donation_screen.dart';
import 'package:holt_dog/features/user_side/user_home/screens/custom_drawer.dart';
import '../widgets/doctor_quick_actions_widgets.dart';
import '../widgets/home_widgets.dart';
import '../widgets/doctor_nav_bar.dart';
import '../models/report_model.dart';

class DoctorHomeScreen extends StatefulWidget {
  static const String routeName = '/doctorHome';
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<DoctorHomeScreen> {
  int _currentIndex = 1; // Default to Home (Center tab)

  final List<Widget> _screens = [
    // const ScanScreen(),
    const DonationScreen(), // Extracted main content
    const _HomeBody(), // Extracted main content
    const ResultsScreen(), // Extracted main content
    // const MapScreen(),
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
      bottomNavigationBar: DoctorNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
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
          const DoctorQuickActionHeader(userName: '', showSearch: true),
          ...mockReports.map((report) => Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: ReportCard(report: report),
              )),
          SizedBox(height: 100.h),
          // Padding(
          //   padding: EdgeInsets.symmetric(horizontal: 30.w),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       SizedBox(height: 20.h),
          //       Text(
          //         'Quick Actions',
          //         style: AppTypography.h3.copyWith(
          //           fontSize: 22.sp,
          //           fontWeight: FontWeight.w900,
          //           color: Colors.black,
          //         ),
          //       ),
          //       SizedBox(height: 30.h),
          //       QuickActionCard(
          //         title: 'Nearby Vets',
          //         icon: Icons.pets,
          //         onTap: () {
          //           Navigator.push(
          //             context,
          //             MaterialPageRoute(
          //                 builder: (context) => const VetsScreen()),
          //           );
          //         },
          //       ),
          //       QuickActionCard(
          //         title: 'Nearby Shelters',
          //         icon: Icons.home_work_outlined,
          //         onTap: () {
          //           Navigator.push(
          //             context,
          //             MaterialPageRoute(
          //                 builder: (context) => const SheltersScreen()),
          //           );
          //         },
          //       ),
          //       QuickActionCard(
          //         title: 'My Reports',
          //         icon: Icons.assignment_outlined,
          //         onTap: () {
          //           context.push(MyReportScreen.routeName);
          //         },
          //       ),
          //       SizedBox(height: 32.h),
          //       Row(
          //         mainAxisAlignment: MainAxisAlignment.start,
          //         children: [
          //           Text(
          //             'Recent Reports',
          //             style: AppTypography.h3.copyWith(
          //               fontSize: 22.sp,
          //               fontWeight: FontWeight.w900,
          //               color: Colors.black,
          //             ),
          //           ),
          //           SizedBox(width: 8.w),
          //           Icon(Icons.history, color: Colors.red[400], size: 24.w),
          //         ],
          //       ),
          //       SizedBox(height: 24.h),

          //       SizedBox(height: 16.h),
          //       ViewAllButton(onTap: () {}),
          //       SizedBox(height: 32.h),
          //       const QuoteBanner(),
          //       SizedBox(height: 140.h),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}
