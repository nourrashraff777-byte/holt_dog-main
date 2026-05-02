import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:holt_dog/features/charity_side/screens/results_screen.dart';
import 'package:holt_dog/features/charity_side/screens/marketplace_screen.dart';
import 'package:holt_dog/features/donation/screens/donation_screen.dart';
import 'package:holt_dog/features/user_side/user_home/screens/custom_drawer.dart';
import 'package:holt_dog/features/insurance_side/widgets/insurance_quick_actions_widgets.dart';
import '../models/report_model.dart';
import '../widgets/insurance_nav_bar.dart';

class InsuranceHomeScreen extends StatefulWidget {
  static const String routeName = '/insuranceHome';
  const InsuranceHomeScreen({super.key});

  @override
  State<InsuranceHomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<InsuranceHomeScreen> {
  int _currentIndex = 1; // Default to Home
  int _marketCartCount = 0;

  late final List<Widget> _screens = [
    const DonationScreen(),          // 0 - Donate
    const _InsuranceHomeBody(),      // 1 - Home
    const ResultsScreen(),           // 2 - Results (same as doctor style)
    MarketplaceScreen(               // 3 - Market
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
      bottomNavigationBar: InsuranceNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        marketCartBadgeCount: _marketCartCount,
      ),
    );
  }
}

// ─── Insurance home body — shows reports feed ─────────────────────────────────

class _InsuranceHomeBody extends StatelessWidget {
  const _InsuranceHomeBody();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reports')
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
              const InsuranceQuickActionHeader(userName: '', showSearch: true),
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
                    child: _InsuranceReportCard(report: report),
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

// ─── Home feed card (with Uploaded By, matching the insurance screenshot) ─────

class _InsuranceReportCard extends StatelessWidget {
  final Report report;
  const _InsuranceReportCard({required this.report});

  Future<void> _setStatus(String s) => FirebaseFirestore.instance
      .collection('reports')
      .doc(report.id)
      .update({'status': s});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 24.h, top: 12.h),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5).withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dog thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: report.imageUrl.isNotEmpty
                          ? Image.network(
                              report.imageUrl,
                              width: 130.w,
                              height: 100.h,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _placeholder(),
                            )
                          : _placeholder(),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Text(
                        report.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15.sp,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Icon(Icons.watch_later,
                        color: Colors.grey[600], size: 16.w),
                    SizedBox(width: 4.w),
                    Text(report.date,
                        style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic)),
                    SizedBox(width: 10.w),
                    Icon(Icons.room, color: Colors.grey[600], size: 16.w),
                    SizedBox(width: 4.w),
                    Text(report.location,
                        style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic)),
                  ],
                ),
              ],
            ),
          ),
          // Status badge
          Positioned(
            top: -10.h,
            right: 10.w,
            child: GestureDetector(
              onTap: () => _showStatusPicker(context),
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 14.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: report.statusColor,
                  borderRadius: BorderRadius.circular(10.r),
                  boxShadow: [
                    BoxShadow(
                      color: report.statusColor.withValues(alpha: 0.4),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Text(
                  report.statusText,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showStatusPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Update Status',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _statusBtn('Needs Help', 'missing', const Color(0xFFC62828)),
            _statusBtn('Undercare', 'pending', const Color(0xFFE65100)),
            _statusBtn('Rescued', 'solved', const Color(0xFF2E7D32)),
          ],
        ),
      ),
    );
  }

  Widget _statusBtn(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => _setStatus(value),
          child: Text(label,
              style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 130.w,
      height: 100.h,
      color: const Color(0xFFEDE7F6),
      child:
          const Icon(Icons.pets, color: Color(0xFF7B1FA2), size: 40),
    );
  }
}
