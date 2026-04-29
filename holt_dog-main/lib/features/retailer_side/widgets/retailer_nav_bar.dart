import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';

class NavCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, size.height * 0.5);

    path.quadraticBezierTo(
      size.width / 2,
      -size.height * 0.1,
      size.width,
      size.height * 0.5,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class RetailerNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const RetailerNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110.h,
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // The Arched Purple Background
          ClipPath(
            clipper: NavCurveClipper(),
            child: Container(
              height: 120.h, // Increased for smooth clip
              width: double.infinity,
              color: AppColors.primaryPurple,
            ),
          ),

          // Navigation Items with animated indicators
          Positioned(
            left: 0,
            right: 0,
            bottom: 3.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildNavItem(0, Icons.shopping_cart_outlined, 'Market', 30.h),
                _buildNavItem(1, Icons.receipt_long_outlined, 'Orders', 30.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      int index, IconData icon, String label, double bottomMargin) {
    bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomMargin),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated Selection Indicator Container
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.all(isSelected ? 14.w : 10.w),
              decoration: BoxDecoration(
                // Active: Pure White with Glow, Inactive: Classic Light Gray
                color: isSelected ? Colors.white : const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(15.r),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.5),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? AppColors.primaryPurple
                    : AppColors.primaryPurple.withValues(alpha: 0.7),
                size: isSelected ? 32.w : 28.w,
              ),
            ),
            SizedBox(height: 4.h),
            // Label with subtle bold change
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: AppTypography.caption.copyWith(
                color: Colors.white,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
                fontSize: 13.sp,
                letterSpacing: isSelected ? 0.5 : 0.2,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
