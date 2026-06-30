import 'package:flutter/material.dart';
import 'package:adlease/screens/splash/splash_screen.dart';
import 'package:adlease/screens/auth/welcome_screen.dart';
import 'package:adlease/screens/auth/login_screen.dart';
import 'package:adlease/screens/auth/register_screen.dart';
import 'package:adlease/screens/auth/forgot_password_screen.dart';
import 'package:adlease/screens/home/main_navigation.dart';
import 'package:adlease/screens/ads/watch_ad_screen.dart';
import 'package:adlease/screens/ownership/select_phone_screen.dart';
import 'package:adlease/screens/profile/edit_profile_screen.dart';
import 'package:adlease/screens/wallet/withdrawal_screen.dart';
import 'package:adlease/screens/referral/referral_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String main = '/main';
  static const String watchAd = '/watch-ad';
  static const String selectPhone = '/select-phone';
  static const String editProfile = '/edit-profile';
  static const String withdrawal = '/withdrawal';
  static const String referral = '/referral';

  static Map<String, WidgetBuilder> get routes => {
        splash: (_) => const SplashScreen(),
        welcome: (_) => const WelcomeScreen(),
        login: (_) => const LoginScreen(),
        register: (_) => const RegisterScreen(),
        forgotPassword: (_) => const ForgotPasswordScreen(),
        main: (_) => const MainNavigation(),
        watchAd: (_) => const WatchAdScreen(),
        selectPhone: (_) => const SelectPhoneScreen(),
        editProfile: (_) => const EditProfileScreen(),
        withdrawal: (_) => const WithdrawalScreen(),
        referral: (_) => const ReferralScreen(),
      };
}
