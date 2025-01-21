import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constant/colors.dart';

class RoundedCard extends StatelessWidget {
  const RoundedCard(
      {super.key, required this.title, required this.onTap, this.icon});

  final String title;
  final VoidCallback onTap;
  final IconData? icon; // Tambahkan ikon opsional

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(left: 10.sp),
        decoration: BoxDecoration(
          color: AppColors.white1,
          borderRadius: BorderRadius.circular(16.sp),
          border: Border.all(color: AppColors.greyLoading),
        ),
        padding: EdgeInsets.symmetric(vertical: 4.5.sp, horizontal: 12.sp),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 10.sp, fontFamily: 'SemiBold'),
            ),
            if (icon != null) // Tampilkan ikon jika ada
              Padding(
                padding: EdgeInsets.only(left: 4.0.sp),
                child: Icon(
                  icon,
                  size: 22.sp,
                  color: AppColors.black, // Warna ikon, sesuaikan jika perlu
                ),
              ),
          ],
        ),
      ),
    );
  }
}
