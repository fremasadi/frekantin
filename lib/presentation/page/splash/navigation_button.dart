import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constant/colors.dart';

class NavigationButtons extends StatelessWidget {
  final int currentPage;
  final VoidCallback nextPage;
  final VoidCallback previousPage;
  final VoidCallback skip;

  const NavigationButtons({
    required this.currentPage,
    required this.nextPage,
    required this.previousPage,
    required this.skip,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return currentPage == 2
        ? Container(
      height: 56.h,
      width: 144.w,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextButton(
        onPressed: skip,
        child: Text(
          'Masuk',
          style: TextStyle(
            fontSize: 14.sp,
            fontFamily: 'SemiBold',
            color: AppColors.white,
          ),
        ),
      ),
    )
        : Row(
      children: [
        if (currentPage != 0)
          GestureDetector(
            onTap: previousPage,
            child: CircleAvatar(
              radius: 28.sp,
              backgroundColor: AppColors.secondary,
              child: Image.asset(
                'assets/icons/ic_arrowleft.png',
                height: 20.h,
                width: 20.w,
                color: AppColors.white,
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(left: 24.0),
          child: GestureDetector(
            onTap: nextPage,
            child: CircleAvatar(
              radius: 28.sp,
              backgroundColor: AppColors.primary,
              child: Image.asset(
                'assets/icons/ic_arrowright.png',
                height: 20.h,
                width: 20.w,
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}