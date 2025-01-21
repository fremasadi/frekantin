import 'dart:async';

import 'package:e_kantin/core/constant/colors.dart';
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
import '../../../bloc/category/categoty_event.dart';
import '../../../bloc/product/product_bloc.dart';
import '../../../bloc/review/review_bloc.dart';
import '../../../bloc/user/user_bloc.dart';
import '../../widgets/category_card.dart';
import '../produk/detail_produk_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final PageController _pageController;
  late final Timer _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        _currentPage = (_currentPage + 1) % 3;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel();
    super.dispose();
  }

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
    return Scaffold(body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, categoryState) {
      return BlocBuilder<ProductBloc, ProductState>(
          builder: (context, productState) {
        if (categoryState is CategoryLoading ||
            productState is ProductLoading) {
          return homeLoadingWidget(context);
        }
        return CustomScrollView(
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
                                                    categoryId:
                                                        category.id.toString(),
                                                    categoryName: category.name,
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
                            return BlocProvider(
                              create: (context) => ReviewBloc(
                                repository: ReviewRepository(),
                                productId: product.id,
                              )..add(FetchAverageRating(product.id)),
                              child: GestureDetector(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return DetailProdukPage(product: product);
                                    },
                                  );
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
        background: Stack(
          children: [
            SizedBox(
              height: 230.h,
              child: PageView.builder(
                controller: _pageController,
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Image.asset(
                    'assets/images/img_slider.jpg',
                    height: 285.h,
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.fill,
                  );
                },
              ),
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
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(25.h),
        child: _buildSearchBar(),
      ),
    );
  }

  Widget _buildWelcomeText(String greting) {
    return Positioned(
      top: MediaQuery.of(context).size.width * .1 + 5,
      left: 10,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 4.5.sp, horizontal: 12.sp),
        decoration: BoxDecoration(
          color: AppColors.black.withOpacity(0.24),
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
                  return Center(child: CircularProgressIndicator());
                } else if (state is UserLoaded) {
                  return Text(
                    state.user.name, // Mengambil nama dari user yang dimuat
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
                return SizedBox(); // Return an empty box if initial state
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
                color: AppColors.primary.withOpacity(0.3),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(4, (index) {
              return Shimmer.fromColors(
                baseColor: AppColors.greyLoading,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  margin: EdgeInsets.all(16.sp),
                  height: 60.h,
                  width: 60.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.greyLoading,
                  ),
                ),
              );
            }),
          ),
          Shimmer.fromColors(
            baseColor: AppColors.greyLoading,
            highlightColor: Colors.grey.shade100,
            child: Container(
              padding: EdgeInsets.all(16.sp),
              height: 250.h,
              width: ScreenUtil().screenWidth,
              decoration: BoxDecoration(
                color: AppColors.greyLoading,
                borderRadius: BorderRadius.circular(16.sp),
              ),
            ),
          ),
          SizedBox(height: 16.sp),
          Shimmer.fromColors(
            baseColor: AppColors.greyLoading,
            highlightColor: Colors.grey.shade100,
            child: Container(
              padding: EdgeInsets.all(16.sp),
              height: 250.h,
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
