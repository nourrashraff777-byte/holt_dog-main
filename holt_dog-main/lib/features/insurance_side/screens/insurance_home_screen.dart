import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:holt_dog/features/user_side/user_home/screens/custom_drawer.dart';
import 'package:holt_dog/features/insurance_side/widgets/insurance_quick_actions_widgets.dart';
import '../models/report_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_styles.dart';

class InsuranceHomeScreen extends StatefulWidget {
  static const String routeName = '/insuranceHome';
  const InsuranceHomeScreen({super.key});

  @override
  State<InsuranceHomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<InsuranceHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      backgroundColor: Colors.white,
      body: const _InsuranceHomeBody(),
      bottomNavigationBar: _InsuranceNavBarSimple(),
    );
  }
}

// ─── Simple nav bar with only Home visible ───────────────────────────────────

class _InsuranceNavBarSimple extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        color: AppColors.primaryPurple,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Icon(Icons.home,
                  color: AppColors.primaryPurple, size: 28.w),
            ),
            SizedBox(height: 4.h),
            Text(
              'Home',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Insurance home body — streams from 'scans' ───────────────────────────────

class _InsuranceHomeBody extends StatelessWidget {
  const _InsuranceHomeBody();

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

// ─── Report card — same design as charity/doctor, adds reporter's name ────────

class _InsuranceReportCard extends StatelessWidget {
  final Report report;
  const _InsuranceReportCard({required this.report});

  Future<void> _setStatus(String s) => FirebaseFirestore.instance
      .collection('scans')
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
              color: AppColors.backgroundGray.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(AppStyles.radiusL.r),
              border: Border.all(
                  color: AppColors.borderLight.withValues(alpha: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dog thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppStyles.radiusM.r),
                      child: CachedNetworkImage(
                        imageUrl: report.imageUrl,
                        width: 130.w,
                        height: 100.h,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 130.w,
                          height: 100.h,
                          color: AppColors.backgroundWhite,
                          child: Center(
                            child: SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: const CircularProgressIndicator(
                                  strokeWidth: 2),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 130.w,
                          height: 100.h,
                          color: const Color(0xFFEDE7F6),
                          child: Icon(Icons.pets,
                              color: AppColors.textHint, size: 30.w),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            report.title,
                            style: AppTypography.bodyLarge.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                              fontSize: 16.sp,
                            ),
                          ),
                          // Reporter name row (fetched by userId)
                          if (report.reporterId.isNotEmpty) ...[
                            SizedBox(height: 6.h),
                            _ReporterName(userId: report.reporterId),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Padding(
                  padding: EdgeInsets.only(left: 4.w),
                  child: Row(
                    children: [
                      Icon(Icons.watch_later,
                          color: Colors.grey[600], size: 18.w),
                      SizedBox(width: 4.w),
                      Text(
                        report.date,
                        style: AppTypography.caption.copyWith(
                          fontSize: 13.sp,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Icon(Icons.room, color: Colors.grey[600], size: 18.w),
                      SizedBox(width: 4.w),
                      Flexible(
                        child: Text(
                          report.location,
                          style: AppTypography.caption.copyWith(
                            fontSize: 13.sp,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Status badge (tappable to change)
          Positioned(
            top: -12.h,
            right: 12.w,
            child: GestureDetector(
              onTap: () => _showStatusPicker(context),
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
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
                  style: AppTypography.caption.copyWith(
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => _setStatus(value),
          child: Text(label, style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}

// ─── Async widget — looks up the reporter's display name ─────────────────────

class _ReporterName extends StatelessWidget {
  final String userId;
  const _ReporterName({required this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, snap) {
        String name = '';
        if (snap.hasData && snap.data!.exists) {
          final data = snap.data!.data() as Map<String, dynamic>? ?? {};
          name = (data['displayName'] ??
                  data['name'] ??
                  data['username'] ??
                  data['email'] ??
                  '')
              .toString();
        }
        if (name.isEmpty) return const SizedBox.shrink();
        return Row(
          children: [
            Icon(Icons.person_outline,
                size: 14.w, color: AppColors.primaryPurple),
            SizedBox(width: 4.w),
            Flexible(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.primaryPurple,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      },
    );
  }
}
