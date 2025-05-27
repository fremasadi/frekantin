import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constant/colors.dart';
import '../../../core/util/date_coverter.dart';
import '../../../core/util/price_converter.dart';
import '../../../data/repository/firebase_service.dart';

class SnapPaymentPage extends StatefulWidget {
  const SnapPaymentPage({
    super.key,
    required this.response,
  });

  final Map<String, dynamic> response;

  @override
  State<SnapPaymentPage> createState() => _SnapPaymentPageState();
}

class _SnapPaymentPageState extends State<SnapPaymentPage> {
  late Map<String, dynamic> payment;
  late int _remainingSeconds;
  late Timer _timer;
  final FirebaseService _firebaseService = FirebaseService();
  late Map<String, dynamic> paymentData;
  bool isAlreadyPaid = false;

  void startCountdown() {
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

  @override
  void initState() {
    super.initState();

    payment = widget.response['payment'];
    paymentData = payment; // ✅ inisialisasi awal agar tidak error

    final gatewayResponse = payment['payment_gateway_response'];
    final parsed = gatewayResponse is String
        ? jsonDecode(gatewayResponse)
        : gatewayResponse;

    final expiry = DateTime.parse(parsed['expiry_time']).toLocal();
    final now = DateTime.now();
    _remainingSeconds = expiry.difference(now).inSeconds;
    _remainingSeconds = _remainingSeconds > 0 ? _remainingSeconds : 0;

    startCountdown();

    // ✅ Pastikan paymentData sudah ada sebelum dipakai
    _firebaseService.listenToOrder(paymentData['order_id'].toString(),
        (updatedOrder) {
      if (updatedOrder != null && mounted) {
        setState(() {
          paymentData = updatedOrder;
        });

        if (updatedOrder['status'] == 'PAID' && !isAlreadyPaid) {
          isAlreadyPaid = true;
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
                        color: AppColors.primary),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Terima kasih sudah melakukan pembayaran',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 12.sp, color: AppColors.greyPrice),
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
                      'Ok',
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
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'URL berhasil disalin',
            style: TextStyle(fontSize: 14.sp),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final qrUrl = payment['payment_qr_url'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, size: 28.sp, color: AppColors.primary),
        ),
        centerTitle: false,
        title: Text(
          'Pembayaran QRIS',
          style: TextStyle(
            fontSize: 16.sp,
            fontFamily: 'SemiBold',
            color: AppColors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                SizedBox(
                  width: 12.w,
                ),
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
                      formatDate(payment['expired_at']),
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
                    padding:
                        EdgeInsets.symmetric(vertical: 8.sp, horizontal: 16.sp),
                    decoration: BoxDecoration(
                      color: AppColors.primary
                          .withAlpha((255 * 0.2).toInt()), // Menghitung alpha
                      borderRadius: BorderRadius.circular(80.r),
                    ),
                    child: Text(
                      _formatTime(_remainingSeconds - 8),
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontFamily: 'SemiBold',
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14.0),
              child: Divider(),
            ),
            Center(
              child: Column(
                children: [
                  Text(
                    'Silakan scan QR berikut:',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontFamily: 'Medium',
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Image.network(
                    qrUrl,
                    width: 200.w,
                    height: 200.w,
                    errorBuilder: (_, __, ___) => const Text('Gagal memuat QR'),
                  ),
                  SizedBox(height: 12.h),
                  GestureDetector(
                    onTap: () => _copyToClipboard(qrUrl),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.copy, size: 20.sp, color: AppColors.primary),
                        SizedBox(width: 8.w),
                        Text(
                          'Salin URL QR',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontFamily: 'SemiBold',
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14.0),
              child: Divider(),
            ),
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
            Text(
              'Instruksi Pembayaran QRIS:',
              style: TextStyle(
                fontFamily: 'SemiBold',
                fontSize: 12.sp,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              '1. Buka aplikasi pembayaran yang mendukung QRIS.',
              style: TextStyle(fontSize: 12.sp),
            ),
            SizedBox(height: 6.h),
            Text(
              '2. Scan QR di atas atau salin URL-nya.',
              style: TextStyle(fontSize: 12.sp),
            ),
            SizedBox(height: 6.h),
            Text(
              '3. Pastikan total tagihan dan merchant sudah benar.',
              style: TextStyle(fontSize: 12.sp),
            ),
            SizedBox(height: 6.h),
            Text(
              '4. Selesaikan pembayaran.',
              style: TextStyle(fontSize: 12.sp),
            ),
          ],
        ),
      ),
    );
  }
}
