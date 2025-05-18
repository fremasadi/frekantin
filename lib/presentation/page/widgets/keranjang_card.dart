// keranjang_card.dart - Updated with seller status handling
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/util/price_converter.dart';
import '../../../core/constant/colors.dart';

class KeranjangCard extends StatefulWidget {
  final int productId;
  final String imageUrl;
  final String title;
  final double price;
  final int initialQuantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback onDelete;
  final bool? isSellerActive; // New property for seller active status

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
    this.isSellerActive, // Add this parameter
  });

  @override
  State<KeranjangCard> createState() => _KeranjangCardState();
}

class _KeranjangCardState extends State<KeranjangCard> {
  late int _currentQuantity;
  late TextEditingController noteController;

  @override
  void initState() {
    super.initState();
    _currentQuantity = widget.initialQuantity;
    noteController = TextEditingController();
    _loadNote();
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  Future<void> _loadNote() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedNote = prefs.getString('note_${widget.productId}');
    if (savedNote != null) {
      setState(() {
        noteController.text = savedNote;
      });
    }
  }

  Future<void> saveNoteToLocal(String productId, String note) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('note_$productId', note);
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

  @override
  Widget build(BuildContext context) {
    // Apply a filter effect to the entire card if seller is inactive
    final isInactive = widget.isSellerActive == false;

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
                        width: 100.h,
                        height: 100.w,
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
                            // color: isInactive ? Colors.grey[600] : null,
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 12.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: isInactive ? null : _decrement,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                  color: isInactive ? Colors.grey[200] : null,
                                ),
                                child: Icon(
                                  Icons.remove,
                                  color: isInactive
                                      ? Colors.grey[400]
                                      : AppColors.black,
                                  size: 24.sp,
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              '$_currentQuantity',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: isInactive ? Colors.grey[600] : null,
                                  ),
                            ),
                            SizedBox(width: 12.w),
                            GestureDetector(
                              onTap: isInactive ? null : _increment,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                  color: isInactive ? Colors.grey[200] : null,
                                ),
                                child: Icon(
                                  Icons.add,
                                  color: isInactive
                                      ? Colors.grey[400]
                                      : AppColors.secondary,
                                  size: 24.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Add message if seller is inactive
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
