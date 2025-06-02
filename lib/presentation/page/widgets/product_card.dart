import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constant/colors.dart';
import '../../../data/models/product.dart';
import '../../bloc/review/review_bloc.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback onPress;

  const ProductCard({
    super.key,
    required this.product,
    required this.onPress,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isSellerActive = widget.product.seller?.isActive == 1;

    return ColorFiltered(
      colorFilter: isSellerActive
          ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
          : const ColorFilter.matrix(<double>[
              0.2126,
              0.7152,
              0.0722,
              0,
              0,
              0.2126,
              0.7152,
              0.0722,
              0,
              0,
              0.2126,
              0.7152,
              0.0722,
              0,
              0,
              0,
              0,
              0,
              1,
              0,
            ]),
      child: Container(
        height: 250.h,
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 12.sp),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.sp),
          boxShadow: [
            BoxShadow(
              color: AppColors.grey,
              spreadRadius: 2,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.sp)),
              child: Image.network(
                widget.product.image!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200.h,
              ),
            ),
            Positioned(
              top: 210.sp,
              left: 15.sp,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: widget.onPress,
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(16.sp),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: 4.sp,
                            horizontal: 12.sp,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 16.sp,
                                color: AppColors.white,
                              ),
                              SizedBox(width: 4.sp),
                              Text(
                                widget.product.averageRating.toStringAsFixed(1),
                                // ✅ Fix disini
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.white,
                                  fontFamily: 'SemiBold',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${widget.product.name} - ${widget.product.seller!.name}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.black,
                      fontFamily: 'SemiBold',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
