import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../models/vet_model.dart';
import '../widgets/user_quick_actions_widgets.dart';

class VetsScreen extends StatelessWidget {
  const VetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data for UI testing during development
    final List<Vet> mockVets = [
      Vet(
        id: '1',
        name: 'GIZA MEDICAL CENTER',
        address: 'Giza City , Egypt',
        phone: '0123456789',
        status: VetStatus.available,
      ),
      Vet(
        id: '2',
        name: 'VET CLINIC',
        address: 'NASR ROAD, Giza',
        phone: '0122334455',
        status: VetStatus.available,
      ),
      Vet(
        id: '3',
        name: 'Zayed Vet Clinic',
        address: '11 Sheikh Zayed, Giza, Egypt',
        phone: '0111222333',
        status: VetStatus.closed,
      ),
      Vet(
        id: '4',
        name: 'Pet Health Center',
        address: '6th of October City, Giza',
        phone: '0101010101',
        status: VetStatus.closed,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const UserQuickActionHeader(
            userName: '',
            showSearch: false,
            showBackButton: true,
            title: 'Nearby Veterinarians',
            subtitle: 'get fast veterinary assistance',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                children: [
                  const _LocationInfoCard(),
                  SizedBox(height: 20.h),
                  ...mockVets.map((vet) => _VetCard(vet: vet)),
                  SizedBox(height: 100.h), // Bottom Nav space
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationInfoCard extends StatelessWidget {
  const _LocationInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check, color: Colors.white, size: 16.w),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Giza , Egypt',
                  style: AppTypography.h3.copyWith(fontSize: 18.sp),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Your location has been accurately shared and at our presence',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VetCard extends StatelessWidget {
  final Vet vet;
  const _VetCard({required this.vet});

  @override
  Widget build(BuildContext context) {
    final bool isAvailable = vet.status == VetStatus.available;
    final Color statusColor = isAvailable ? Colors.green : Colors.red;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        border:
            Border.all(color: statusColor.withValues(alpha: 0.8), width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vet.name,
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(Icons.room, color: AppColors.textHint, size: 14.w),
                    SizedBox(width: 4.w),
                    Text(vet.address, style: AppTypography.caption),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.check_circle_outline,
                        color: statusColor, size: 14.w),
                    SizedBox(width: 4.w),
                    Text(
                      isAvailable ? 'available' : 'Closed',
                      style: AppTypography.caption.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  vet.phone,
                  style: AppTypography.bodySmall
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: statusColor.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(Icons.phone_in_talk, color: Colors.white, size: 28.w),
          ),
        ],
      ),
    );
  }
}
