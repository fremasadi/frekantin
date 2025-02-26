import 'package:e_kantin/presentation/page/splash/skip_button.dart';
import 'package:e_kantin/presentation/page/splash/splash_content.dart';
import 'package:flutter/material.dart';

import '../../../core/router/app_router.dart';
import 'dots_indicator.dart';
import 'navigation_button.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  late PageController pageController;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void onPageChanged(int index) {
    setState(() {
      currentPage = index;
    });
  }

  void skip() {
    Navigator.pushNamed(context, AppRouter.signIn);
  }

  void nextPage() {
    pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void previousPage() {
    pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: pageController,
            onPageChanged: onPageChanged,
            children: const [
              SplashContent(
                image: 'assets/images/img_splash01.jpg',
                title: 'Selamat datang di Kantin Nguldi!',
                description: 'Solusi Terbaik untuk Pemesanan Makakan Dikantin',
              ),
              SplashContent(
                image: 'assets/images/img_splash01.jpg',
                title: 'Aplikasi Berkualitas',
                description: 'Menyediakan berbagai pembayaran',
              ),
              SplashContent(
                image: 'assets/images/img_splash01.jpg',
                title: 'Fitur Unggulan',
                description:
                    'Anda tidak perlu mengantri tinggal memesan dan menunggu dimeja',
              ),
            ],
          ),
          SkipButton(currentPage: currentPage, skip: skip),
          Positioned(
            bottom: 40,
            left: 20,
            child: DotsIndicator(currentPage: currentPage, totalDots: 3),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: NavigationButtons(
              currentPage: currentPage,
              nextPage: nextPage,
              previousPage: previousPage,
              skip: skip,
            ),
          ),
        ],
      ),
    );
  }
}
