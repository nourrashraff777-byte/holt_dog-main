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

class CharityNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  /// Total items in marketplace cart; shown on the Market tab when > 0.
  final int marketCartBadgeCount;

  const CharityNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.marketCartBadgeCount = 0,
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
                _buildNavItem(0, Icons.payments, 'Donate', 15.h),
                _buildNavItem(1, Icons.home, 'Home', 30.h),
                _buildNavItem(2, Icons.analytics, 'Results', 30.h),
                _buildNavItem(
                  3,
                  Icons.shopping_bag,
                  'Market',
                  15.h,
                  badgeCount: marketCartBadgeCount,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    String label,
    double bottomMargin, {
    int badgeCount = 0,
  }) {
    bool isSelected = currentIndex == index;
    final iconColor = isSelected
        ? AppColors.primaryPurple
        : AppColors.primaryPurple.withValues(alpha: 0.7);
    final iconSize = isSelected ? 32.w : 28.w;

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
              child: badgeCount > 0
                  ? Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        Icon(icon, color: iconColor, size: iconSize),
                        Positioned(
                          right: -4.w,
                          top: -4.h,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: badgeCount > 9 ? 4.w : 5.w,
                              vertical: 2.h,
                            ),
                            decoration: const BoxDecoration(
                              color: Color(0xFF9E9E9E),
                              shape: BoxShape.circle,
                            ),
                            constraints: BoxConstraints(minWidth: 18.w),
                            alignment: Alignment.center,
                            child: Text(
                              badgeCount > 99 ? '99+' : '$badgeCount',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Icon(icon, color: iconColor, size: iconSize),
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
