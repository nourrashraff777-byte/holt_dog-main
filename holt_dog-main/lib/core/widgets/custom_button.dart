import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../constants/app_styles.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isSecondary;
  final double? width;
  final double? height;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSecondary ? AppColors.backgroundWhite : AppColors.primaryMagenta,
        foregroundColor: isSecondary ? AppColors.primaryPurple : AppColors.textOnPurple,
        elevation: 0,
        side: isSecondary ? const BorderSide(color: AppColors.primaryPurple) : null,
        minimumSize: Size(width ?? double.infinity, height ?? 56.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppStyles.radiusXL),
        ),
      ),
      child: isLoading
          ? SizedBox(
              height: 24.h,
              width: 24.w,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: isSecondary ? AppColors.primaryPurple : AppColors.textOnPurple,
              ),
            )
          : Text(
              text,
              style: isSecondary
                  ? AppTypography.buttonLabel.copyWith(color: AppColors.primaryPurple)
                  : AppTypography.buttonLabel,
            ),
    );
  }
}
