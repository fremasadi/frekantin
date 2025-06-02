import 'package:e_kantin/core/constant/colors.dart';
import 'package:e_kantin/presentation/page/order/order_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../data/repository/order_repository.dart';
import '../../bloc/cart/cart_bloc.dart';
import '../../bloc/cart/cart_event.dart';
import '../../bloc/cart/cart_state.dart';
import '../../bloc/order/order_bloc.dart';
import '../../bloc/table_number/table_number_bloc.dart';
import '../widgets/keranjang_card.dart';
import 'scan_nomer_meja.dart';

class KeranjangPage extends StatelessWidget {
  KeranjangPage({super.key});

  // Controller untuk nomor meja
  final TextEditingController _tableNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    context.read<CartBloc>().add(LoadCart());

    return BlocConsumer<TableNumberBloc, TableNumberState>(
        listener: (context, state) {
      if (state is TableNumberValid) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) =>
                  OrderBloc(orderRepository: OrderRepository()),
              child: OrderPage(tableNumber: _tableNumberController.text),
            ),
          ),
        );
      } else if (state is TableNumberInvalid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            backgroundColor: Colors.red,
          ),
        );
      } else if (state is TableNumberError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.error),
            backgroundColor: Colors.red,
          ),
        );
      }
    }, builder: (context, state) {
      return Scaffold(
        body: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.only(
                  top: ScreenUtil().statusBarHeight + 10,
                  bottom: ScreenUtil().statusBarHeight * .5),
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
                              padding:
                                  EdgeInsets.symmetric(horizontal: 12.0.sp),
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
                        GestureDetector(
                          onTap: () async {
                            // Show loading indicator while opening scanner
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );

                            // Small delay to show loading
                            await Future.delayed(
                                const Duration(milliseconds: 0));
                            Navigator.pop(context); // Close loading

                            String? scannedResult = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const QrScannerPage(),
                              ),
                            );

                            if (scannedResult != null &&
                                scannedResult.isNotEmpty) {
                              _tableNumberController.text = scannedResult;
                              // Show success snackbar
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Meja $scannedResult berhasil dipilih'),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.0),
                              // Increased radius
                              border: Border.all(
                                color: _tableNumberController.text.isEmpty
                                    ? Colors.grey.withOpacity(0.3)
                                    : Colors.green.withOpacity(0.5),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withAlpha((255 * 0.1).toInt()),
                                  blurRadius: 8.0,
                                  spreadRadius: 0.0,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16.0, horizontal: 16.0),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: _tableNumberController.text.isEmpty
                                          ? Colors.grey.withOpacity(0.1)
                                          : Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.qr_code_scanner,
                                      size: 24,
                                      color: _tableNumberController.text.isEmpty
                                          ? Colors.grey
                                          : Colors.green,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _tableNumberController.text.isEmpty
                                              ? 'Scan QR Code Meja'
                                              : 'Meja ${_tableNumberController.text}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: _tableNumberController
                                                    .text.isEmpty
                                                ? Colors.grey[600]
                                                : Colors.black87,
                                          ),
                                        ),
                                        if (_tableNumberController.text.isEmpty)
                                          Text(
                                            'Tap untuk memindai',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Colors.grey[400],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // List Item
                        // Updated ListView.builder in cart page
                        Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: cartItems.length,
                            itemBuilder: (context, index) {
                              final item = cartItems[index];

                              // Check if seller is active from sellerInfo
                              final bool isSellerActive =
                                  item.product?.sellerInfo?.isActive ??
                                      (item.product?.seller?.isActive == 1
                                          ? true
                                          : false);

                              return KeranjangCard(
                                imageUrl: item.product?.image ?? '',
                                title: item.product?.name ??
                                    'Produk Tidak Diketahui',
                                price: item.product?.price ?? 0.0,
                                initialQuantity: item.quantity,
                                isSellerActive: isSellerActive,
                                notes: item.notes,
                                // Pass the notes from cart item
                                itemId: item.id,
                                // Pass the item ID for notes update
                                // Pass seller active status
                                onAdd: () {
                                  // Only allow add if seller is active
                                  if (isSellerActive != false) {
                                    context.read<CartBloc>().add(UpdateCartItem(
                                        item.id, item.quantity + 1));
                                  }
                                },
                                onRemove: () {
                                  // Only allow remove if seller is active
                                  if (isSellerActive != false) {
                                    context.read<CartBloc>().add(UpdateCartItem(
                                        item.id, item.quantity - 1));
                                  }
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
                bool hasInactiveSeller = false;

                if (state is CartLoaded) {
                  totalPrice = state.totalPrice;

                  // Cek apakah ada seller tidak aktif
                  hasInactiveSeller = state.items.any(
                      (item) => item.product?.sellerInfo?.isActive == false);
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
                          if (hasInactiveSeller) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Tidak bisa lanjut, ada penjual yang sedang tidak aktif.',
                                ),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }

                          if (_tableNumberController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Silakan scan nomor meja terlebih dahulu',
                                ),
                              ),
                            );
                            return;
                          }

                          context.read<TableNumberBloc>().add(
                                ValidateTableNumber(
                                  tableNumber: _tableNumberController.text,
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
    });
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
