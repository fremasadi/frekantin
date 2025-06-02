import 'package:e_kantin/core/constant/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../data/repository/review_repository.dart';
import '../../../bloc/productbycategory/product_by_category.dart';
import '../../../bloc/review/review_bloc.dart';
import '../produk/detail_produk_page.dart';
import '../review/review_product_page.dart';

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

  // Filter variables
  double _minRating = 0.0;
  List<int> _selectedPriceRanges = [];
  bool _showOpenOnly = false;

  // Price range constants
  static const List<Map<String, dynamic>> priceRanges = [
    {'label': 'Di bawah Rp16.000', 'min': 0, 'max': 16000, 'index': 0},
    {
      'label': 'Rp16.000 sampai Rp40.000',
      'min': 16000,
      'max': 40000,
      'index': 1
    },
    {
      'label': 'Rp40.000 sampai Rp100.000',
      'min': 40000,
      'max': 100000,
      'index': 2
    },
    {
      'label': 'Di atas Rp100.000',
      'min': 100000,
      'max': double.infinity,
      'index': 3
    },
  ];

  @override
  void initState() {
    super.initState();
    context
        .read<ProductByCategoryBloc>()
        .fetchProductsByCategory(widget.categoryId);
  }

  // Filter logic - semua filter harus terpenuhi (AND logic)
  bool _passesFilters(dynamic product) {
    // Rating filter - jika ada filter rating, rating produk harus >= minimum
    if (_minRating > 0) {
      double productRating = 0.0;

      // Ambil rating dari product.averageRating
      if (product.averageRating != null) {
        productRating =
            double.tryParse(product.averageRating.toString()) ?? 0.0;
      }

      if (productRating < _minRating) {
        return false; // Produk tidak memenuhi syarat rating minimum
      }
    }

    // Price filter - jika ada filter harga, harga produk harus masuk dalam salah satu range
    if (_selectedPriceRanges.isNotEmpty) {
      bool priceMatch = false;
      final productPrice = double.tryParse(product.price.toString()) ?? 0;

      for (int rangeIndex in _selectedPriceRanges) {
        final range = priceRanges[rangeIndex];
        if (productPrice >= range['min'] &&
            (range['max'] == double.infinity
                ? true
                : productPrice < range['max'])) {
          priceMatch = true;
          break;
        }
      }
      if (!priceMatch) {
        return false; // Produk tidak masuk dalam range harga yang dipilih
      }
    }

    // Open now filter - jika diaktifkan, toko harus buka
    if (_showOpenOnly) {
      if (product.seller?.isActive != 1) {
        return false; // Toko sedang tutup
      }
    }

    // Semua filter terpenuhi
    return true;
  }

  // Method untuk menghitung filtered products
  List<dynamic> _getFilteredProducts(List<dynamic> products) {
    if (_minRating == 0.0 && _selectedPriceRanges.isEmpty && !_showOpenOnly) {
      return products; // Tidak ada filter, tampilkan semua
    }

    return products.where((product) => _passesFilters(product)).toList();
  }

  void _showRatingFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildRatingBottomSheet(),
    );
  }

  void _showOpenNowFilter() {
    setState(() {
      _showOpenOnly = !_showOpenOnly;
    });
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
                    Row(
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
                    SizedBox(height: 16.h),
                    SizedBox(
                      height: 30.h,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          RoundedCard(
                            title: _minRating > 0
                                ? 'Bintang ${_minRating.toStringAsFixed(1)}+'
                                : 'Rating',
                            onTap: _showRatingFilter,
                            isActive: _minRating > 0,
                          ),
                          RoundedCard(
                            title: _selectedPriceRanges.isNotEmpty
                                ? 'Harga (${_selectedPriceRanges.length})'
                                : 'Rentang Harga',
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) =>
                                    buildPriceBottomDialog(context),
                              );
                            },
                            icon: Icons.keyboard_arrow_down,
                            isActive: _selectedPriceRanges.isNotEmpty,
                          ),
                          RoundedCard(
                            title: 'Buka Sekarang',
                            onTap: _showOpenNowFilter,
                            isActive: _showOpenOnly,
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
                      final filteredProducts = _getFilteredProducts(products);

                      if (filteredProducts.isEmpty) {
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
                              'Tidak ada produk yang sesuai dengan filter',
                              style: TextStyle(
                                  fontSize: 16.sp, fontFamily: 'Medium'),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 16.h),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _minRating = 0.0;
                                  _selectedPriceRanges.clear();
                                  _showOpenOnly = false;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                              ),
                              child: Text(
                                'Reset Filter',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontFamily: 'Medium',
                                ),
                              ),
                            ),
                          ],
                        );
                      }

                      return ListView.builder(
                        itemCount: filteredProducts.length,
                        padding: EdgeInsets.zero,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          bool isSellerActive = product.seller?.isActive == 1;

                          // Ambil rating dari product.averageRating
                          double productRating = 0.0;
                          if (product.averageRating != null) {
                            productRating = double.tryParse(
                                    product.averageRating.toString()) ??
                                0.0;
                          }

                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ReviewProductPage(
                                            productId: product.id),
                                      ),
                                    );
                                  },
                                  child: Stack(
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
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          child: Image.network(
                                            product.image!,
                                            height: 90.h,
                                            width: 90.w,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: _buildRatingContainer(
                                            productRating > 0
                                                ? productRating
                                                    .toStringAsFixed(1)
                                                : '-'),
                                      ),
                                    ],
                                  ),
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
                                    ],
                                  ),
                                ),
                              ],
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

  Widget _buildRatingBottomSheet() {
    return BottomSheet(
      onClosing: () {},
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              color: AppColors.white,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Filter Rating",
                      style: TextStyle(
                        fontSize: 16.0.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.0.h),
                    ...List.generate(5, (index) {
                      final rating = (index + 1).toDouble();
                      return RadioListTile<double>(
                        title: Row(
                          children: [
                            ...List.generate(5, (starIndex) {
                              return Icon(
                                Icons.star,
                                size: 16.sp,
                                color: starIndex < rating
                                    ? Colors.orange
                                    : Colors.grey,
                              );
                            }),
                            SizedBox(width: 8.w),
                            Text(
                              '${rating.toInt()} bintang ke atas',
                              style: TextStyle(
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                        value: rating,
                        groupValue: _minRating,
                        onChanged: (value) {
                          setModalState(() {
                            _minRating = value ?? 0.0;
                          });
                        },
                        activeColor: AppColors.primary,
                      );
                    }),
                    RadioListTile<double>(
                      title: const Text('Semua rating'),
                      value: 0.0,
                      groupValue: _minRating,
                      onChanged: (value) {
                        setModalState(() {
                          _minRating = value ?? 0.0;
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
                            setModalState(() {
                              _minRating = 0.0;
                            });
                            setState(() {});
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Reset",
                            style:
                                TextStyle(fontSize: 14.sp, color: Colors.red),
                          ),
                        ),
                        SizedBox(width: 8.0.w),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {});
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                          child: Text(
                            "Terapkan",
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
              ),
            );
          },
        );
      },
    );
  }

  Widget buildPriceBottomDialog(BuildContext context) {
    List<bool> tempSelectedRanges = List.generate(
        priceRanges.length, (index) => _selectedPriceRanges.contains(index));

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
                  ...priceRanges.map((range) {
                    final index = range['index'] as int;
                    return CheckboxListTile(
                      title: Text(
                        range['label'] as String,
                        style: TextStyle(fontSize: 14.sp),
                      ),
                      value: tempSelectedRanges[index],
                      onChanged: (value) {
                        setState(() {
                          tempSelectedRanges[index] = value ?? false;
                        });
                      },
                      activeColor: AppColors.primary,
                    );
                  }).toList(),
                  SizedBox(height: 16.0.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            tempSelectedRanges = List.generate(
                                priceRanges.length, (index) => false);
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
                          this.setState(() {
                            _selectedPriceRanges = [];
                            for (int i = 0;
                                i < tempSelectedRanges.length;
                                i++) {
                              if (tempSelectedRanges[i]) {
                                _selectedPriceRanges.add(i);
                              }
                            }
                          });
                          Navigator.pop(context);
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

// Widget untuk filter cards
class RoundedCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final IconData? icon;
  final bool isActive;

  const RoundedCard({
    Key? key,
    required this.title,
    required this.onTap,
    this.icon,
    this.isActive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.white,
          border: Border.all(
            color: isActive ? AppColors.primary : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                color: isActive ? Colors.white : Colors.black87,
                fontFamily: 'Medium',
              ),
            ),
            if (icon != null) ...[
              SizedBox(width: 4.w),
              Icon(
                icon,
                size: 16.sp,
                color: isActive ? Colors.white : Colors.black87,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
