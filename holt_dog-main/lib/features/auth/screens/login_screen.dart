import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:holt_dog/features/charity_side/screens/charity_home_screen.dart';
import 'package:holt_dog/features/doctor_side/screens/doctor_home_screen.dart';
import 'package:holt_dog/features/insurance_side/screens/insurance_home_screen.dart';
import 'package:holt_dog/features/retailer_side/screens/retailer_home_screen.dart';
import 'package:holt_dog/features/user_side/user_home/screens/user_home_screen.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../widgets/auth_header.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedUserType = 'User';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    _navigateBySelectedUserType();
    // if (_formKey.currentState!.validate()) {
    //   context.read<AuthCubit>().login(
    //         _emailController.text.trim(),
    //         _passwordController.text.trim(),
    //       );
    // }
  }

  void _navigateBySelectedUserType() {
    log('selectedUserType: $_selectedUserType');
    switch (_selectedUserType) {
      case 'Insurance Agent':
        context.go(InsuranceHomeScreen.routeName);
        break;
      case 'Retailer':
        context.go(RetailerHomeScreen.routeName);
        break;
      case 'Charity':
        context.go(CharityHomeScreen.routeName);
        break;
      case 'Doctor':
        context.go(DoctorHomeScreen.routeName);
        break;
      case 'User':
      default:
        context.go(UserHomeScreen.routeName);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          _navigateBySelectedUserType();
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundGray,
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const AuthHeader(
                  title: 'Welcome Back !',
                  subtitle: 'Login',
                ),
                Padding(
                  padding: EdgeInsets.all(AppStyles.spaceL.w),
                  child: Column(
                    children: [
                      SizedBox(height: 30.h),
                      CustomTextField(
                        label: 'Email :',
                        hint: 'Enter Your Email',
                        controller: _emailController,
                        prefixIcon: null,
                        suffixIcon: const Icon(Icons.email_outlined,
                            color: AppColors.textSecondary),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20.h),
                      CustomTextField(
                        label: 'Password :',
                        hint: 'Enter Your Password',
                        controller: _passwordController,
                        isPassword: true,
                        prefixIcon: null,
                        suffixIcon: const Icon(Icons.lock_outline,
                            color: AppColors.textSecondary),
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 30.h),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedUserType,
                        decoration: InputDecoration(
                          labelText: 'Login as',
                          labelStyle: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: const BorderSide(
                              color: AppColors.borderLight,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: const BorderSide(
                              color: AppColors.primaryMagenta,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 14.h,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'User', child: Text('User')),
                          DropdownMenuItem(
                              value: 'Doctor', child: Text('Doctor')),
                          DropdownMenuItem(
                              value: 'Charity', child: Text('Charity')),
                          DropdownMenuItem(
                              value: 'Retailer', child: Text('Retailer')),
                          DropdownMenuItem(
                              value: 'Insurance Agent',
                              child: Text('Insurance Agent')),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _selectedUserType = value);
                        },
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () =>
                              context.push(AppRouter.forgotPassword),
                          child: Text(
                            'Forgot Password ?',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.primaryMagenta,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Don\'t Have An Account ? ',
                            style: AppTypography.bodyMedium,
                          ),
                          GestureDetector(
                            onTap: () => context.push(AppRouter.signup),
                            child: Text(
                              'Sign Up',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.primaryMagenta,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 40.h),
                      BlocBuilder<AuthCubit, AuthState>(
                        builder: (context, state) {
                          return CustomButton(
                            text: 'Login',
                            isLoading: state is AuthLoading,
                            onPressed: _handleLogin,
                          );
                        },
                      ),
                      SizedBox(height: 20.h),
                      GestureDetector(
                        onTap: () => context.push(AppRouter.privacyPolicy),
                        child: Text(
                          'Privacy Policy',
                          style: AppTypography.bodySmall.copyWith(
                            decoration: TextDecoration.underline,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      // SizedBox(height: 20.h),
                      // TextButton(
                      //   onPressed: () => context.go(AppRouter.home),
                      //   child: Text(
                      //     'Skip to Home (Test Only)',
                      //     style: AppTypography.caption.copyWith(
                      //       color: AppColors.primaryMagenta.withValues(alpha:0.5),
                      //       decoration: TextDecoration.underline,
                      //     ),
                      //   ),
                      // ),
                      SizedBox(height: 10.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
