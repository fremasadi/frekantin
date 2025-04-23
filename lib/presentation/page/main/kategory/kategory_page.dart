import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/colors.dart';
import '../../../../data/models/category.dart';
import 'detail_product_kategory.dart';

class KategoryPage extends StatelessWidget {
  final List<Category> categories;

  const KategoryPage({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back,
              size: 28.sp,
            )),
        backgroundColor: AppColors.white,
        centerTitle: false,
        title: Text(
          'Aneka Kuliner',
          style: TextStyle(fontSize: 14.sp, fontFamily: 'SemiBold'),
        ),
      ),
      body: GridView.builder(
        padding: EdgeInsets.only(left: 16.sp, right: 16.sp, top: 16.sp),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 8.h,
          crossAxisSpacing: 8.w,
          childAspectRatio: 0.7,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DetailProductKategory(
                            categoryId: category.id.toString(),
                            categoryName: category.name,
                          )));
            },
            child: _buildCategoryCard(category),
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard(Category category) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16.sp),
          child: CachedNetworkImage(
            imageUrl: category.imageUrl!,
            height: 100.h,
            width: double.infinity,
            fit: BoxFit.fill,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          category.name,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
