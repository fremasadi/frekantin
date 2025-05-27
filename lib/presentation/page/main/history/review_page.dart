import 'package:e_kantin/core/constant/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constant/strings.dart';
import '../../../../data/models/order.dart';
import '../../../bloc/review/review_bloc.dart'; // Pastikan Anda mengimpor model Order

class ReviewPage extends StatefulWidget {
  final Order order; // Terima Order sebagai parameter

  const ReviewPage({super.key, required this.order});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  // List untuk menyimpan rating dan ulasan setiap item
  late List<int> _ratings;
  late List<TextEditingController> _reviewControllers;
  late Map<int, bool> _reviewStatus; // Menyimpan status review per productId
  late Map<int, ReviewChecked>
      _reviewData; // Menyimpan data ulasan per productId

  @override
  void initState() {
    super.initState();
    _ratings = List<int>.filled(widget.order.orderItems.length, 0);
    _reviewControllers = List<TextEditingController>.generate(
      widget.order.orderItems.length,
      (index) => TextEditingController(),
    );
    _reviewStatus = {}; // Inisialisasi map untuk status review
    _reviewData = {}; // Inisialisasi map untuk data ulasan

    // Panggil event CheckReviewStatus untuk setiap produk
    for (var orderItem in widget.order.orderItems) {
      context.read<ReviewBloc>().add(
            CheckReviewStatus(
              orderItemId: orderItem.id,
              productId: orderItem.product.id,
            ),
          );
    }
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
    return BlocConsumer<ReviewBloc, ReviewState>(
      listener: (context, state) {
        // Handle state ReviewSubmitSuccess
        if (state is ReviewSubmitSuccess) {
          // Refresh halaman atau perbarui data
          for (var orderItem in widget.order.orderItems) {
            context.read<ReviewBloc>().add(
                  CheckReviewStatus(
                    orderItemId: orderItem.id,
                    productId: orderItem.product.id,
                  ),
                );
          }

          // Tampilkan pesan sukses (opsional)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ulasan berhasil dikirim!'),
              backgroundColor: Colors.green,
            ),
          );
        }

        // Handle state ReviewError (opsional)
        if (state is ReviewError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
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
                    return BlocBuilder<ReviewBloc, ReviewState>(
                      builder: (context, state) {
                        // Update status review jika state adalah ReviewChecked
                        if (state is ReviewChecked &&
                            state.productId == orderItem.product.id) {
                          _reviewStatus[orderItem.product.id] =
                              state.isReviewed;
                          _reviewData[orderItem.product.id] =
                              state; // Simpan data ulasan
                        }

                        // Jika produk sudah diulas, tampilkan rating dan komentar
                        if (_reviewStatus[orderItem.product.id] == true) {
                          final review = _reviewData[orderItem.product.id];
                          if (review != null) {
                            return Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 6.h, horizontal: 16.sp),
                              padding: EdgeInsets.all(16.sp),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(12.sp),
                                border: Border.all(color: AppColors.black),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.r),
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                    ],
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    'Anda sudah memberikan ulasan:',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: AppColors.greyPrice,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  // Tampilkan rating (bintang)
                                  Row(
                                    children: List.generate(5, (starIndex) {
                                      return Icon(
                                        starIndex < (review.rating ?? 0)
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.amber,
                                        size: 20.sp,
                                      );
                                    }),
                                  ),
                                  SizedBox(height: 4.h),
                                  // Tampilkan komentar
                                  Text(
                                    review.comment ?? '',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: AppColors.black,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        }

                        // Jika belum diulas, tampilkan form ulasan
                        return Container(
                          margin: EdgeInsets.symmetric(
                              vertical: 6.h, horizontal: 16.sp),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                  // Tombol Kirim (jika rating > 0)
                                  if (_ratings[index] > 0) ...[
                                    TextButton(
                                      onPressed: state is ReviewLoading
                                          ? null
                                          : () {
                                              context.read<ReviewBloc>().add(
                                                    SubmitReview(
                                                      orderId: int.parse(
                                                          orderItem.orderId
                                                              as String),
                                                      productId:
                                                          orderItem.product.id,
                                                      rating: _ratings[index],
                                                      comment:
                                                          _reviewControllers[
                                                                  index]
                                                              .text,
                                                      image: null,
                                                    ),
                                                  );
                                            },
                                      child: state is ReviewLoading
                                          ? SizedBox(
                                              width: 12.sp,
                                              height: 12.sp,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: AppColors.primary,
                                              ),
                                            )
                                          : Text(
                                              'Kirim',
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                fontFamily: 'SemiBold',
                                                color: AppColors.primary,
                                              ),
                                            ),
                                    ),
                                  ],
                                ],
                              ),
                              // Rating dan Ulasan (jika belum diulas)
                              if (_reviewStatus[orderItem.product.id] ==
                                  false) ...[
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
                                              _ratings[index] = starIndex + 1;
                                            });
                                          },
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                                if (_ratings[index] > 0) ...[
                                  TextField(
                                    controller: _reviewControllers[index],
                                    maxLines: 3,
                                    decoration: InputDecoration(
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppColors.greyLoading,
                                            width: 2.0),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppColors.white, width: 1.0),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      hintText: 'Tulis ulasan Anda di sini...',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
