import 'package:e_kantin/core/constant/colors.dart';
import 'package:e_kantin/presentation/page/order/order_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../data/repository/order_repository.dart';
import '../../bloc/cart/cart_bloc.dart';
import '../../bloc/cart/cart_event.dart';
import '../../bloc/cart/cart_state.dart';
import '../../bloc/order/order_bloc.dart';
import '../widgets/keranjang_card.dart';

class KeranjangPage extends StatelessWidget {
  KeranjangPage({super.key});

  // Controller untuk nomor meja
  final TextEditingController _tableNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.only(
                top: ScreenUtil().statusBarHeight,
                bottom: ScreenUtil().statusBarHeight * .5 ),
            color: AppColors.primary,
            child: Center(
              child: Text(
                'Keranjang',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontFamily: 'SemiBold',
                  color: AppColors.white,
                ),
              ),
            ),
          ),

          // Daftar Item di Keranjang
          Expanded(
            child: BlocBuilder<CartBloc, CartState>(
              builder: (context, state) {
                if (state is CartLoading) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: List.generate(
                        4,
                        (_) => _buildContainerLoading(),
                      ),
                    ),
                  );
                } else if (state is CartLoaded) {
                  final cartItems = state.items;

                  // Jika Keranjang Kosong
                  if (cartItems.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/icons/ic_empty_cart.png',
                            width: 100.w,
                            height: 100.h,
                            fit: BoxFit.cover,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0.sp),
                            child: Text(
                              'Wah, Keranjangmu kosong',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontFamily: 'Medium',
                                color: AppColors.black,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.0.sp),
                            child: Text(
                              'Yuk, isi dengan makanan yang ingin anda makan',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.greyPrice,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Jika Keranjang Berisi Item
                  return Column(
                    children: [
                      // Input Nomor Meja
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(
                                  (255 * 0.2).toInt()), // Menghitung alpha
                              blurRadius: 1.0,
                              spreadRadius: 0.0,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          controller: _tableNumberController,
                          decoration: InputDecoration(
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Image.asset(
                                'assets/icons/ic_location.png',
                                width: 25.w,
                                height: 25.h,
                              ),
                            ),
                            hintText: 'Yuk Tuliskan Meja Anda Sekarang',
                            hintStyle: TextStyle(
                              fontSize: 12.sp,
                              fontFamily: 'Medium',
                              color: Colors.grey,
                            ),
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 16.0),
                          ),
                        ),
                      ),

                      // List Item
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: cartItems.length,
                          itemBuilder: (context, index) {
                            final item = cartItems[index];

                            return KeranjangCard(
                              imageUrl: item.product?.image ?? '',
                              title: item.product?.name ??
                                  'Produk Tidak Diketahui',
                              price: item.product?.price ?? 0.0,
                              initialQuantity: item.quantity,
                              onAdd: () {
                                context.read<CartBloc>().add(
                                    UpdateCartItem(item.id, item.quantity + 1));
                              },
                              onRemove: () {
                                context.read<CartBloc>().add(
                                    UpdateCartItem(item.id, item.quantity - 1));
                              },
                              productId: item.id,
                              onDelete: () {
                                context
                                    .read<CartBloc>()
                                    .add(RemoveCartItem(item.id));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        '${item.product?.name ?? 'Item'} berhasil dihapus dari keranjang'),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                } else if (state is CartError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                } else {
                  return const Center(
                    child: Text(
                      'Terjadi kesalahan, silakan coba lagi.',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }
              },
            ),
          ),

          // Footer Total Harga
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              String totalPrice = '0';

              if (state is CartLoaded) {
                totalPrice = state.totalPrice;
              }

              if (totalPrice.isEmpty || totalPrice == '0') {
                return Container();
              }

              return Container(
                padding:
                    EdgeInsets.symmetric(vertical: 12.sp, horizontal: 24.sp),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16.sp),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Harga',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontFamily: 'Medium',
                            color: AppColors.greyPrice,
                          ),
                        ),
                        Text(
                          'Rp.$totalPrice',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontFamily: 'SemiBold',
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        if (_tableNumberController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Silakan isi nomor meja terlebih dahulu'),
                            ),
                          );
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider(
                              create: (context) =>
                                  OrderBloc(orderRepository: OrderRepository()),
                              child: OrderPage(
                                  tableNumber: _tableNumberController.text),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 17.5.sp, horizontal: 48.sp),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(16.sp),
                        ),
                        child: Text(
                          'Lanjut',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: 'SemiBold',
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Container _buildContainerLoading() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12.sp),
      height: 150.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.greyLoading,
        borderRadius: BorderRadius.circular(16.sp),
      ),
    );
  }
}
