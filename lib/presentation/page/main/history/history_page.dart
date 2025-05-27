import 'package:e_kantin/core/constant/colors.dart';
import 'package:e_kantin/core/constant/strings.dart';
import 'package:e_kantin/core/util/date_coverter.dart';
import 'package:e_kantin/core/util/price_converter.dart';
import 'package:e_kantin/presentation/page/main/history/review_page.dart';
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

  // Filter status
  String _selectedStatus = "SEMUA"; // Default filter status
  final List<String> _statusOptions = [
    "SEMUA",
    "TERTUNDA",
    "DIBAYAR",
    "SELESAI",
    "BATAL"
  ];

  // Fungsi untuk menggabungkan order dengan order_id yang sama
  List<Order> _groupOrdersByOrderId(List<Order> orders) {
    Map<String, List<Order>> groupedOrders = {};

    // Kelompokkan order berdasarkan order_id
    for (Order order in orders) {
      if (groupedOrders.containsKey(order.orderId)) {
        groupedOrders[order.orderId]!.add(order);
      } else {
        groupedOrders[order.orderId] = [order];
      }
    }

    // Gabungkan order yang memiliki order_id sama
    List<Order> mergedOrders = [];

    groupedOrders.forEach((orderId, orderList) {
      if (orderList.length == 1) {
        // Jika hanya ada satu order dengan order_id ini, tambahkan langsung
        mergedOrders.add(orderList.first);
      } else {
        // Jika ada beberapa order dengan order_id sama, gabungkan
        Order mergedOrder = _mergeOrders(orderList);
        mergedOrders.add(mergedOrder);
      }
    });

    return mergedOrders;
  }

  // Fungsi untuk menggabungkan beberapa order menjadi satu
  Order _mergeOrders(List<Order> orders) {
    Order baseOrder = orders.first;
    List<OrderItem> allOrderItems = [];
    double totalAmount = 0;

    // Gabungkan semua order items dan hitung total amount
    for (Order order in orders) {
      allOrderItems.addAll(order.orderItems);
      totalAmount += double.parse(order.totalAmount);
    }

    // Buat order baru dengan semua items yang digabungkan
    return Order(
      id: baseOrder.id,
      orderId: baseOrder.orderId,
      customerId: baseOrder.customerId,
      sellerId: baseOrder.sellerId,
      // Menggunakan seller_id dari order pertama
      orderStatus: baseOrder.orderStatus,
      totalAmount: totalAmount.toString(),
      tableNumber: baseOrder.tableNumber,
      estimatedDeliveryTime: baseOrder.estimatedDeliveryTime,
      createdAt: baseOrder.createdAt,
      updatedAt: baseOrder.updatedAt,
      orderItems: allOrderItems,
      payment: baseOrder.payment,
    );
  }

  // Filter orders berdasarkan status yang dipilih
  List<Order> _filterOrders(List<Order> orders) {
    // Pertama, gabungkan order dengan order_id yang sama
    List<Order> groupedOrders = _groupOrdersByOrderId(orders);

    if (_selectedStatus == "SEMUA") {
      return groupedOrders;
    }

    String statusFilter = _getStatusCode(_selectedStatus);
    return groupedOrders
        .where((order) => order.orderStatus == statusFilter)
        .toList();
  }

  // Konversi status display ke kode status backend
  String _getStatusCode(String displayStatus) {
    switch (displayStatus) {
      case "TERTUNDA":
        return "PENDING";
      case "DIBAYAR":
        return "PAID";
      case "SELESAI":
        return "COMPLETED";
      case "BATAL":
        return "CANCELLED";
      default:
        return "";
    }
  }

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
                  'Riwayat Pembelian',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontFamily: 'SemiBold',
                  ),
                ),
              ],
            ),

            // Filter Status Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: SizedBox(
                height: 40.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _statusOptions.length,
                  itemBuilder: (context, index) {
                    final status = _statusOptions[index];
                    final isSelected = status == _selectedStatus;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedStatus = status;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 8.w),
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.greyLoading,
                          ),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color:
                                isSelected ? Colors.white : AppColors.greyPrice,
                            fontSize: 12.sp,
                            fontFamily: 'Medium',
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            Expanded(
              child: BlocBuilder<OrderBloc, OrderState>(
                builder: (context, state) {
                  if (state is OrderLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (state is OrdersLoaded) {
                    final filteredOrders = _filterOrders(state.orders);

                    if (filteredOrders.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 64.sp,
                              color: AppColors.greyPrice,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'Tidak ada riwayat $_selectedStatus',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontFamily: 'Medium',
                                color: AppColors.greyPrice,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      itemCount: filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order = filteredOrders[index];
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
                  ),
                  Text(
                    formatDate(order.createdAt.toString()),
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppColors.greyPrice,
                      fontFamily: 'Medium',
                    ),
                  ),
                ],
              ),
              if (order.orderStatus == 'PENDING')
                Text(
                  'Tertunda',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppColors.greyPrice,
                  ),
                ),
              if (order.orderStatus == 'PAID')
                Text(
                  'Sudah Dibayar',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppColors.greyPrice,
                  ),
                ),
              if (order.orderStatus == 'COMPLETED')
                Text(
                  'Selesai',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppColors.greyPrice,
                  ),
                ),
              if (order.orderStatus == 'CANCELLED')
                Text(
                  'Batal',
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
                                '$imageUrl/storage/${orderItem.product.image}',
                                // Menampilkan gambar item
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
                            order: order), // Pass the order to the PaymentPage
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
              if (order.orderStatus == 'COMPLETED')
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReviewPage(
                            order: order), // Kirim Order ke ReviewPage
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
                      'Nilai',
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
