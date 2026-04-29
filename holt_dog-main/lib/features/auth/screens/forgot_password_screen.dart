import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../widgets/auth_header.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleRecoverPassword() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().sendResetEmail(_emailController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is AuthInitial && _emailController.text.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reset link sent to your email!')),
          );
          context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundGray,
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                AuthHeader(
                  title: 'Forgot Password',
                  subtitle: 'Forgot Password',
                  showBackButton: true,
                  onBackPressed: () => context.pop(),
                ),
                Padding(
                  padding: EdgeInsets.all(30.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 20.h),
                      Text(
                        'Enter Mail Address Here',
                        style: AppTypography.h2.copyWith(
                          color: AppColors.textPrimary,
                          fontSize: 22.sp,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        'Enter Email Address Associated\nTo Your Account.',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 40.h),
                      CustomTextField(
                        label: 'Email :',
                        hint: 'Enter Your Email',
                        controller: _emailController,
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 50.h),
                      BlocBuilder<AuthCubit, AuthState>(
                        builder: (context, state) {
                          return CustomButton(
                            text: 'Recover Password',
                            isLoading: state is AuthLoading,
                            onPressed: _handleRecoverPassword,
                          );
                        },
                      ),
                      SizedBox(height: 40.h),
                      // Background icon placeholder
                      Opacity(
                        opacity: 0.1,
                        child: Image.asset(
                          'assets/images/onboarding2.paw.png',
                          width: 100.w,
                          color: AppColors.primaryPurple,
                        ),
                      ),
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
