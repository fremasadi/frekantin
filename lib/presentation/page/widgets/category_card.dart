import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.image,
    required this.category,
  });

  final String image;
  final String category;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16.0.sp),
      child: Column(
        children: [
          Container(
            height: 60.h,
            width: 60.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                fit: BoxFit.fill,
                image: CachedNetworkImageProvider(image),
              ),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            category,
            style: TextStyle(fontSize: 12.sp, fontFamily: 'Medium'),
          ),
        ],
      ),
    );
  }
}
