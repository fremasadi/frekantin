import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constant/colors.dart';
import '../../../../data/repository/review_repository.dart';
import '../../../bloc/review/review_bloc.dart';
import '../../../bloc/search_product/search_product_bloc.dart';
import '../../../bloc/search_product/search_product_event.dart';
import '../../../bloc/search_product/search_product_state.dart';
import '../produk/detail_produk_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller =
      TextEditingController(); // Controller untuk TextField

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: ScreenUtil().statusBarHeight,
          ),
          Row(
            children: [
              SizedBox(
                width: 12.w,
              ),
              GestureDetector(
                onTap: () {
                  context.read<SearchProductBloc>().add(ClearSearchResults());
                  Navigator.pop(context);
                },
                child: Container(
                  padding: EdgeInsets.all(8.sp),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey
                            .withAlpha((255 * 0.2).toInt()), // Menghitung alpha
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    size: 22.sp,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.sp),
                  margin:
                      EdgeInsets.symmetric(vertical: 12.sp, horizontal: 16.sp),
                  decoration: BoxDecoration(
                    color: AppColors.white1,
                    borderRadius: BorderRadius.circular(16.sp),
                    border: Border.all(color: AppColors.black),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, size: 28.sp, color: AppColors.black),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: TextFormField(
                          controller: _controller,
                          focusNode: _focusNode,
                          onFieldSubmitted: (value) {
                            if (value.isNotEmpty) {
                              context
                                  .read<SearchProductBloc>()
                                  .add(SearchProductByKeyword(value));
                            }
                          },
                          decoration: InputDecoration(
                            hintText: 'Mau makan apa hari ini',
                            hintStyle:
                                TextStyle(fontSize: 12.sp, color: Colors.grey),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      Icon(Icons.restaurant,
                          color: Colors.redAccent, size: 22.sp),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: BlocBuilder<SearchProductBloc, SearchProductState>(
              builder: (context, state) {
                if (state is SearchProductLoading) {
                  return loadingPlaceholder();
                } else if (state is SearchProductLoaded) {
                  if (state.products.isEmpty) {
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
                          'Maaf Makanan Tidak Tersedia',
                          style:
                              TextStyle(fontSize: 16.sp, fontFamily: 'Medium'),
                        ),
                      ],
                    );
                  }
                  return ListView.builder(
                    itemCount: state.products.length,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      final product = state.products[index];
                      bool isSellerActive = product.seller?.isActive == 1;

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
                                  ColorFiltered(
                                    colorFilter: isSellerActive
                                        ? const ColorFilter.mode(
                                            Colors.transparent,
                                            BlendMode.multiply)
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
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.network(
                                        product.image,
                                        height: 100.h,
                                        width: 100.w,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: BlocBuilder<ReviewBloc, ReviewState>(
                                      builder: (context, reviewState) {
                                        if (reviewState is ReviewLoaded) {
                                          return _buildRatingContainer(
                                              reviewState.rating.toString());
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                    if (isSellerActive)
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
                                    if (!isSellerActive)
                                      Text(
                                        'Toko Sedang Tutup',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontFamily: 'SemiBold',
                                          color: Colors.red,
                                        ),
                                      )
                                    // if (!isSellerActive)
                                    //   Text(
                                    //     'Penjual tutup untuk saat ini.',
                                    //     style: TextStyle(color: Colors.red),
                                    //   )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else if (state is SearchProductError) {
                  return Center(child: Text(state.message));
                }
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/icons/ic_search.png',
                      width: 150.w,
                      height: 150.h,
                    ),
                    SizedBox(
                      height: 12.h,
                    ),
                    Text(
                      "Cari makanan dengan kata kunci!",
                      style: TextStyle(fontSize: 14.sp, fontFamily: 'SemiBold'),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
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

  Widget loadingPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
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
}
