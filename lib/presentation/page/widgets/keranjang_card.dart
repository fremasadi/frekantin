// keranjang_card.dart - Updated with notes navigation
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constant/colors.dart';
import '../../../core/util/price_converter.dart';
import '../cart/edit_note_page.dart';

class KeranjangCard extends StatefulWidget {
  final int productId;
  final String imageUrl;
  final String title;
  final double price;
  final int initialQuantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback onDelete;
  final bool? isSellerActive;
  final String? notes; // Add notes parameter
  final int itemId; // Add itemId for notes update

  const KeranjangCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.initialQuantity,
    required this.onAdd,
    required this.onRemove,
    required this.productId,
    required this.onDelete,
    required this.itemId, // Make itemId required
    this.isSellerActive,
    this.notes, // Add notes parameter
  });

  @override
  State<KeranjangCard> createState() => _KeranjangCardState();
}

class _KeranjangCardState extends State<KeranjangCard> {
  late int _currentQuantity;

  @override
  void initState() {
    super.initState();
    _currentQuantity = widget.initialQuantity;
  }

  void _increment() {
    // Only allow increment if seller is active
    if (widget.isSellerActive != false) {
      setState(() {
        _currentQuantity++;
      });
      widget.onAdd();
    }
  }

  void _decrement() {
    // Only allow decrement if seller is active
    if (widget.isSellerActive != false && _currentQuantity > 1) {
      setState(() {
        _currentQuantity--;
      });
      widget.onRemove();
    }
  }

  void _navigateToEditNote() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditNotePage(
          itemId: widget.itemId,
          productName: widget.title,
          currentNote: widget.notes ?? '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Apply a filter effect to the entire card if seller is inactive
    final isInactive = widget.isSellerActive == false;
    final hasNotes = widget.notes != null && widget.notes!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ColorFiltered(
                    colorFilter: isInactive
                        ? const ColorFilter.mode(
                            Colors.grey,
                            BlendMode.saturation,
                          )
                        : const ColorFilter.mode(
                            Colors.transparent,
                            BlendMode.srcOver,
                          ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        width: 80.h,
                        height: 80.w,
                        fit: BoxFit.cover,
                        imageUrl: widget.imageUrl,
                      ),
                    ),
                  ),
                  if (isInactive)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 4.h),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Tidak Aktif',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isInactive ? Colors.grey[600] : null,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Rp.${formatPrice(widget.price)}',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                color:
                                    isInactive ? Colors.grey[600] : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        GestureDetector(
                          onTap: widget.onDelete,
                          child: Image.asset(
                            'assets/icons/delete.png',
                            width: 25.w,
                            height: 25.h,
                            color: Colors.red,
                          ),
                        )
                      ],
                    ),
                    // Show current notes if exists
                    if (hasNotes) ...[
                      SizedBox(height: 4.h),
                      Text(
                        'Catatan: ${widget.notes}',
                        style: TextStyle(
                          fontFamily: 'Medium',
                          fontSize: 10.sp,
                          color: AppColors.greyPrice,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 8.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: _navigateToEditNote,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 4.h, horizontal: 12.sp),
                  decoration: BoxDecoration(
                    color: hasNotes
                        ? AppColors.secondary.withOpacity(0.1)
                        : AppColors.grey,
                    borderRadius: BorderRadius.circular(12.sp),
                    border: hasNotes
                        ? Border.all(
                            color: AppColors.secondary.withOpacity(0.3))
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        hasNotes ? Icons.edit_note : Icons.edit,
                        color: hasNotes
                            ? AppColors.secondary
                            : AppColors.greyPrice,
                        size: 16.sp,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        hasNotes ? 'Edit Catatan' : 'Tambah Catatan',
                        style: TextStyle(
                          fontFamily: 'SemiBold',
                          fontSize: 12.sp,
                          color: hasNotes
                              ? AppColors.secondary
                              : AppColors.greyPrice,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: isInactive ? null : _decrement,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                        color: isInactive ? Colors.grey[200] : null,
                      ),
                      child: Icon(
                        Icons.remove,
                        color: isInactive ? Colors.grey[400] : AppColors.black,
                        size: 18.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    '$_currentQuantity',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: isInactive ? Colors.grey[600] : null,
                        ),
                  ),
                  SizedBox(width: 12.w),
                  GestureDetector(
                    onTap: isInactive ? null : _increment,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                        color: isInactive ? Colors.grey[200] : null,
                      ),
                      child: Icon(
                        Icons.add,
                        color:
                            isInactive ? Colors.grey[400] : AppColors.secondary,
                        size: 18.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
