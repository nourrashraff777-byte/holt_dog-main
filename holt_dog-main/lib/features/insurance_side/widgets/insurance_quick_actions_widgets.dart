import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';

class SlantedHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height * 0.7);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class InsuranceQuickActionHeader extends StatelessWidget {
  final String userName;
  final String? title;
  final String? subtitle;
  final bool showSearch;
  final bool showBackButton;

  const InsuranceQuickActionHeader({
    super.key,
    this.userName = '',
    this.title,
    this.subtitle,
    this.showSearch = true,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipPath(
          clipper: SlantedHeaderClipper(),
          child: Container(
            width: double.infinity,
            height: showSearch ? 235.h : 145.h,
            color: AppColors.primaryPurple,
            padding: EdgeInsets.only(top: 45.h, left: 30.w, right: 30.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (showBackButton) ...[
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.arrow_back_ios_new,
                              color: Colors.white, size: 18.w),
                        ),
                      ),
                      SizedBox(width: 15.w),
                    ],
                    Text(
                      title ??
                          (userName.isEmpty
                              ? 'welcome Insurance Agent!'
                              : 'welcome , $userName !'),
                      style: GoogleFonts.inter(
                        fontSize: title != null ? 18.sp : 22.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(left: showBackButton ? 45.w : 0),
                  child: Text(
                    subtitle ?? 'Rescue starts with you',
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 20.h,
          right: 20.w,
          child: Opacity(
            opacity: 0.3,
            child: Icon(
              Icons.pets,
              size: 100.w,
              color: Colors.white,
            ),
          ),
        ),
        if (showSearch)
          Positioned(
            bottom: 65.h,
            left: 30.w,
            right: 30.w,
            child: Row(
              children: [
                Builder(
                  builder: (context) => GestureDetector(
                    onTap: () {
                      if (Scaffold.of(context).hasDrawer) {
                        Scaffold.of(context).openDrawer();
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.menu,
                        color: AppColors.primaryPurple,
                        size: 24.w,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Container(
                    height: 50.h,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundGray.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(25.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        hintText: 'search',
                        hintStyle: AppTypography.caption
                            .copyWith(color: AppColors.textHint),
                        suffixIcon: Icon(Icons.search,
                            color: AppColors.textHint, size: 20.w),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class QuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const QuickActionCard(
      {super.key,
      required this.title,
      required this.icon,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 20.h),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 15.h),
        decoration: BoxDecoration(
          // Subtle beveled look with linear gradient
          gradient: LinearGradient(
            colors: [
              Colors.white,
              AppColors.backgroundGray.withValues(alpha: 0.8),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(100.r), // Stadium pill shape
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.8), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Red icon on the card directly
            Icon(icon, color: Colors.red, size: 32.w),
            SizedBox(width: 24.w),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            // White bold chevron icon
            Icon(Icons.chevron_right, color: Colors.white, size: 36.w),
          ],
        ),
      ),
    );
  }
}
