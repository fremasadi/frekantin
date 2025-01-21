import 'package:e_kantin/presentation/page/main/base_page.dart';
import 'package:e_kantin/presentation/page/splash/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreenLoading extends StatefulWidget {
  const SplashScreenLoading({super.key});

  @override
  State<SplashScreenLoading> createState() => _SplashScreenLoadingState();
}

class _SplashScreenLoadingState extends State<SplashScreenLoading> {
  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  void checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => BasePage()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SplashView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Menampilkan loading
      ),
    );
  }
}
