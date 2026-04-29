import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../models/shelter_model.dart';
import '../widgets/user_quick_actions_widgets.dart';

class SheltersScreen extends StatelessWidget {
  const SheltersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data for UI testing during development
    final List<Shelter> mockShelters = [
      Shelter(
        id: '1',
        name: 'Mira Gamal Shelter',
        address:
            'B6 رئيس مجلس المعادي، قسم مصر الجديدة، محافظة القاهرة 4460231',
        phone: '01147572385',
        status: ShelterStatus.available,
        rating: 4.5,
      ),
      Shelter(
        id: '2',
        name: 'Animal Protection Foundation Shelter - APF',
        address: 'المعادي، أبو النمرس، محافظة الجيزة 3361113',
        phone: '01221104994',
        status: ShelterStatus.available,
        rating: 4.0,
      ),
      Shelter(
        id: '3',
        name: 'Society for Protection of Animal Rights in Egypt S.P.A.R.E',
        address: '8 Sakara Road, Giza, Shabramant, Al-Mansouriya',
        phone: '0233813855',
        status: ShelterStatus.closed,
        rating: 3.5,
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
            title: 'Nearby Shelters',
            subtitle: 'A safe place full of love 🐾',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                children: [
                  const _LocationInfoCard(),
                  SizedBox(height: 20.h),
                  ...mockShelters
                      .map((shelter) => _ShelterCard(shelter: shelter)),
                  SizedBox(height: 100.h),
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
        borderRadius: BorderRadius.circular(20.r),
        border:
            Border.all(color: Colors.black.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.green, width: 2),
            ),
            child: Icon(Icons.location_on, color: Colors.green, size: 24.w),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'current location Detected',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textSecondary),
                ),
                Text(
                  'cairo , Egypt',
                  style: AppTypography.h3.copyWith(fontSize: 18.sp),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Your location has been automatically detected and shared emergency services',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShelterCard extends StatelessWidget {
  final Shelter shelter;
  const _ShelterCard({required this.shelter});

  @override
  Widget build(BuildContext context) {
    final bool isAvailable = shelter.status == ShelterStatus.available;
    final Color statusColor = isAvailable ? Colors.green : Colors.red;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        border:
            Border.all(color: statusColor.withValues(alpha: 0.8), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shelter.name,
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.room, color: AppColors.textHint, size: 16.w),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        shelter.address,
                        style: AppTypography.caption.copyWith(fontSize: 12.sp),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(Icons.check_circle_outline,
                        color: statusColor, size: 16.w),
                    SizedBox(width: 6.w),
                    Text(
                      isAvailable ? 'Available' : 'Closed',
                      style: AppTypography.caption.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                const Divider(height: 1),
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < shelter.rating.floor()
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.grey,
                          size: 18.w,
                        );
                      }),
                    ),
                    Text(
                      shelter.phone,
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: statusColor.withValues(alpha: 0.3),
                  blurRadius: 8,
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
