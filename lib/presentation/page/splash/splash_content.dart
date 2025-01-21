import 'package:e_kantin/core/constant/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashContent extends StatelessWidget {
  final String image;
  final String title;
  final String description;

  const SplashContent({
    super.key,
    required this.image,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 80.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.sp),
              child: Image.asset(
                image,
                height: 420.h,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            title,
            style: TextStyle(
                fontSize: 16.sp,
                fontFamily: 'Bold',
                color: AppColors.secondary),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10.h),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 35),
            child: Text(
              description,
              style: TextStyle(fontSize: 12.sp),
              textAlign: TextAlign.center,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
