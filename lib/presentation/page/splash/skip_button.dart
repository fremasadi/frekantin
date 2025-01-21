import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constant/colors.dart';

class SkipButton extends StatelessWidget {
  final int currentPage;
  final VoidCallback skip;

  const SkipButton({required this.currentPage, required this.skip, super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).size.width * .1,
      right: 0,
      child: (currentPage == 0 || currentPage == 1)
          ? TextButton(
        onPressed: skip,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 6.sp, horizontal: 12.sp),
          decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(16.sp)),
          child: Row(
            children: [
              Text(
                'Lewati',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: 'Medium',
                  color: AppColors.white,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Image.asset(
                  'assets/icons/ic_arrowright.png',
                  height: 18.h,
                  width: 18.h,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      )
          : const SizedBox(),
    );
  }
}