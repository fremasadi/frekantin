import 'package:e_kantin/core/constant/colors.dart';
import 'package:e_kantin/presentation/page/widgets/rounded_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../data/repository/review_repository.dart';
import '../../../bloc/productbycategory/product_by_category.dart';
import '../../../bloc/review/review_bloc.dart';
import '../produk/detail_produk_page.dart';

class DetailProductKategory extends StatefulWidget {
  const DetailProductKategory(
      {super.key, required this.categoryId, required this.categoryName});

  final String categoryId;
  final String categoryName;

  @override
  State<DetailProductKategory> createState() => _DetailProductKategoryState();
}

class _DetailProductKategoryState extends State<DetailProductKategory> {
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    context
        .read<ProductByCategoryBloc>()
        .fetchProductsByCategory(widget.categoryId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: ScreenUtil().statusBarHeight),
        child: NotificationListener<ScrollNotification>(
          onNotification: (scrollNotification) {
            if (scrollNotification is UserScrollNotification) {
              setState(() {
                _isScrolling =
                    scrollNotification.direction != ScrollDirection.idle;
              });
            }
            return false;
          },
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: _isScrolling
                      ? [
                          BoxShadow(
                            color: Colors.grey.withAlpha(
                                (255 * 0.2).toInt()), // Menghitung alpha
                            spreadRadius: 0,
                            blurRadius: 6,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(
                              Icons.arrow_back,
                              size: 28.sp,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Aneka ${widget.categoryName} dikantin',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontFamily: 'SemiBold',
                                ),
                              ),
                              Text(
                                'Yuk pilihlah kesukaan anda',
                                style: TextStyle(fontSize: 12.sp),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 30.h,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          RoundedCard(
                            title: 'Bintang 4.5+',
                            onTap: () {},
                          ),
                          RoundedCard(
                            title: 'Rentang Harga',
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) =>
                                    buildBottomDialog(context),
                              );
                            },
                            icon: Icons.keyboard_arrow_down,
                          ),
                          RoundedCard(
                            title: 'Buka Sekarang',
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // BlocBuilder for Products
              Expanded(
                child:
                    BlocBuilder<ProductByCategoryBloc, ProductByCategoryState>(
                  builder: (context, state) {
                    if (state is ProductByCategoryLoading) {
                      return loadingPlaceholder();
                    } else if (state is ProductByCategoryLoaded) {
                      final products = state.products;
                      if (products.isEmpty) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/icons/ic_p.empty.png',
                              width: 200.w,
                              height: 200.h,
                            ),
                            Text(
                              'Tidak ada makanan',
                              style: TextStyle(
                                  fontSize: 16.sp, fontFamily: 'Medium'),
                            ),
                          ],
                        );
                      }
                      return ListView.builder(
                        itemCount: products.length,
                        padding: EdgeInsets.zero,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return BlocProvider(
                            create: (context) => ReviewBloc(
                              repository: ReviewRepository(),
                              productId: product.id,
                            )..add(FetchAverageRating(product.id)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: Image.network(
                                          product.image,
                                          height: 100.h,
                                          width: 100.w,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: BlocBuilder<ReviewBloc,
                                            ReviewState>(
                                          builder: (context, reviewState) {
                                            if (reviewState is ReviewLoaded) {
                                              return _buildRatingContainer(
                                                  reviewState.rating
                                                      .toString());
                                            } else if (reviewState
                                                is ReviewLoading) {
                                              return _buildRatingContainer(
                                                  '-'); // Placeholder saat loading
                                            } else {
                                              return _buildRatingContainer(
                                                  '-'); // Placeholder untuk error
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 12.0.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${product.name}, ${product.seller!.name}',
                                          style: TextStyle(
                                            fontSize: 14.0.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 4.0.h),
                                        Text(
                                          product.description,
                                          style: TextStyle(
                                            fontSize: 12.0.sp,
                                            color: AppColors.greyLoading,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 4.0.h),
                                        Text(
                                          'Rp.${product.price}',
                                          style: const TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                        SizedBox(height: 4.0.h),
                                        GestureDetector(
                                          onTap: () {
                                            showModalBottomSheet(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return DetailProdukPage(
                                                    product: product);
                                              },
                                            );
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 4.5.sp,
                                                horizontal: 12.sp),
                                            decoration: BoxDecoration(
                                              color: Colors.redAccent,
                                              borderRadius:
                                                  BorderRadius.circular(16.sp),
                                            ),
                                            child: Text(
                                              'Tambah',
                                              style: TextStyle(
                                                fontSize: 10.sp,
                                                fontFamily: 'SemiBold',
                                                color: AppColors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    } else if (state is ProductByCategoryError) {
                      return Center(child: Text(state.message));
                    }
                    return Container();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget loadingPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: 5,
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.all(8.0),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            children: [
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16.0,
                      width: double.infinity,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 8.0),
                    Container(
                      height: 12.0,
                      width: 150.0,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 8.0),
                    Container(
                      height: 12.0,
                      width: 100.0,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingContainer(String rating) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(6.sp)),
      ),
      padding: EdgeInsets.all(4.sp),
      child: Row(
        children: [
          Icon(
            Icons.star,
            size: 12.sp,
            color: Colors.orange,
          ),
          Text(
            rating,
            style: TextStyle(
              fontSize: 10.sp,
              fontFamily: 'SemiBold',
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBottomDialog(BuildContext context) {
    bool isFirstChecked = false;
    bool isSecondChecked = false;
    bool isThirdChecked = false;
    bool isFourthChecked = false;

    return BottomSheet(
      onClosing: () {},
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              color: AppColors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Rentang harga",
                    style: TextStyle(
                      fontSize: 16.0.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.0.h),
                  CheckboxListTile(
                    title: Text(
                      "Di bawah Rp16.000",
                      style: TextStyle(fontSize: 14.sp),
                    ),
                    value: isFirstChecked,
                    onChanged: (value) {
                      setState(() {
                        isFirstChecked = value ?? false;
                      });
                    },
                    activeColor: AppColors.primary,
                  ),
                  CheckboxListTile(
                    title: Text(
                      "Rp16.000 sampai Rp40.000",
                      style: TextStyle(fontSize: 14.sp),
                    ),
                    value: isSecondChecked,
                    onChanged: (value) {
                      setState(() {
                        isSecondChecked = value ?? false;
                      });
                    },
                    activeColor: AppColors.primary,
                  ),
                  CheckboxListTile(
                    title: Text(
                      "Rp40.000 sampai Rp100.000",
                      style: TextStyle(fontSize: 14.sp),
                    ),
                    value: isThirdChecked,
                    onChanged: (value) {
                      setState(() {
                        isThirdChecked = value ?? false;
                      });
                    },
                    activeColor: AppColors.primary,
                  ),
                  CheckboxListTile(
                    title: Text(
                      "Di atas Rp100.000",
                      style: TextStyle(fontSize: 14.sp),
                    ),
                    value: isFourthChecked,
                    onChanged: (value) {
                      setState(() {
                        isFourthChecked = value ?? false;
                      });
                    },
                    activeColor: AppColors.primary,
                  ),
                  SizedBox(height: 16.0.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isFirstChecked = false;
                            isSecondChecked = false;
                            isThirdChecked = false;
                            isFourthChecked = false;
                          });
                        },
                        child: Text(
                          "Hapus filter",
                          style: TextStyle(fontSize: 14.sp, color: Colors.red),
                        ),
                      ),
                      SizedBox(width: 8.0.w),
                      ElevatedButton(
                        onPressed: () {
                          // Pasang filter
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        child: Text(
                          "Pasang",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
