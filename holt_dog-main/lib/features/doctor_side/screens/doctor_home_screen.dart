import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  int _currentIndex = 1;

  final List<Widget> _screens = [
    const DonationScreen(),
    const _HomeBody(),
    const ResultsScreen(),
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
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('scans')
          .orderBy('timestamp', descending: true)
          .limit(20)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF4A148C)),
          );
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final docs = snapshot.data?.docs ?? [];
        final reports = docs.map((doc) => Report.fromFirestore(doc)).toList();

        return SingleChildScrollView(
          child: Column(
            children: [
              const DoctorQuickActionHeader(userName: '', showSearch: true),
              if (reports.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 60.h),
                  child: Column(
                    children: [
                      Icon(Icons.pets, size: 64.w, color: Colors.grey[400]),
                      SizedBox(height: 12.h),
                      Text(
                        'No reports found',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...reports.map(
                  (report) => Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30.w),
                    child: ReportCard(report: report),
                  ),
                ),
              SizedBox(height: 100.h),
            ],
          ),
        );
      },
    );
  }
}
