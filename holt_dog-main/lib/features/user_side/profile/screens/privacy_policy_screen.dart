import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/custom_button.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: Stack(
        children: [
          // Background Decorations (Paw Prints)
          Positioned(
            top: -20,
            right: -20,
            child: Opacity(
              opacity: 0.1,
              child: Transform.rotate(
                angle: 0.5,
                child: Image.asset(
                  'assets/images/onboarding2.paw.png',
                  width: 150.w,
                  color: AppColors.primaryHotPink,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -30,
            child: Opacity(
              opacity: 0.1,
              child: Transform.rotate(
                angle: -0.5,
                child: Image.asset(
                  'assets/images/onboarding2.paw.png',
                  width: 120.w,
                  color: AppColors.primaryHotPink,
                ),
              ),
            ),
          ),

          // Content
          Column(
            children: [
              // Header
              _buildHeader(context),

              // Scrolling Content
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('1. Introduction :'),
                      _buildSectionBody(
                          'We respect your privacy and are committed to protecting your personal data. '
                          'This Privacy Policy explains how we collect, use, and safeguard your information when you use our application.'),

                      SizedBox(height: 24.h),
                      _buildSectionTitle('2. Information We Collect :'),

                      // Location Sub-section
                      _buildInfoItem(
                        icon: Icons.location_on_rounded,
                        color: AppColors.primaryMagenta,
                        title: 'Location (GPS)',
                        body: 'We may collect your device location to:\n'
                            '• Help identify and report stray dogs\n'
                            '• Provide accurate rescue locations\n'
                            '• Improve nearby services',
                      ),

                      // Camera Sub-section
                      _buildInfoItem(
                        icon: Icons.camera_alt_rounded,
                        color: AppColors.primaryHotPink,
                        title: 'Camera Access',
                        body: 'We use your camera to:\n'
                            '• Allow you to capture photos of dogs in need\n'
                            '• Upload images for reporting and rescue purposes',
                      ),

                      // Contacts Sub-section
                      _buildInfoItem(
                        icon: Icons.contacts_rounded,
                        color: AppColors.primaryPurple,
                        title: 'Contacts',
                        body: 'We may access your contacts to:\n'
                            '• Help you share reports with friends or volunteers\n'
                            '• Enable faster communication during rescue cases',
                      ),

                      SizedBox(height: 24.h),
                      _buildSectionTitle('3. How We Use Your Data :'),
                      _buildSectionBody('We use your data to:\n'
                          '• Improve user experience\n'
                          '• Provide rescue services\n'
                          '• Analyze app performance\n'
                          '• Ensure safety and prevent misuse'),

                      SizedBox(height: 24.h),
                      _buildSectionTitle('4. Data Sharing :'),
                      _buildSectionBody('We do NOT sell your data.\n'
                          'We may share data with:\n'
                          '• Rescue organizations\n'
                          '• Service providers (for app functionality)'),

                      SizedBox(height: 24.h),
                      _buildSectionTitle('5. Data Security :'),
                      _buildSectionBody(
                          'We take appropriate security measures to protect your data from unauthorized access.'),

                      SizedBox(height: 24.h),
                      _buildSectionTitle('6. Your Rights :'),
                      _buildSectionBody('You can:\n'
                          '• Deny permissions (Camera, Location, Contacts)\n'
                          '• Request deletion of your data\n'
                          '• Stop using the app anytime'),

                      SizedBox(height: 24.h),
                      _buildSectionTitle('7. Updates :'),
                      _buildSectionBody(
                          'We may update this policy. Changes will be posted inside the app.'),

                      SizedBox(height: 100.h), // Space for bottom buttons
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bottom Buttons
          Positioned(
            bottom: 30,
            left: 24.w,
            right: 24.w,
            child: Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Decline',
                    isSecondary: true,
                    onPressed: () => context.pop(),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: CustomButton(
                    text: 'Accept',
                    onPressed: () => context.pop(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.only(top: 60.h, bottom: 20.h, left: 24.w, right: 24.w),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () => context.pop(),
              ),
              const Spacer(),
              Icon(Icons.lock_rounded,
                  color: AppColors.primaryMagenta, size: 24.sp),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            'Privacy & Policy',
            style: AppTypography.h1.copyWith(
              color: AppColors.textPrimary,
              fontSize: 28.sp,
            ),
          ),
          Container(
            height: 4.h,
            width: 40.w,
            margin: EdgeInsets.only(top: 8.h),
            decoration: BoxDecoration(
              color: AppColors.primaryHotPink,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Text(
        title,
        style: AppTypography.h3.copyWith(
          color: AppColors.primaryHotPink,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSectionBody(String body) {
    return Text(
      body,
      style: AppTypography.bodyMedium.copyWith(
        color: AppColors.textSecondary,
        height: 1.5,
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required Color color,
    required String title,
    required String body,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: color, size: 22.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  body,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
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
