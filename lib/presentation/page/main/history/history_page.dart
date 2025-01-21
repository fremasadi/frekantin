import 'package:e_kantin/core/constant/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  int selectedIndex = 0; // Index untuk menandai tab yang dipilih

  final List<String> tabs = ['Belum Dibayar', 'Diproses', 'Selesai', 'Batal'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: ScreenUtil().statusBarHeight,
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {},
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
                'Pesanan',
                style: TextStyle(
                  fontSize: 16.sp,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.search,
                  size: 28.sp,
                  color: AppColors.primary,
                ),
              )
            ],
          ),
          SizedBox(
            height: 40.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tabs.length,
              itemBuilder: (context, index) {
                final isSelected = selectedIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          tabs[index],
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: isSelected ? AppColors.primary : Colors.grey,
                          ),
                        ),
                        if (isSelected)
                          Container(
                            margin: EdgeInsets.only(top: 4.h),
                            height: 3.h,
                            width: 24.w,
                            color: AppColors.primary,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: Center(
              child: Text(
                'Tab yang dipilih: ${tabs[selectedIndex]}',
                style: TextStyle(fontSize: 16.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
