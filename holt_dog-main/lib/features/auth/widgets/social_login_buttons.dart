import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/constants/app_colors.dart';

class SocialLoginButtons extends StatelessWidget {
  const SocialLoginButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _socialIcon(FontAwesomeIcons.google, AppColors.googleBlue),
        SizedBox(width: 20.w),
        _socialIcon(FontAwesomeIcons.facebook, AppColors.facebookBlue),
        SizedBox(width: 20.w),
        _socialIcon(FontAwesomeIcons.instagram, AppColors.instagramPink),
      ],
    );
  }

  Widget _socialIcon(IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: icon == FontAwesomeIcons.instagram
          ? ShaderMask(
              shaderCallback: (bounds) =>
                  AppColors.instagramGradient.createShader(bounds),
              child: Icon(icon, color: Colors.white, size: 28.w),
            )
          : Icon(icon, color: color, size: 28.w),
    );
  }
}
