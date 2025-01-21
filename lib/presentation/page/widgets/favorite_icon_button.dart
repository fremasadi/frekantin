import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FavoriteIconButton extends StatelessWidget {
  const FavoriteIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32.sp,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.white,
          shape: const CircleBorder(),
          elevation: 0,
          padding: const EdgeInsets.all(4),
        ),
        child: const Icon(
          Icons.favorite_border,
          color: Colors.black,
          size: 22,
        ),
      ),
    );
  }
}
