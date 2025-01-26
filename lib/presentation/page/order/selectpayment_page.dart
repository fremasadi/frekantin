import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constant/colors.dart';

class SelectpaymentPage extends StatefulWidget {
  const SelectpaymentPage({super.key});

  @override
  State<SelectpaymentPage> createState() => _SelectpaymentPageState();
}

class _SelectpaymentPageState extends State<SelectpaymentPage> {
  String _selectedPayment = '';

  final List<Map<String, String>> paymentMethods = [
    {'icon': 'assets/icons/ic_bca.png', 'text': 'bca'},
    {'icon': 'assets/icons/ic_bri.png', 'text': 'bri'},
    {'icon': 'assets/icons/ic_bni.png', 'text': 'bni'},
    {'icon': 'assets/icons/ic_mandiri.png', 'text': 'mandiri'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            size: 28.sp,
          ),
        ),
        centerTitle: false,
        title: Text(
          'Metode Pembayaran',
          style: TextStyle(
            fontSize: 16.sp,
            color: AppColors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: paymentMethods.length,
              itemBuilder: (context, index) {
                final method = paymentMethods[index];
                return ListTile(
                  leading: Image.asset(
                    method['icon']!,
                    width: 40.w,
                    height: 40.h,
                    fit: BoxFit.contain,
                  ),
                  title: Text(method['text']!),
                  trailing: _selectedPayment == method['text']
                      ? Icon(
                          Icons.check,
                          color: Colors.green,
                          size: 22.sp,
                        )
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedPayment = method['text']!;
                    });
                  },
                );
              },
            ),
          ),
          if (_selectedPayment.isNotEmpty)
            Container(
              padding:
                  EdgeInsets.symmetric(vertical: 7.5.sp, horizontal: 48.sp),
              margin: EdgeInsets.only(bottom: 24.sp),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16.sp),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context,
                      _selectedPayment); // Mengembalikan pilihan ke halaman sebelumnya
                },
                child: Text(
                  'Konfirmasi',
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: 'SemiBold',
                      color: AppColors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
