import 'package:e_kantin/core/constant/colors.dart';
import 'package:e_kantin/core/constant/strings.dart';
import 'package:e_kantin/core/router/app_router.dart';
import 'package:e_kantin/presentation/page/main/kategory/detail_product_kategory.dart';
import 'package:e_kantin/presentation/page/main/kategory/kategory_page.dart';
import 'package:e_kantin/presentation/page/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../data/repository/review_repository.dart';
import '../../../bloc/category/category_bloc.dart';
import '../../../bloc/category/category_state.dart';
import '../../../bloc/category/categoty_event.dart';
import '../../../bloc/content/content_bloc.dart';
import '../../../bloc/product/product_bloc.dart';
import '../../../bloc/review/review_bloc.dart';
import '../../../bloc/user/user_bloc.dart';
import '../../widgets/category_card.dart';
import '../../widgets/image_slider.dart';
import '../produk/detail_produk_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String getGreting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Pagi';
    } else if (hour < 14) {
      return 'Siang';
    } else if (hour < 18) {
      return 'Sore';
    } else {
      return 'Malam';
    }
  }

  @override
  Widget build(BuildContext context) {
    context.read<ProductBloc>().fetchProducts();

    return Scaffold(body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, categoryState) {
      return BlocBuilder<ProductBloc, ProductState>(
          builder: (context, productState) {
        if (categoryState is CategoryLoading ||
            productState is ProductLoading) {
          return homeLoadingWidget(context);
        }
        return RefreshIndicator(
          backgroundColor: AppColors.primary,
          onRefresh: () async {
            context.read<CategoryBloc>().add(FetchCategories());
            context.read<ProductBloc>().fetchProducts();
          },
          child: CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BlocBuilder<CategoryBloc, CategoryState>(
                      builder: (context, state) {
                        if (state is CategoryLoaded) {
                          return Column(
                            children: [
                              _buildSectionHeader(
                                'Kategori',
                                'Lihat Semua',
                                () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => KategoryPage(
                                                categories: state.categories,
                                              )));
                                },
                              ),
                              SizedBox(
                                height: 16.h,
                              ),
                              SizedBox(
                                height: 100.h,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: state.categories.length,
                                  itemBuilder: (context, index) {
                                    final category = state.categories[index];
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    DetailProductKategory(
                                                      categoryId: category.id
                                                          .toString(),
                                                      categoryName:
                                                          category.name,
                                                    )));
                                      },
                                      child: CategoryCard(
                                          image: category.imageUrl!,
                                          category: category.name),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        } else if (state is CategoryError) {
                          return Center(child: Text('Error: ${state.message}'));
                        }
                        return const Center(
                            child: Text('No categories available'));
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0.sp),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rekomendasi enak buat kamu',
                            style: TextStyle(
                                fontSize: 14.sp, fontFamily: 'SemiBold'),
                          ),
                        ],
                      ),
                    ),
                    BlocBuilder<ProductBloc, ProductState>(
                      builder: (context, state) {
                        if (state is ProductLoaded) {
                          return ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: state.products.length,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final product = state.products[index];
                              final bool isSellerActive =
                                  product.seller?.isActive == 1;

                              return BlocProvider(
                                create: (context) => ReviewBloc(
                                  repository: ReviewRepository(),
                                  productId: product.id,
                                )..add(FetchAverageRating(product.id)),
                                child: GestureDetector(
                                  onTap: () {
                                    if (isSellerActive) {
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return DetailProdukPage(
                                              product: product);
                                        },
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Penjual tidak aktif untuk saat ini.'),
                                          duration: Duration(seconds: 2),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  },
                                  child: ProductCard(
                                    product: product,
                                  ),
                                ),
                              );
                            },
                          );
                        } else if (state is ProductError) {
                          return Text('Error: ${state.message}');
                        }
                        return Container();
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      });
    }));
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200.h,
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.white,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  BlocBuilder<ImageContentBloc, ImageContentState>(
                    builder: (context, state) {
                      if (state.isLoading) {
                        return const Center(child: SizedBox());
                      } else if (state.errorMessage.isNotEmpty) {
                        return Center(child: Text(state.errorMessage));
                      } else {
                        return AutoSlidePageView(
                          images: state.images,
                          imageUrl: imageUrl,
                        );
                      }
                    },
                  ),
                  _buildWelcomeText(getGreting()),
                  Positioned(
                      top: MediaQuery.of(context).size.width * .1 + 5,
                      right: 10.sp,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, AppRouter.history);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.white1,
                                shape: BoxShape.circle,
                              ),
                              padding: EdgeInsets.all(8.sp),
                              child: Image.asset(
                                'assets/icons/history.png',
                                width: 25.w,
                                height: 25.h,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 8.w,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, AppRouter.setting);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.white1,
                                shape: BoxShape.circle,
                              ),
                              padding: EdgeInsets.all(8.sp),
                              child: Image.asset(
                                'assets/icons/setting.png',
                                width: 25.w,
                                height: 25.h,
                              ),
                            ),
                          ),
                        ],
                      ))
                ],
              ),
            ),
            SizedBox(
              height: 30.h,
            )
          ],
        ),
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(25.h),
        child: _buildSearchBar(),
      ),
    );
  }

  //appbar item
  Widget _buildWelcomeText(String greting) {
    return Positioned(
      top: ScreenUtil().screenWidth * .1 + 5,
      left: 10,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 4.5.sp, horizontal: 12.sp),
        decoration: BoxDecoration(
          color: AppColors.black
              .withAlpha((255 * 0.2).toInt()), // Menghitung alpha
          borderRadius: BorderRadius.circular(16.sp),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selamat $greting',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.white,
                fontFamily: 'SemiBold',
              ),
            ),
            BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                if (state is UserLoading) {
                  return const Text('');
                } else if (state is UserLoaded) {
                  return Text(
                    state.user.name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.white,
                      fontFamily: 'SemiBold',
                    ),
                  );
                } else if (state is UserError) {
                  return Text(
                    'Error: ${state.message}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.white,
                      fontFamily: 'SemiBold',
                    ),
                  );
                }
                return const SizedBox(); // Return an empty box if initial state
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRouter.searchProduct);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 6.sp),
        margin: EdgeInsets.symmetric(vertical: 12.sp, horizontal: 16.sp),
        decoration: BoxDecoration(
          color: AppColors.white1,
          borderRadius: BorderRadius.circular(16.sp),
          border: Border.all(color: AppColors.black),
        ),
        child: Row(
          children: [
            Icon(Icons.search, size: 28.sp, color: AppColors.black),
            SizedBox(width: 12.w),
            Text(
              'Mau makan apa hari ini',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
            ),
            const Spacer(),
            Icon(Icons.restaurant, color: Colors.redAccent, size: 22.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
      String title, String actionText, GestureTapCallback onTap) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.sp),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16.sp, fontFamily: 'SemiBold'),
            ),
            Container(
              padding:
                  EdgeInsets.symmetric(vertical: 4.5.sp, horizontal: 12.sp),
              decoration: BoxDecoration(
                color: AppColors.primary
                    .withAlpha((255 * 0.2).toInt()), // Menghitung alpha
                borderRadius: BorderRadius.circular(16.sp),
              ),
              child: Text(
                actionText,
                style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.primary,
                    fontFamily: 'SemiBold'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget homeLoadingWidget(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Shimmer.fromColors(
            baseColor: AppColors.greyLoading,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 200.h,
              width: ScreenUtil().screenWidth,
              color: AppColors.greyLoading,
            ),
          ),
          Shimmer.fromColors(
            baseColor: AppColors.greyLoading,
            highlightColor: Colors.grey.shade100,
            child: Container(
              margin: EdgeInsets.all(16.sp),
              height: 50.h,
              width: ScreenUtil().screenWidth,
              decoration: BoxDecoration(
                color: AppColors.greyLoading,
                borderRadius: BorderRadius.circular(16.sp),
              ),
            ),
          ),
          SizedBox(
            height: 80.h, // Sesuaikan tinggi agar tidak terpotong
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              // Agar bisa di-scroll horizontal
              itemCount: 6,
              // Jumlah item
              itemBuilder: (context, index) {
                return Shimmer.fromColors(
                  baseColor: AppColors.greyLoading,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 8.sp),
                    // Margin antar item
                    height: 60.h,
                    width: 60.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.greyLoading,
                    ),
                  ),
                );
              },
            ),
          ),
          Shimmer.fromColors(
            baseColor: AppColors.greyLoading,
            highlightColor: Colors.grey.shade100,
            child: Container(
              padding: EdgeInsets.all(16.sp),
              margin: EdgeInsets.all(16.sp),
              height: 200.h,
              width: ScreenUtil().screenWidth,
              decoration: BoxDecoration(
                color: AppColors.greyLoading,
                borderRadius: BorderRadius.circular(16.sp),
              ),
            ),
          ),
          Shimmer.fromColors(
            baseColor: AppColors.greyLoading,
            highlightColor: Colors.grey.shade100,
            child: Container(
              padding: EdgeInsets.all(16.sp),
              margin: EdgeInsets.all(16.sp),
              height: 200.h,
              width: ScreenUtil().screenWidth,
              decoration: BoxDecoration(
                color: AppColors.greyLoading,
                borderRadius: BorderRadius.circular(16.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
