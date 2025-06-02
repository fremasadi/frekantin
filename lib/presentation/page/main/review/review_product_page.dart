import 'package:e_kantin/core/constant/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../data/repository/review_feedback_repository.dart';
import '../../../bloc/review/review_feedback_bloc.dart';

class ReviewProductPage extends StatelessWidget {
  final int productId;

  const ReviewProductPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReviewFeedbackBloc(repository: ReviewFeedbackRepository())
        ..add(FetchReviewFeedback(productId)),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text(
            'Review Makanan',
            style: TextStyle(
              fontSize: 16.sp,
              fontFamily: 'SemiBold',
              color: Colors.black,
            ),
          ),
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.w),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocBuilder<ReviewFeedbackBloc, ReviewFeedbackState>(
          builder: (context, state) {
            if (state is ReviewFeedbackLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      strokeWidth: 3.w,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Loading...',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey[600],
                        fontFamily: 'SemiBold',
                      ),
                    ),
                  ],
                ),
              );
            } else if (state is ReviewFeedbackLoaded) {
              final reviews = state.reviewFeedbackResponse.data;

              if (reviews.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.rate_review_outlined,
                        size: 80.w,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Belum ada ulasan',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontFamily: 'SemiBold',
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Jadilah orang pertama yang mengulas produk ini!',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  // Summary Header
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.all(16.w),
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Review Pembeli',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontFamily: 'SemiBold',
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 20.w),
                            SizedBox(width: 4.w),
                            Text(
                              _calculateAverageRating(reviews)
                                  .toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontFamily: 'SemiBold',
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              '(${reviews.length} ${reviews.length == 1 ? 'review' : 'reviews'})',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Reviews List
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      itemCount: reviews.length,
                      itemBuilder: (context, index) {
                        final review = reviews[index];
                        return Container(
                          margin: EdgeInsets.only(bottom: 12.h),
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.08),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // User Info & Rating
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20.r,
                                    backgroundColor: Colors.blue[100],
                                    backgroundImage: review.customer.image !=
                                            null
                                        ? NetworkImage(review.customer.image!)
                                        : null,
                                    child: review.customer.image == null
                                        ? Text(
                                            review.customer.name.isNotEmpty
                                                ? review.customer.name[0]
                                                    .toUpperCase()
                                                : 'U',
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue[600],
                                            ),
                                          )
                                        : null,
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          review.customer.name,
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontFamily: 'Medium',
                                            color: Colors.grey[800],
                                          ),
                                        ),
                                        SizedBox(height: 2.h),
                                        Text(
                                          _formatDate(review.reviewDate),
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _buildStarRating(
                                      int.tryParse(review.rating) ?? 0),
                                ],
                              ),

                              SizedBox(height: 12.h),

                              // Comment
                              Text(
                                review.comment,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey[700],
                                  height: 1.4,
                                ),
                              ),

                              // Review Image (if exists)
                              if (review.image != null) ...[
                                SizedBox(height: 12.h),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.r),
                                  child: Image.network(
                                    review.image!,
                                    height: 150.h,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 150.h,
                                        width: double.infinity,
                                        color: Colors.grey[200],
                                        child: Icon(
                                          Icons.image_not_supported,
                                          color: Colors.grey[400],
                                          size: 40.w,
                                        ),
                                      );
                                    },
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
              );
            } else if (state is ReviewFeedbackError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 80.w,
                      color: Colors.red[400],
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Ups! Ada yang tidak beres',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.w),
                      child: Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    ElevatedButton.icon(
                      onPressed: () {
                        context
                            .read<ReviewFeedbackBloc>()
                            .add(FetchReviewFeedback(productId));
                      },
                      icon: Icon(Icons.refresh, size: 20.w),
                      label: Text(
                        'Coba Lagi',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                            horizontal: 24.w, vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }

  Widget _buildStarRating(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 16.w,
        );
      }),
    );
  }

  double _calculateAverageRating(List reviews) {
    if (reviews.isEmpty) return 0.0;
    double total = 0;
    for (var review in reviews) {
      total += double.tryParse(review.rating.toString()) ?? 0;
    }
    return total / reviews.length;
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Hari Ini';
      } else if (difference.inDays == 1) {
        return 'Kemarin';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} beberapa hari yang lalu';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return '$weeks ${weeks == 1 ? 'Minggu' : 'Minggu'} ini';
      } else {
        final months = (difference.inDays / 30).floor();
        return '$months ${months == 1 ? 'Bulan' : 'Bulan'} ini';
      }
    } catch (e) {
      return dateString;
    }
  }
}
