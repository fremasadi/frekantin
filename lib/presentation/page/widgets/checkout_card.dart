import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/util/price_converter.dart';

class CheckoutCard extends StatefulWidget {
  final String imageUrl;
  final String title;
  final double price;
  final int quantity;
  final String note;

  const CheckoutCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.quantity,
    required this.note,
  });

  @override
  State<CheckoutCard> createState() => _CheckoutCardState();
}

class _CheckoutCardState extends State<CheckoutCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  width: 100.h,
                  height: 70.w,
                  fit: BoxFit.cover,
                  imageUrl: widget.imageUrl,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Rp.${formatPrice(widget.price)}',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Text(
                          '${widget.quantity}x',
                          style:
                              TextStyle(fontSize: 12.sp, fontFamily: 'Medium'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.note.isNotEmpty
                          ? widget.note
                          : 'Tidak ada catatan',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontFamily: 'Medium',
                        color:
                            widget.note.isNotEmpty ? Colors.black : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
