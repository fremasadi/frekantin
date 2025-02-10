import 'package:e_kantin/core/constant/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/strings.dart';
import '../../../../data/models/order.dart'; // Pastikan Anda mengimpor model Order

class ReviewPage extends StatefulWidget {
  final Order order; // Terima Order sebagai parameter

  const ReviewPage({super.key, required this.order});

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  // List untuk menyimpan rating dan ulasan setiap item
  late List<int> _ratings;
  late List<TextEditingController> _reviewControllers;

  @override
  void initState() {
    super.initState();
    // Inisialisasi rating dan controller untuk setiap item
    _ratings = List<int>.filled(widget.order.orderItems.length, 0);
    _reviewControllers = List<TextEditingController>.generate(
      widget.order.orderItems.length,
      (index) => TextEditingController(),
    );
  }

  @override
  void dispose() {
    // Dispose semua controller
    for (var controller in _reviewControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: ScreenUtil().statusBarHeight,
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back,
                  size: 28.sp,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(
                width: 12.w,
              ),
              Text(
                'Ulasan Pesanan',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontFamily: 'SemiBold',
                ),
              ),
            ],
          ),
          // Menampilkan Daftar Item Pesanan
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: widget.order.orderItems.length,
              itemBuilder: (context, index) {
                final orderItem = widget.order.orderItems[index];
                return Container(
                  margin:
                      EdgeInsets.symmetric(vertical: 6.h, horizontal: 16.sp),
                  padding: EdgeInsets.all(16.sp),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12.sp),
                    border: Border.all(color: AppColors.black),
                  ),
                  child: Column(
                    children: [
                      // Informasi Produk
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: Image.network(
                              '$imageUrl/storage/${orderItem.product.image}',
                              width: 40.w,
                              height: 40.h,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  orderItem.product.name,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontFamily: 'SemiBold',
                                  ),
                                ),
                                Text(
                                  '${orderItem.quantity}x',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: AppColors.greyPrice,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_ratings[index] > 0) ...[
                            Text(
                              'Kirim',
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  fontFamily: 'SemiBold',
                                  color: AppColors.primary),
                            ),
                          ],
                        ],
                      ),
                      // Rating untuk Item Ini
                      Row(
                        children: [
                          Text(
                            'Rating:',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontFamily: 'Medium',
                            ),
                          ),
                          Row(
                            children: List.generate(5, (starIndex) {
                              return IconButton(
                                icon: Icon(
                                  starIndex < _ratings[index]
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 25.sp,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _ratings[index] = starIndex +
                                        1; // Update rating untuk item ini
                                  });
                                },
                              );
                            }),
                          ),
                        ],
                      ),
                      // Ulasan untuk Item Ini
                      if (_ratings[index] > 0) ...[
                        TextField(
                          controller: _reviewControllers[index],
                          maxLines: 3,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: AppColors.greyPrice, width: 2.0),
                              // Warna saat focused
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: AppColors.white, width: 1.0),
                              // Warna saat tidak focused
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            hintText: 'Tulis ulasan Anda di sini...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
