import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:holt_dog/features/user_side/user_home/screens/custom_drawer.dart';
import 'package:holt_dog/features/user_side/reports/screens/my_report_screen.dart'
    hide Report;
import '../widgets/user_quick_actions_widgets.dart';
import '../widgets/home_widgets.dart';
import '../widgets/user_nav_bar.dart';
import '../models/report_model.dart';
import '../../../../core/constants/app_typography.dart';
import '../../scan/screens/scan_screen.dart';
import '../../map/screens/map_screen.dart';
import 'vets_screen.dart';
import 'shelters_screen.dart';

class UserHomeScreen extends StatefulWidget {
  static const String routeName = '/userHome';
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<UserHomeScreen> {
  int _currentIndex = 1; // Default to Home (Center tab)

  final List<Widget> _screens = [
    const ScanScreen(),
    const _HomeBody(), // Extracted main content
    const MapScreen(),
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
      bottomNavigationBar: UserNavBar(
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
    return SingleChildScrollView(
      child: Column(
        children: [
          const UserQuickActionHeader(userName: '', showSearch: true),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                Text(
                  'Quick Actions',
                  style: AppTypography.h3.copyWith(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 30.h),
                QuickActionCard(
                  title: 'Nearby Vets',
                  icon: Icons.pets,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const VetsScreen()),
                    );
                  },
                ),
                QuickActionCard(
                  title: 'Nearby Shelters',
                  icon: Icons.home_work_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SheltersScreen()),
                    );
                  },
                ),
                QuickActionCard(
                  title: 'My Reports',
                  icon: Icons.assignment_outlined,
                  onTap: () {
                    context.push(MyReportScreen.routeName);
                  },
                ),
                SizedBox(height: 32.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Reports',
                      style: AppTypography.h3.copyWith(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Icon(Icons.history, color: Colors.red[400], size: 24.w),
                  ],
                ),
                SizedBox(height: 24.h),
                const _RecentReportsList(),
                SizedBox(height: 16.h),
                ViewAllButton(
                  onTap: () => context.push(MyReportScreen.routeName),
                ),
                SizedBox(height: 32.h),
                const QuoteBanner(),
                SizedBox(height: 140.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentReportsList extends StatelessWidget {
  const _RecentReportsList();

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Text(
          'Sign in to see your reports.',
          style: AppTypography.bodySmall,
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('scans')
          .where('userId', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 24.h),
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Text(
              'Error: ${snapshot.error}',
              style: AppTypography.bodySmall.copyWith(color: Colors.red),
            ),
          );
        }

        final docs = [...?snapshot.data?.docs];
        if (docs.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Text(
              'No reports yet. Run a scan to add one.',
              style: AppTypography.bodySmall,
            ),
          );
        }

        // Sort newest first in Dart so we don't need a composite index.
        docs.sort((a, b) {
          final ta = (a.data() as Map<String, dynamic>)['timestamp']
              as Timestamp?;
          final tb = (b.data() as Map<String, dynamic>)['timestamp']
              as Timestamp?;
          if (ta == null && tb == null) return 0;
          if (ta == null) return 1;
          if (tb == null) return -1;
          return tb.compareTo(ta);
        });

        final recent = docs.take(3).map((doc) {
          return _scanDocToReport(doc.id, doc.data() as Map<String, dynamic>);
        }).toList();

        return Column(
          children: recent.map((r) => ReportCard(report: r)).toList(),
        );
      },
    );
  }

  static Report _scanDocToReport(String id, Map<String, dynamic> data) {
    final analysis = (data['analysis'] is Map)
        ? Map<String, dynamic>.from(data['analysis'] as Map)
        : const <String, dynamic>{};
    final disease = (analysis['disease'] as String?) ?? '';
    final mood = (analysis['mood'] as String?) ?? '';
    final isDog = analysis['isDog'] == true;

    String title;
    if (isDog && disease.isNotEmpty && mood.isNotEmpty) {
      title = '$disease · $mood';
    } else if (isDog && disease.isNotEmpty) {
      title = disease;
    } else {
      title = 'Dog scan';
    }

    final address = (data['address'] as String?) ?? '';
    final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
    final dateText = _relativeDate(timestamp);

    final statusRaw = (data['status'] as String?) ?? 'pending';
    final status = _statusFromString(statusRaw);

    return Report(
      id: id,
      title: title,
      location: address.isEmpty ? 'Unknown location' : address,
      date: dateText,
      imageUrl: (data['imageUrl'] as String?) ?? '',
      status: status,
    );
  }

  static ReportStatus _statusFromString(String raw) {
    switch (raw.toLowerCase()) {
      case 'solved':
      case 'rescued':
        return ReportStatus.solved;
      case 'pending':
      case 'undercare':
        return ReportStatus.pending;
      case 'need help':
      case 'needs help':
      case 'missing':
      default:
        return ReportStatus.missing;
    }
  }

  static String _relativeDate(DateTime? d) {
    if (d == null) return '—';
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) {
      final h = diff.inHours;
      return '$h hour${h == 1 ? '' : 's'} ago';
    }
    if (diff.inDays < 7) {
      final dy = diff.inDays;
      return '$dy day${dy == 1 ? '' : 's'} ago';
    }
    final w = (diff.inDays / 7).floor();
    return '$w week${w == 1 ? '' : 's'} ago';
  }
}
