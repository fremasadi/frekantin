import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:e_kantin/core/constant/colors.dart';
import 'package:e_kantin/core/util/price_converter.dart';
import 'package:e_kantin/data/models/product.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../bloc/cart/cart_bloc.dart';
import '../../../bloc/cart/cart_event.dart';
import '../../../bloc/cart/cart_state.dart';
import '../../widgets/input_form_button.dart';

class DetailProdukPage extends StatelessWidget {
  final Product product;

  const DetailProdukPage({required this.product, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                product.name,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                product.seller.name,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(product.description),
          SizedBox(height: 8.h),
          Text(formatPrice(product.price)),
          SizedBox(height: 16.h),
          BlocConsumer<CartBloc, CartState>(
            listener: (context, state) {
              if (state is CartActionSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
                Navigator.pop(context);
              } else if (state is CartError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            builder: (context, state) {
              if (state is CartLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              return InputFormButton(
                color: AppColors.primary,
                onClick: () {
                  context.read<CartBloc>().add(
                        AddCartItem(product.id, 1),
                      );
                },
                titleText: 'Tambah keranjang',
              );
            },
          ),
        ],
      ),
    );
  }
}
