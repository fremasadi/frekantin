import 'dart:async'; // Perlu untuk Timer

import 'package:e_kantin/core/constant/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cart/keranjang_page.dart';
import 'home/home_page.dart';

class BasePage extends StatefulWidget {
  const BasePage({super.key});

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  int _selectedIndex = 0;
  bool _isVisible = true; // Status visibilitas navbar
  final ScrollController _scrollController = ScrollController();
  Timer? _scrollTimer; // Timer untuk mendeteksi saat scroll berhenti

  // List of screens
  final List<Widget> _screens = [
    const HomePage(), // Halaman Home
    KeranjangPage(), // Halaman Keranjang
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        // Scroll ke bawah
        setState(() {
          _isVisible = false; // Sembunyikan navbar
        });
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        // Scroll ke atas
        setState(() {
          _isVisible = true; // Tampilkan navbar
        });
      }

      _resetScrollTimer();
    });
  }

  // Fungsi untuk mereset timer setiap kali ada scroll
  void _resetScrollTimer() {
    if (_scrollTimer != null) {
      _scrollTimer!.cancel();
    }

    // Set timer untuk 2 detik
    _scrollTimer = Timer(const Duration(seconds: 1), () {
      setState(() {
        _isVisible = true; // Tampilkan kembali navbar jika scroll berhenti
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose controller saat tidak digunakan lagi
    if (_scrollTimer != null) {
      _scrollTimer!.cancel(); // Jangan lupa dispose timer
    }
    super.dispose();
  }

  // Function to handle tab selection
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Function to get the icon based on selected index
  Widget _getIcon(String assetPath, int index) {
    return Image.asset(
      assetPath,
      width: 24.w,
      height: 24.h,
      color: _selectedIndex == index
          ? AppColors.primary
          : Colors.grey, // Ubah warna berdasarkan status
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          if (notification.direction == ScrollDirection.reverse) {
            setState(() {
              _isVisible = false;
            });
          } else if (notification.direction == ScrollDirection.forward) {
            setState(() {
              _isVisible = true;
            });
          }
          _resetScrollTimer();

          return true;
        },
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar:
          _isVisible // Menampilkan atau menyembunyikan BottomNavigationBar
              ? BottomNavigationBar(
                  currentIndex: _selectedIndex,
                  onTap: _onItemTapped,
                  backgroundColor: Colors.white,
                  type: BottomNavigationBarType.fixed,
                  items: [
                    BottomNavigationBarItem(
                      icon: _getIcon('assets/icons/ic_home.png', 0),
                      label: 'Beranda',
                    ),
                    BottomNavigationBarItem(
                      icon: _getIcon('assets/icons/ic_keranjang.png', 1),
                      label: 'Keranjang',
                    ),
                    // BottomNavigationBarItem(
                    //   icon: _getIcon('assets/icons/ic_history.png', 2),
                    //   label: 'Aktivitas',
                    // ),
                  ],
                  selectedItemColor: AppColors.black,
                  selectedLabelStyle:
                      TextStyle(fontSize: 12.sp, fontFamily: 'SemiBold'),
                  unselectedLabelStyle: TextStyle(fontSize: 12.sp),
                  unselectedItemColor: Colors.grey,
                )
              : null,
    );
  }
}
