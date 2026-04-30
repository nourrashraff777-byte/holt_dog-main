import 'package:go_router/go_router.dart';
import 'package:holt_dog/features/charity_side/screens/charity_home_screen.dart';
import 'package:holt_dog/features/doctor_side/screens/doctor_home_screen.dart';
import 'package:holt_dog/features/donation/screens/donation_screen.dart';
import 'package:holt_dog/features/donation/screens/add_card_screen.dart';
import 'package:holt_dog/features/donation/screens/e_wallet_screen.dart';
import 'package:holt_dog/features/insurance_side/screens/insurance_home_screen.dart';
import 'package:holt_dog/features/other_pages/payment_processing_page.dart';
import 'package:holt_dog/features/other_pages/payment_success_page.dart';
import 'package:holt_dog/features/other_pages/payment_failed_page.dart';
import 'package:holt_dog/features/retailer_side/screens/retailer_home_screen.dart';
import 'package:holt_dog/features/user_side/reports/screens/my_report_screen.dart';
import '../../features/onboarding/screens/splash_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/verify_otp_screen.dart';
import '../../features/auth/screens/reset_password_screen.dart';
import '../../features/user_side/profile/screens/privacy_policy_screen.dart';
import '../../features/user_side/user_home/screens/user_home_screen.dart';

class AppRouter {
  // Route Names
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String verifyOtp = '/verify-otp';
  static const String resetPassword = '/reset-password';
  static const String privacyPolicy = '/privacy-policy';
  static const String userHome = '/userHome';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: signup,
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: verifyOtp,
        name: 'verifyOtp',
        builder: (context, state) => const VerifyOTPScreen(),
      ),
      GoRoute(
        path: resetPassword,
        name: 'resetPassword',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: privacyPolicy,
        name: 'privacyPolicy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: UserHomeScreen.routeName,
        name: 'userHome',
        builder: (context, state) => const UserHomeScreen(),
      ),
      GoRoute(
        path: DonationScreen.routeName,
        name: 'donation',
        builder: (context, state) {
          final bool isBackButtonVisible = state.extra as bool? ?? false;
          return DonationScreen(isBackButtonVisible: isBackButtonVisible);
        },
      ),
      GoRoute(
        path: MyReportScreen.routeName,
        name: 'myReportScreen',
        builder: (context, state) => const MyReportScreen(),
      ),
      GoRoute(
        path: AddCardScreen.routeName,
        name: 'addCardScreen',
        builder: (context, state) => const AddCardScreen(),
      ),
      GoRoute(
        path: EWalletScreen.routeName,
        name: 'eWalletScreen',
        builder: (context, state) => const EWalletScreen(),
      ),
      GoRoute(
        path: PaymentProcessingScreen.routeName,
        name: 'paymentProcessing',
        builder: (context, state) => const PaymentProcessingScreen(),
      ),
      GoRoute(
        path: PaymentSuccessScreen.routeName,
        name: 'paymentSuccess',
        builder: (context, state) => const PaymentSuccessScreen(),
      ),
      GoRoute(
        path: PaymentFailedScreen.routeName,
        name: 'paymentFailed',
        builder: (context, state) => const PaymentFailedScreen(),
      ),
      GoRoute(
        path: DoctorHomeScreen.routeName,
        name: 'doctorHome',
        builder: (context, state) => const DoctorHomeScreen(),
      ),
      GoRoute(
        path: CharityHomeScreen.routeName,
        name: 'charityHome',
        builder: (context, state) => const CharityHomeScreen(),
      ),
      GoRoute(
        path: RetailerHomeScreen.routeName,
        name: 'retailerHome',
        builder: (context, state) => const RetailerHomeScreen(),
      ),
      GoRoute(
        path: InsuranceHomeScreen.routeName,
        name: 'insuranceHome',
        builder: (context, state) => const InsuranceHomeScreen(),
      ),
    ],
  );
}
