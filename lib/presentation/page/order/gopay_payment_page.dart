import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constant/colors.dart';
import '../../../core/util/date_coverter.dart';
import '../../../core/util/price_converter.dart';
import '../../../data/repository/firebase_service.dart';
import '../main/base_page.dart';

class GopayPaymentPage extends StatefulWidget {
  const GopayPaymentPage({
    super.key,
    required this.response,
  });

  final Map<String, dynamic> response;

  @override
  State<GopayPaymentPage> createState() => _GopayPaymentPageState();
}

class _GopayPaymentPageState extends State<GopayPaymentPage> {
  late Map<String, dynamic> payment;
  late Map<String, dynamic> paymentData;
  late int _remainingSeconds;
  late Timer _timer;
  final FirebaseService _firebaseService = FirebaseService();
  bool isAlreadyPaid = false;
  bool isLaunchingApp = false;

  // Hapus StreamSubscription karena listenToOrder return void

  void startCountdown() {
    if (_remainingSeconds <= 0) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            _timer.cancel();
          }
        });
      }
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _launchGoPay() async {
    if (payment['payment_deeplink'] == null) {
      _showErrorDialog('Link pembayaran tidak tersedia');
      return;
    }

    final url = Uri.parse(payment['payment_deeplink']);

    setState(() {
      isLaunchingApp = true;
    });

    try {
      // Coba mode: externalApplication dulu
      bool launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );

      // Kalau gagal, fallback ke inAppWebView
      if (!launched) {
        launched = await launchUrl(
          url,
          mode: LaunchMode.inAppWebView,
          webViewConfiguration: const WebViewConfiguration(
            enableJavaScript: true,
            enableDomStorage: true,
          ),
        );
      }

      if (!launched) {
        _showErrorDialog('Tidak dapat membuka halaman pembayaran');
      }
    } catch (e) {
      _showErrorDialog('Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          isLaunchingApp = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(
          'Error',
          style: TextStyle(
            fontSize: 16.sp,
            fontFamily: 'SemiBold',
            color: Colors.red,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(fontSize: 12.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12.sp,
                fontFamily: 'SemiBold',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/icons/success_payment.png',
              width: 120.w,
              height: 120.h,
            ),
            SizedBox(height: 16.h),
            Text(
              'Pembayaran Berhasil!',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Terima kasih sudah melakukan pembayaran melalui GoPay',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.greyPrice,
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'OK',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: 'SemiBold',
                  color: AppColors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    final orders = widget.response['orders'];
    payment =
        Map<String, dynamic>.from(widget.response['payment']); // <-- Fix disini

    if (orders == null) {
      throw Exception('Data order atau payment tidak ditemukan');
    }

    final paymentOrderId = payment['order_id'];
    final foundOrder = orders.firstWhere(
      (order) => order['id'] == paymentOrderId,
      orElse: () => null,
    );

    if (foundOrder == null) {
      throw Exception('Order terkait dengan payment tidak ditemukan');
    }

    paymentData = Map<String, dynamic>.from(foundOrder);

    final gatewayResponse = payment['payment_gateway_response'];
    final parsed = gatewayResponse is String
        ? jsonDecode(gatewayResponse)
        : gatewayResponse;

    final expiry = DateTime.parse(parsed['expiry_time']).toLocal();
    final now = DateTime.now();
    _remainingSeconds = expiry.difference(now).inSeconds;
    _remainingSeconds = _remainingSeconds > 0 ? _remainingSeconds : 0;

    if (paymentData['status'] == 'PAID') {
      isAlreadyPaid = true;
    }

    if (_remainingSeconds > 0) {
      startCountdown();
    }

    _firebaseService.listenToOrder(paymentData['order_id'].toString(),
        (updatedOrder) {
      if (updatedOrder != null && mounted) {
        setState(() {
          paymentData = Map<String, dynamic>.from(updatedOrder);
        });

        if (updatedOrder['status'] == 'PAID' && !isAlreadyPaid) {
          isAlreadyPaid = true;
          _showSuccessDialog();
        }
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const BasePage()),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.white,
          leading: IconButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const BasePage()),
            ),
            icon: Icon(Icons.arrow_back, size: 28.sp, color: AppColors.primary),
          ),
          centerTitle: false,
          title: Text(
            'Pembayaran GoPay',
            style: TextStyle(
              fontSize: 16.sp,
              fontFamily: 'SemiBold',
              color: AppColors.black,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status dan Timer - PERBAIKAN: Gunakan 'status' bukan 'payment_status'
                Row(
                  children: [
                    if (paymentData['status'] == 'PENDING')
                      Image.asset(
                        'assets/icons/ic_time.png',
                        width: 30.w,
                        color: AppColors.secondary,
                        height: 30.h,
                      ),
                    if (paymentData['status'] == 'PAID')
                      Image.asset(
                        'assets/icons/checklist.png',
                        width: 30.w,
                        height: 30.h,
                      ),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (paymentData['status'] == 'PENDING')
                          Text(
                            'Bayar Sebelum',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontFamily: 'SemiBold',
                            ),
                          ),
                        if (paymentData['status'] == 'PAID')
                          Text(
                            'Pembayaran Berhasil',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontFamily: 'SemiBold',
                            ),
                          ),
                        Text(
                          formatDate(paymentData['expired_at'] ??
                              payment['expired_at']),
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontFamily: 'Medium',
                            color: AppColors.greyPrice,
                          ),
                        )
                      ],
                    ),
                    const Spacer(),
                    if (paymentData['status'] == 'PENDING')
                      Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 8.sp, horizontal: 16.sp),
                        decoration: BoxDecoration(
                          color: Colors.green.withAlpha((255 * 0.2).toInt()),
                          borderRadius: BorderRadius.circular(80.r),
                        ),
                        child: Text(
                          _formatTime(_remainingSeconds),
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontFamily: 'SemiBold',
                            color: Colors.green,
                          ),
                        ),
                      ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14.0),
                  child: Divider(),
                ),

                // QR Code dan Button
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Scan QR atau buka aplikasi GoPay:',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontFamily: 'Medium',
                          color: AppColors.black,
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // QR Code - PERBAIKAN: Gunakan payment untuk QR
                      if (payment['payment_qr_url'] != null)
                        Container(
                          padding: EdgeInsets.all(16.sp),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Image.network(
                            payment['payment_qr_url'],
                            width: 200.w,
                            height: 200.w,
                            errorBuilder: (_, __, ___) => Container(
                              width: 200.w,
                              height: 200.w,
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: Text('Gagal memuat QR'),
                              ),
                            ),
                          ),
                        ),
                      SizedBox(height: 20.h),

                      // Button Buka GoPay - PERBAIKAN: Gunakan payment
                      if (paymentData['status'] == 'PENDING')
                        SizedBox(
                          width: double.infinity,
                          height: 50.h,
                          child: ElevatedButton.icon(
                            onPressed: isLaunchingApp ? null : _launchGoPay,
                            icon: isLaunchingApp
                                ? SizedBox(
                                    width: 20.w,
                                    height: 20.h,
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Icon(
                                    Icons.open_in_new,
                                    color: AppColors.white,
                                    size: 20.sp,
                                  ),
                            label: Text(
                              isLaunchingApp
                                  ? 'Membuka...'
                                  : 'Buka Halaman Pembayaran',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontFamily: 'SemiBold',
                                color: AppColors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      SizedBox(height: 12.h),

                      // // Copy Link - PERBAIKAN: Gunakan payment
                      // if (payment['payment_deeplink'] != null)
                      //   GestureDetector(
                      //     onTap: () =>
                      //         _copyToClipboard(payment['payment_deeplink']),
                      //     child: Row(
                      //       mainAxisAlignment: MainAxisAlignment.center,
                      //       children: [
                      //         Icon(Icons.copy,
                      //             size: 16.sp, color: Colors.green),
                      //         SizedBox(width: 8.w),
                      //         Text(
                      //           'Salin Link Pembayaran',
                      //           style: TextStyle(
                      //             fontSize: 12.sp,
                      //             fontFamily: 'SemiBold',
                      //             color: Colors.green,
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                    ],
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14.0),
                  child: Divider(),
                ),

                // Total Tagihan - PERBAIKAN: Gunakan paymentData
                Text(
                  'Total Tagihan',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontFamily: 'Medium',
                    color: AppColors.greyPrice,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  formatCurrency(payment['gross_amount'].toString()),
                  style: TextStyle(
                    fontFamily: 'SemiBold',
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 24.h),

                // Instruksi
                Text(
                  'Instruksi Pembayaran GoPay:',
                  style: TextStyle(
                    fontFamily: 'SemiBold',
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  '1. Klik tombol "Buka Aplikasi GoPay" di atas.',
                  style: TextStyle(fontSize: 12.sp),
                ),
                SizedBox(height: 6.h),
                Text(
                  '2. Atau scan QR code menggunakan aplikasi GoPay.',
                  style: TextStyle(fontSize: 12.sp),
                ),
                SizedBox(height: 6.h),
                Text(
                  '3. Pastikan total tagihan sudah benar.',
                  style: TextStyle(fontSize: 12.sp),
                ),
                SizedBox(height: 6.h),
                Text(
                  '4. Selesaikan pembayaran di aplikasi GoPay.',
                  style: TextStyle(fontSize: 12.sp),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
