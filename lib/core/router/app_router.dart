import 'package:e_kantin/presentation/page/auth/forgot_password.dart';
import 'package:e_kantin/presentation/page/auth/signin_page.dart';
import 'package:e_kantin/presentation/page/main/base_page.dart';
import 'package:e_kantin/presentation/page/main/history/history_page.dart';
import 'package:e_kantin/presentation/page/main/home/home_page.dart';
import 'package:e_kantin/presentation/page/main/home/search_page.dart';
import 'package:e_kantin/presentation/page/main/profile/profile_page.dart';
import 'package:e_kantin/presentation/page/payment/selectpayment_page.dart';
import 'package:e_kantin/presentation/page/splash/splash_loading.dart';
import 'package:e_kantin/presentation/page/splash/splash_page.dart';
import 'package:flutter/material.dart';

import '../../presentation/page/auth/signup_page.dart';
import '../error/exceptions.dart';

class AppRouter {
  static const String checkLog = '/checkLog';
  static const String splash = '/splash';

  //main menu
  static const String main = '/';
  static const String home = '/home';
  static const String searchProduct = '/search';
  static const String payment = '/payment';
  static const String selectPayment = '/select-payment';
  static const String history = '/history';
  static const String setting = '/setting';

  //authentication
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String forgotPassword = '/forgot-password';

  static Route<dynamic> onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case checkLog:
        return MaterialPageRoute(builder: (_) => const SplashScreenLoading());
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashView());
      case main:
        return MaterialPageRoute(builder: (_) => const BasePage());
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case signIn:
        return MaterialPageRoute(builder: (_) => const SignInPage());
      case signUp:
        return MaterialPageRoute(builder: (_) => const SignUpPage());
      case setting:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case selectPayment:
        return MaterialPageRoute(builder: (_) => const SelectpaymentPage());
      case history:
        return MaterialPageRoute(builder: (_) => const HistoryPage());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPassword());
      case searchProduct:
        return MaterialPageRoute(builder: (_) => const SearchPage());
      default:
        throw const RouteException('Route not found!');
    }
  }
}
