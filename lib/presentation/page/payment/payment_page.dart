import 'package:e_kantin/core/constant/colors.dart';
import 'package:e_kantin/core/util/price_converter.dart';
import 'package:e_kantin/presentation/page/payment/selectpayment_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../bloc/cart/cart_bloc.dart';
import '../../bloc/cart/cart_state.dart';
import '../widgets/checkout_card.dart';

class PaymentPage extends StatelessWidget {
  final String tableNumber;

  const PaymentPage({Key? key, required this.tableNumber}) : super(key: key);

  final double serviceFee = 3000.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: ScreenUtil().statusBarHeight,
          ),
          Center(
            child: Row(
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.arrow_back,
                      size: 22.sp,
                      color: AppColors.black,
                    )),
                SizedBox(
                  width: 12.w,
                ),
                Text(
                  'Pembayaran',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontFamily: 'SemiBold',
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Image.asset(
                  'assets/icons/ic_location.png',
                  width: 25.w,
                  height: 25.h,
                ),
                SizedBox(
                  width: 12.w,
                ),
                Text(
                  'Meja $tableNumber',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontFamily: 'Medium',
                    color: AppColors.black,
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0.sp),
                    child: Text(
                      'List Makanan',
                      style: TextStyle(fontSize: 12.sp, fontFamily: 'SemiBold'),
                    ),
                  ),
                  SizedBox(
                    height: 12.h,
                  ),
                  BlocBuilder<CartBloc, CartState>(
                    builder: (context, state) {
                      if (state is CartLoading) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(
                            children: [
                              _buildContainerLoading(),
                              _buildContainerLoading(),
                              _buildContainerLoading(),
                              _buildContainerLoading(),
                            ],
                          ),
                        );
                      } else if (state is CartLoaded) {
                        final cartItems = state.items;

                        return ListView.builder(
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: cartItems.length,
                          itemBuilder: (context, index) {
                            final item = cartItems[index];

                            return CheckoutCard(
                              imageUrl: item.product?.image ?? '',
                              title: item.product?.name ??
                                  'Produk Tidak Diketahui',
                              price: item.product?.price ?? 0.0,
                              quantity: item.quantity,
                              note: '',
                            );
                          },
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
                  Padding(
                    padding: EdgeInsets.all(12.0.sp),
                    child: GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SelectpaymentPage()),
                        );
                        // if (result != null) {
                        //   context.read<PaymentBloc>().add(
                        //     PaymentMethodSelected(result),
                        //   );
                        // }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Image.asset(
                            'assets/icons/ic_selectpayment.png',
                            width: 25.w,
                            height: 25.h,
                          ),
                          SizedBox(
                            width: 8.w,
                          ),
                          Text(
                            'Metode Pembayaran',
                            style: TextStyle(fontSize: 12.sp),
                          ),
                          const Spacer(),
                          Text(
                            'Pilih',
                            style: TextStyle(
                                fontSize: 12.sp, fontFamily: 'Medium'),
                          ),
                          SizedBox(
                            width: 8.w,
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16.sp,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0.sp),
                    child: Divider(
                      color: AppColors.greyPrice,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(12.0.sp),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/icons/ic_rincian.png',
                          width: 25.w,
                          height: 25.h,
                        ),
                        SizedBox(
                          width: 8.w,
                        ),
                        Text(
                          'Rincian Pembayaran',
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0.sp),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Subtotal untuk makanan',
                          style: TextStyle(
                              fontSize: 10.sp, color: AppColors.greyPrice),
                        ),
                        BlocBuilder<CartBloc, CartState>(
                          builder: (context, state) {
                            if (state is CartLoaded) {
                              final cartItems = state.items;
                              double subtotal =
                                  cartItems.fold(0.0, (total, item) {
                                return total +
                                    (item.product?.price ?? 0.0) *
                                        item.quantity;
                              });
                              return Text(
                                'Rp.${formatPrice(subtotal)}',
                                style: TextStyle(
                                    fontSize: 10.sp,
                                    color: AppColors.greyPrice),
                              );
                            }
                            return Text('Rp.000',
                                style: TextStyle(
                                    fontSize: 10.sp,
                                    color: AppColors.greyPrice));
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0.sp),
                    child: Row(
                      children: [
                        Text(
                          'Biaya Layanan',
                          style: TextStyle(
                              fontSize: 10.sp, color: AppColors.greyPrice),
                        ),
                        SizedBox(
                          width: 8.w,
                        ),
                        GestureDetector(
                          onTap: () {
                            _showServiceFeeDialog(context);
                          },
                          child: Container(
                            padding: EdgeInsets.all(4.sp),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.black)),
                            child: Text(
                              '?',
                              style: TextStyle(
                                  fontSize: 10.sp, color: AppColors.greyPrice),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Rp.${formatPrice(serviceFee)}',
                          style: TextStyle(
                              fontSize: 10.sp, color: AppColors.greyPrice),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0.sp),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Pembayaran',
                          style: TextStyle(
                              fontSize: 12.sp, color: AppColors.black),
                        ),
                        BlocBuilder<CartBloc, CartState>(
                          builder: (context, state) {
                            if (state is CartLoaded) {
                              final cartItems = state.items;
                              double subtotal =
                                  cartItems.fold(0.0, (total, item) {
                                return total +
                                    (item.product?.price ?? 0.0) *
                                        item.quantity;
                              });
                              double totalPayment = subtotal + serviceFee;
                              return Text(
                                'Rp.${formatPrice(totalPayment)}',
                                style: TextStyle(
                                    fontSize: 12.sp, color: Colors.red),
                              );
                            }
                            return Text('Rp.000',
                                style: TextStyle(
                                    fontSize: 12.sp, color: Colors.red));
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 12.h,
                  )
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 12.sp, horizontal: 24.sp),
            margin: EdgeInsets.only(bottom: ScreenUtil().bottomBarHeight),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.sp)),
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
                    BlocBuilder<CartBloc, CartState>(
                      builder: (context, state) {
                        if (state is CartLoaded) {
                          final cartItems = state.items;
                          double subtotal = cartItems.fold(0.0, (total, item) {
                            return total +
                                (item.product?.price ?? 0.0) * item.quantity;
                          });
                          double totalPayment = subtotal + serviceFee;
                          return Text(
                            'Rp.${formatPrice(totalPayment)}',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontFamily: 'SemiBold',
                              color: Colors.red,
                            ),
                          );
                        }
                        return Text('Rp.000',
                            style:
                                TextStyle(fontSize: 12.sp, color: Colors.red));
                      },
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        vertical: 12.sp, horizontal: 16.sp),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16.sp),
                    ),
                    child: Text(
                      'Pesanan',
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
          ),
        ],
      ),
    );
  }

  Widget _buildContainerLoading() {
    return Container(
      margin: EdgeInsets.only(bottom: 12.sp),
      height: 100.h,
      color: AppColors.greyPrice,
    );
  }

  void _showServiceFeeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          title: Text(
            'Biaya Layanan',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp, fontFamily: 'Medium'),
          ),
          content: Text(
            textAlign: TextAlign.center,
            'Biaya layanan diterapkan agar kami dapat terus memberikan pengalaman berbelanja terbaik untukmu',
            style: TextStyle(fontSize: 12.sp),
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text(
                  'OK',
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: 'Medium',
                      color: AppColors.primary),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
