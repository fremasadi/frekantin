import 'package:flutter/material.dart';

import '../../../core/constant/colors.dart';

class DotsIndicator extends StatelessWidget {
  final int currentPage;
  final int totalDots;

  const DotsIndicator({required this.currentPage, required this.totalDots, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        totalDots,
            (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: currentPage == index
                ? AppColors.primary
                : AppColors.secondary,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}