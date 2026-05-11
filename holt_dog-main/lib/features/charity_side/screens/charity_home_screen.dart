import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:holt_dog/core/constants/app_colors.dart';
import 'package:holt_dog/core/widgets/app_drawer.dart';
import 'package:holt_dog/features/auth/cubit/auth_cubit.dart';
import 'package:holt_dog/features/auth/cubit/auth_state.dart';
import 'package:holt_dog/features/auth/models/user_model.dart';
import 'package:holt_dog/features/marketplace/presentation/screens/marketplace_screen.dart';
import 'package:holt_dog/features/charity_side/screens/results_screen.dart';
import 'package:holt_dog/features/donation/screens/donation_screen.dart';
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
  int _currentIndex = 1;
  int _marketCartCount = 0;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthCubit>().state;
    final UserModel? user = state is Authenticated ? state.user : null;

    final List<Widget> screens = [
      const DonationScreen(),
      _HomeBody(userName: user?.name ?? ''),
      const ResultsScreen(),
      MarketplaceScreen(
        onCartItemCountChanged: (count) =>
            setState(() => _marketCartCount = count),
      ),
    ];

    return Scaffold(
      drawer: user != null ? AppDrawer(user: user) : const Drawer(),
      backgroundColor: Colors.white,
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
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
  final String userName;

  const _HomeBody({this.userName = ''});

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
              CharityQuickActionHeader(userName: userName, showSearch: true),
              Padding(
                padding: EdgeInsets.fromLTRB(30.w, 12.h, 30.w, 4.h),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _showDoctorsSheet(context),
                    icon: Icon(Icons.medical_services_outlined, size: 22.sp),
                    label: Text(
                      'View all doctors',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                  ),
                ),
              ),
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

void _showDoctorsSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: 0.52,
      minChildSize: 0.35,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              SizedBox(height: 10.h),
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
                child: Row(
                  children: [
                    Icon(Icons.groups_outlined,
                        color: AppColors.primaryPurple, size: 26.sp),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        'Doctors',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where('role', isEqualTo: 'doctor')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFF4A148C)),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.w),
                          child: Text(
                            'Could not load doctors.\n${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.red[700], fontSize: 14.sp),
                          ),
                        ),
                      );
                    }
                    final docs = snapshot.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_off_outlined,
                                size: 48.sp, color: Colors.grey[400]),
                            SizedBox(height: 12.h),
                            Text(
                              'No doctors registered yet',
                              style: TextStyle(
                                fontSize: 15.sp,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.separated(
                      controller: scrollController,
                      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
                      itemCount: docs.length,
                      separatorBuilder: (_, __) => SizedBox(height: 8.h),
                      itemBuilder: (context, i) {
                        final doc = docs[i];
                        final d = doc.data();
                        final name =
                            (d['name'] as String?)?.trim().isNotEmpty == true
                                ? (d['name'] as String).trim()
                                : 'Doctor';
                        final phone =
                            (d['phone'] as String?)?.trim() ?? '';
                        final email =
                            (d['email'] as String?)?.trim() ?? '';
                        final canCall = _phoneForDial(phone).isNotEmpty;
                        return Material(
                          color: const Color(0xFFF7F8FC),
                          borderRadius: BorderRadius.circular(14.r),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 14.w, vertical: 4.h),
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primaryPurple
                                  .withValues(alpha: 0.15),
                              child: Icon(Icons.person_outline,
                                  color: AppColors.primaryPurple,
                                  size: 22.sp),
                            ),
                            title: Text(
                              name,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15.sp,
                              ),
                            ),
                            subtitle: email.isNotEmpty
                                ? Text(
                                    email,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey[600]),
                                  )
                                : (phone.isNotEmpty
                                    ? Text(
                                        phone,
                                        style: TextStyle(
                                            fontSize: 12.sp,
                                            color: Colors.grey[600]),
                                      )
                                    : null),
                            trailing: IconButton(
                              tooltip: canCall ? 'Call' : 'No phone number',
                              onPressed: canCall
                                  ? () => _launchDoctorCall(ctx, phone)
                                  : null,
                              icon: Icon(
                                Icons.phone_in_talk_rounded,
                                color: canCall
                                    ? const Color(0xFF2E7D32)
                                    : Colors.grey[400],
                                size: 26.sp,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

String _phoneForDial(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return '';
  final buf = StringBuffer();
  for (var i = 0; i < trimmed.length; i++) {
    final c = trimmed[i];
    if (c == '+' && buf.isEmpty) {
      buf.write(c);
    } else if (RegExp(r'\d').hasMatch(c)) {
      buf.write(c);
    }
  }
  return buf.toString();
}

Future<void> _launchDoctorCall(BuildContext context, String phone) async {
  final digits = _phoneForDial(phone);
  if (digits.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No valid phone number')),
    );
    return;
  }
  final uri = Uri(scheme: 'tel', path: digits);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cannot open phone dialer')),
    );
  }
}
