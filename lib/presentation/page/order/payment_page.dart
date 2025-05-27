import 'dart:async';
import 'dart:convert';

import 'package:e_kantin/core/util/date_coverter.dart';
import 'package:e_kantin/core/util/price_converter.dart';
import 'package:e_kantin/presentation/page/main/base_page.dart';
import 'package:e_kantin/presentation/page/widgets/input_form_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import untuk Clipboard
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constant/colors.dart';
import '../../../data/repository/firebase_service.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({
    super.key,
    required this.response,
  });

  final Map<String, dynamic> response;

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late Map<String, dynamic> paymentData;
  final FirebaseService _firebaseService = FirebaseService();

  late Timer _timer;
  int _remainingSeconds = 0;
  bool isAlreadyPaid = false;

  void startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        // Check if widget is still mounted
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

    final orders = widget.response['orders'];
    final payment = widget.response['payment'];

    if (orders == null || payment == null) {
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

    final paymentGatewayResponse = payment['payment_gateway_response'];
    final parsedResponse = paymentGatewayResponse is String
        ? jsonDecode(paymentGatewayResponse)
        : paymentGatewayResponse;

    final expiryTimeString = parsedResponse['expiry_time'];
    if (expiryTimeString == null) {
      throw Exception('expiry_time is missing or null');
    }

    final expiryTime = DateTime.parse(expiryTimeString).toLocal();
    final now = DateTime.now();
    _remainingSeconds = expiryTime.difference(now).inSeconds;
    _remainingSeconds = _remainingSeconds > 0 ? _remainingSeconds : 0;

    startCountdown();

    // Set up Firebase listener with mounted check
    _firebaseService.listenToOrder(paymentData['order_id'], (updatedOrder) {
      if (updatedOrder != null && mounted) {
        // Check if widget is still mounted
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

  @override
  Widget build(BuildContext context) {
    final payment = widget.response['payment'];
    // Fungsi untuk menyalin teks ke clipboard
    void copyToClipboard(BuildContext context, String text) {
      Clipboard.setData(ClipboardData(text: text)).then((_) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'berhasil disalin',
              style: TextStyle(fontSize: 14.sp),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      });
    }

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
            onPressed: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const BasePage()));
            },
            icon: Icon(
              Icons.arrow_back,
              size: 28.sp,
              color: AppColors.primary,
            ),
          ),
          centerTitle: false,
          title: Text(
            'Pembayaran',
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
                      padding: EdgeInsets.symmetric(
                          vertical: 8.sp, horizontal: 16.sp),
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
              Text(
                'Nomor Virtual Account ${payment['payment_va_name']}',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontFamily: 'Medium',
                  color: AppColors.greyPrice,
                ),
              ),
              SizedBox(
                width: 8.w,
              ),
              Row(
                children: [
                  Text(
                    '${payment['payment_va_number']}',
                    style: TextStyle(
                      fontFamily: 'SemiBold',
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(
                    width: 8.w,
                  ),
                  GestureDetector(
                    onTap: () {
                      // Panggil fungsi untuk menyalin teks
                      copyToClipboard(
                          context, '${payment['payment_va_number']}');
                    },
                    child: Image.asset(
                      'assets/icons/ic_copy.png',
                      width: 25.w,
                      height: 25.h,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 16.h,
              ),
              Text(
                'Total Tagihan',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontFamily: 'Medium',
                  color: AppColors.greyPrice,
                ),
              ),
              SizedBox(
                width: 8.w,
              ),
              Text(
                formatCurrency(payment['gross_amount'].toString()),
                style: TextStyle(
                  fontFamily: 'SemiBold',
                  fontSize: 14.sp,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 14.0),
                child: Divider(),
              ),
              Text(
                'Metode Bayar',
                style: TextStyle(
                  fontFamily: 'SemiBold',
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(
                height: 16.h,
              ),
              Text(
                '1. Pilih m-Transfer > Virtual Account',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: 'Medium',
                ),
              ),
              SizedBox(
                height: 8.h,
              ),
              Text(
                '2. Masukkan nomor Virtual Account ${payment['payment_va_name']} dan pilih Send',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: 'Medium',
                ),
              ),
              SizedBox(
                height: 8.h,
              ),
              Text(
                '3. Periksa informasi yang tertera di layar. Pastikan merchant adalah Kantin Ngudi. Total tagihan sudah benar. Jika benar, pilih Ya',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: 'Medium',
                ),
              ),
              SizedBox(
                height: 8.h,
              ),
              Text(
                '4. Masukkan pin Anda dan pilih OK',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: 'Medium',
                ),
              ),
              SizedBox(
                height: 24.h,
              ),
              InputFormButton(
                onClick: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const BasePage()));
                },
                titleText: 'Dashboard',
                color: AppColors.primary,
              )
            ],
          ),
        ),
      ),
    );
  }
}
