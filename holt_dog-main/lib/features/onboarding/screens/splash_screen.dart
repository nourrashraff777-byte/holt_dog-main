import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holt_dog/features/charity_side/screens/charity_home_screen.dart';
import 'package:holt_dog/features/doctor_side/screens/doctor_home_screen.dart';
import 'package:holt_dog/features/insurance_side/screens/insurance_home_screen.dart';
import 'package:holt_dog/features/retailer_side/screens/retailer_home_screen.dart';
import 'package:holt_dog/features/user_side/user_home/screens/user_home_screen.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/routes/app_router.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Wait for at least 3 seconds for the splash screen to show
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;
    
    final authCubit = context.read<AuthCubit>();
    final state = authCubit.state;
    
    if (state is AuthInitial || state is AuthLoading) {
      // If still loading, wait for the next state
      authCubit.stream.listen((newState) {
        if (!mounted) return;
        if (newState is Authenticated) {
          _navigateByRole(newState.user.role);
        } else if (newState is Unauthenticated || newState is AuthError) {
          context.go(AppRouter.onboarding);
        }
      });
    } else {
      // Already finished loading
      if (state is Authenticated) {
        _navigateByRole(state.user.role);
      } else {
        context.go(AppRouter.onboarding);
      }
    }
  }

  void _navigateByRole(String role) {
    switch (role) {
      case 'insurance_agent':
      case 'Insurance Agent':
        context.go(InsuranceHomeScreen.routeName);
        break;
      case 'retailer':
      case 'Retailer':
        context.go(RetailerHomeScreen.routeName);
        break;
      case 'charity':
        context.go(CharityHomeScreen.routeName);
        break;
      case 'doctor':
        context.go(DoctorHomeScreen.routeName);
        break;
      default:
        context.go(UserHomeScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/backgroubg.png',
              fit: BoxFit.cover,
            ),
          ),
          // Logo in the Center
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Responsive Logo
                Image.asset(
                  'assets/images/logo.png',
                  height: 300.h,
                ),
              ],
            ),
          ),
          // Loading Indicator and Branding at the Bottom
          Positioned(
            bottom: 30.h,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  'Smart Rescue',
                  style: AppTypography.h2.copyWith(
                    color: AppColors.primaryPurple,
                    fontSize: 32.sp,
                  ),
                ),
                SizedBox(height: 30.h),
                const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryMagenta),
                ),
                SizedBox(height: 15.h),
                Text(
                  'Loading....',
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
