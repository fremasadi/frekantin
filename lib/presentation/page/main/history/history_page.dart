import 'package:e_kantin/core/constant/colors.dart';
import 'package:e_kantin/core/constant/strings.dart';
import 'package:e_kantin/core/util/date_coverter.dart';
import 'package:e_kantin/core/util/price_converter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../data/models/order.dart';
import '../../../../data/repository/order_repository.dart';
import '../../../bloc/order/order_bloc.dart';
import 'payment_history_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // Menyimpan status expanded per order item
  Map<int, bool> expandedItems = {};

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OrderBloc(orderRepository: OrderRepository())
        ..add(FetchOrdersEvent()),
      child: Scaffold(
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
                  'Riwayat',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontFamily: 'SemiBold',
                  ),
                ),
              ],
            ),
            Expanded(
              child: BlocBuilder<OrderBloc, OrderState>(
                builder: (context, state) {
                  if (state is OrderLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (state is OrdersLoaded) {
                    return ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      itemCount: state.orders.length,
                      itemBuilder: (context, index) {
                        final order = state.orders[index];
                        return orderHistory(order, index);
                      },
                    );
                  } else if (state is OrderFailure) {
                    return Center(
                      child: Text(
                        'Gagal memuat riwayat pesanan: ${state.error}',
                        style: TextStyle(color: Colors.red, fontSize: 14.sp),
                      ),
                    );
                  } else {
                    return Center(
                      child: Text(
                        'Tidak ada riwayat pesanan.',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget orderHistory(Order order, int orderIndex) {
    // Menangani status expanded untuk setiap order secara terpisah
    bool isExpanded = expandedItems[orderIndex] ?? false;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
      margin: EdgeInsets.symmetric(vertical: 6.sp),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.greyLoading),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          // Order Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#${order.orderId}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontFamily: 'SemiBold',
                    ),
                  ),Text(
                    formatDate(order.createdAt.toString()),
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppColors.greyPrice,
                      fontFamily: 'Medium',
                    ),
                  ),
                ],
              ),
              Text(
                order.orderStatus,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: AppColors.greyPrice,
                ),
              ),
            ],
          ),
          const Divider(),

          // Menampilkan item pertama terlebih dahulu
          Column(
            children: [
              // Menampilkan item pertama terlebih dahulu
              Padding(
                padding: EdgeInsets.only(bottom: 8.sp),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.sp),
                      child: Image.network(
                        '$imageUrl/storage/${order.orderItems.first.product.image}', // Menampilkan gambar item pertama
                        width: 100.w,
                        height: 70.h,
                        fit: BoxFit.fill,
                      ),
                    ),
                    SizedBox(
                      width: 12.w,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.orderItems.first.product.name,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontFamily: 'SemiBold',
                          ),
                        ),
                        Text(
                          order.orderItems.first.notes.isNotEmpty
                              ? order.orderItems.first.notes
                              : "tidak ada catatan",
                          style: TextStyle(
                            color: AppColors.greyPrice,
                            fontSize: 10.sp,
                          ),
                        ),
                        SizedBox(
                          height: 4.h,
                        ),
                        Text(
                          formatCurrency(order.orderItems.first.price),
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontFamily: 'SemiBold',
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      '${order.orderItems.first.quantity}X',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: AppColors.greyPrice,
                      ),
                    ),
                  ],
                ),
              ),

              // Menampilkan tombol 'Lihat Semua' atau 'Tutup Semua'
              if (order.orderItems.length > 1 && !isExpanded)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      expandedItems[orderIndex] = true;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Lihat Semua',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontFamily: 'SemiBold',
                          color: AppColors.primary,
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        size: 16.sp,
                      )
                    ],
                  ),
                ),
              if (isExpanded) ...[
                // Menampilkan item pertama terakhir (di bawah) dan item-item berikutnya di atasnya
                Column(
                  children: [
                    // Item selain yang pertama ditampilkan di atas
                    ...order.orderItems.skip(1).map((orderItem) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 8.sp),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12.sp),
                              child: Image.network(
                                '$imageUrl/storage/${orderItem.product.image}', // Menampilkan gambar item
                                width: 100.w,
                                height: 70.h,
                                fit: BoxFit.fill,
                              ),
                            ),
                            SizedBox(
                              width: 12.w,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  orderItem.product.name,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontFamily: 'SemiBold',
                                  ),
                                ),
                                Text(
                                  orderItem.notes.isNotEmpty
                                      ? orderItem.notes
                                      : "tidak ada catatan",
                                  style: TextStyle(
                                    color: AppColors.greyPrice,
                                    fontSize: 10.sp,
                                  ),
                                ),
                                SizedBox(
                                  height: 4.h,
                                ),
                                Text(
                                  formatCurrency(orderItem.price),
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontFamily: 'SemiBold',
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              '${orderItem.quantity}X',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: AppColors.greyPrice,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    // Menampilkan tombol 'Tutup Semua'
                    if (order.orderItems.length > 1 && isExpanded)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            expandedItems[orderIndex] = false;
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Tutup Semua',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontFamily: 'SemiBold',
                                color: AppColors.primary,
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_up,
                              size: 16.sp,
                            )
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),

          const Divider(),

          // Payment Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total:${formatCurrency(order.totalAmount)}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontFamily: 'SemiBold',
                    ),
                  ),
                  Text(
                    'Meja: ${order.tableNumber}',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppColors.greyPrice,
                      fontFamily: 'Medium',
                    ),
                  ),
                ],
              ),
              if (order.orderStatus == 'PENDING')
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentHistoryPage(
                            order: order), // Pass tRhe order to the PaymentPage
                      ),
                    );
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 4.sp, horizontal: 8.sp),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.greyPrice),
                    ),
                    child: Text(
                      'Bayar',
                      style: TextStyle(
                        fontFamily: 'SemiBold',
                        fontSize: 12.sp,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
