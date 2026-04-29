import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/routes/app_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      body: SafeArea(
        child: Stack(
          children: [
            PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: [
                _OnboardingPage(
                  graphic: Container(
                    padding: EdgeInsets.all(40.w),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundWhite,
                      shape: BoxShape.circle,
                      boxShadow: AppStyles.softShadow,
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      size: 100.w,
                      color: AppColors.primaryMagenta,
                    ),
                  ),
                  title: 'Spot a dog in need?',
                  subtitle: 'Take a photo and help save a life.',
                  description:
                      'Our App Makes It Easy To Report Stray Dogs That Need Help, Just Point Your Camera And Capture The Moment.',
                  isSecondaryPage: false,
                ),
                _OnboardingPage(
                  graphic: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(24.w),
                        decoration: const BoxDecoration(
                          color: AppColors.backgroundWhite,
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/images/dog_onboarding2.png',
                          height: 100.h,
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSmallWhiteBox(
                              'assets/images/onboarding2.paw.png'),
                          SizedBox(width: 15.w),
                          _buildSmallWhiteBox(
                              'assets/images/heart_onboarding2..png'),
                          SizedBox(width: 15.w),
                          _buildSmallWhiteBox(
                              'assets/images/dog_bone_onboarding2..png'),
                        ],
                      ),
                    ],
                  ),
                  title: 'AI-Powered Analysis',
                  subtitle: 'Breed Detection And Health Analysis',
                  description:
                      'Instantly identify breeds and get immediate health insights to provide the best care for rescued animals.',
                  isSecondaryPage: true,
                ),
              ],
            ),
            _buildTopNavigation(),
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNavigation() {
    return Positioned(
      top: 10.h,
      right: 15.w,
      child: TextButton(
        onPressed: () => context.go(AppRouter.login),
        child: Text(
          'Skip',
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: _currentPage == 0
                ? AppColors.textPrimary
                : AppColors.textOnPurple,
          ),
        ),
      ),
    );
  }

  Widget _buildSmallWhiteBox(String asset) {
    return Container(
      height: 44.w,
      width: 44.w,
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12.r),
      ),
      padding: EdgeInsets.all(10.w),
      child: Image.asset(asset, fit: BoxFit.contain),
    );
  }

  Widget _buildBottomNavigation() {
    return Positioned(
      bottom: 40.h,
      left: 30.w,
      right: 30.w,
      child: Column(
        children: [
          _buildIndicators(),
          SizedBox(height: 48.h),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        2,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          height: 10.h,
          width: _currentPage == index ? 24.w : 10.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: _currentPage == index
                ? (_currentPage == 1
                    ? AppColors.primaryMagenta
                    : AppColors.primaryMagenta)
                : (_currentPage == 1
                    ? AppColors.backgroundWhite.withValues(alpha: 0.4)
                    : AppColors.borderLight),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _currentPage == 1
                  ? AppColors.primaryMagenta
                  : AppColors.borderLight,
              foregroundColor: _currentPage == 1
                  ? AppColors.textOnPurple
                  : AppColors.textPrimary,
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              minimumSize: Size(0, 56.h),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r)),
            ),
            onPressed: _currentPage > 0
                ? () {
                    _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut);
                  }
                : null,
            child: FittedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_currentPage == 1) ...[
                    const Icon(Icons.arrow_back_rounded, size: 20),
                    SizedBox(width: 8.w),
                  ],
                  const Text('Previous'),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 20.w),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _currentPage == 1
                  ? AppColors.backgroundWhite
                  : AppColors.primaryMagenta,
              foregroundColor: _currentPage == 1
                  ? AppColors.primaryPurple
                  : AppColors.textOnPurple,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              minimumSize: Size(0, 56.h),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r)),
            ),
            onPressed: () {
              if (_currentPage < 1) {
                _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut);
              } else {
                context.go(AppRouter.login);
              }
            },
            child: FittedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Next'),
                  if (_currentPage == 0) ...[
                    SizedBox(width: 8.w),
                    const Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final Widget graphic;
  final String title;
  final String subtitle;
  final String description;
  final bool isSecondaryPage;

  const _OnboardingPage({
    required this.graphic,
    required this.title,
    required this.subtitle,
    required this.description,
    this.isSecondaryPage = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor =
        isSecondaryPage ? AppColors.primaryPurple : AppColors.backgroundGray;
    final contentColor =
        isSecondaryPage ? AppColors.textOnPurple : AppColors.textPrimary;

    return Container(
      color: bgColor,
      padding: EdgeInsets.symmetric(horizontal: 30.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 40.h),
          graphic,
          SizedBox(height: 60.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.h2.copyWith(
              color: contentColor,
              fontSize: 26.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTypography.subHeadline.copyWith(
              color: isSecondaryPage
                  ? AppColors.backgroundWhite
                  : AppColors.primaryMagenta,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            description,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: isSecondaryPage
                  ? AppColors.backgroundWhite.withValues(alpha: 0.8)
                  : AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          SizedBox(height: 140.h),
        ],
      ),
    );
  }
}
