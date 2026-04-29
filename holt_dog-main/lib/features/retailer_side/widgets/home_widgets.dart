import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:holt_dog/features/donation/screens/donation_screen.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_styles.dart';
import '../models/report_model.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 64.h, left: 30.w, right: 30.w, bottom: 40.h),
      decoration: BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(80.r),
          bottomRight: Radius.circular(80.r),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Nearby home',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textOnPurple.withValues(alpha:0.9),
                          fontSize: 14.sp,
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down, color: AppColors.textOnPurple.withValues(alpha:0.9), size: 20.w),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Holt Dog',
                    style: GoogleFonts.robotoSlab(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textOnPurple,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: AppColors.backgroundWhite.withValues(alpha:0.2),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: AppColors.backgroundWhite.withValues(alpha:0.3), width: 1.5),
                ),
                child: Row(
                  children: [
                    Text(
                      'Report Now',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textOnPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Icon(Icons.add_circle_outline, color: AppColors.textOnPurple, size: 20.w),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StatusSummaryCard extends StatelessWidget {
  final String label;
  final String count;
  final IconData icon;
  final Color color;

  const StatusSummaryCard({
    super.key,
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80.w,
      margin: EdgeInsets.only(right: 16.w),
      padding: EdgeInsets.symmetric(vertical: 20.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(40.r),
        border: Border.all(color: AppColors.borderLight.withValues(alpha:0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24.w),
          SizedBox(height: 12.h),
          Text(
            count,
            style: AppTypography.h3.copyWith(color: AppColors.textPrimary, fontSize: 22.sp),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              fontSize: 11.sp,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class ReportCard extends StatelessWidget {
  final Report report;

  const ReportCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 24.h, top: 12.h), // Top margin for label overlap
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.backgroundGray.withValues(alpha:0.6),
              borderRadius: BorderRadius.circular(AppStyles.radiusL.r),
              border: Border.all(color: AppColors.borderLight.withValues(alpha:0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                              child: const CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 130.w,
                          height: 100.h,
                          color: AppColors.backgroundWhite,
                          child: Icon(Icons.pets, color: AppColors.textHint, size: 30.w),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Text(
                        report.title,
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Padding(
                  padding: EdgeInsets.only(left: 4.w),
                  child: Row(
                    children: [
                      Icon(Icons.watch_later, color: Colors.grey[600], size: 18.w),
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
                      Text(
                        report.location,
                        style: AppTypography.caption.copyWith(
                          fontSize: 13.sp,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: -12.h,
            right: 12.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: report.statusColor,
                borderRadius: BorderRadius.circular(10.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.1),
                    blurRadius: 4,
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
        ],
      ),
    );
  }
}

class ViewAllButton extends StatelessWidget {
  final VoidCallback onTap;
  const ViewAllButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColors.backgroundGray,
            borderRadius: BorderRadius.circular(100.r),
            border: Border.all(color: AppColors.borderLight, width: 1.5),
          ),
          child: Text(
            'View All',
            style: AppTypography.buttonLabel.copyWith(
              color: Colors.black,
              fontSize: 18.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class QuoteBanner extends StatelessWidget {
  const QuoteBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 40.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundGray.withValues(alpha:0.8),
        borderRadius: BorderRadius.circular(AppStyles.radiusL.r),
        border: Border.all(color: AppColors.borderLight.withValues(alpha:0.5)),
      ),
      child: Column(
        children: [
          Text(
            'They don\'t have a voice, but they feel pain, fear, and hunger just like us.\nYour small donation can save a life.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.primaryPurple,
              fontWeight: FontWeight.w800,
              fontSize: 18.sp,
            ),
          ),
          SizedBox(height: 24.h),
          InkWell(
            onTap: () {
              context.push(DonationScreen.routeName, extra: true);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 12.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryMagenta, Color(0xFFFF4081)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(100.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryMagenta.withValues(alpha:0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Text(
                'Donate Now',
                style: AppTypography.buttonLabel.copyWith(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
