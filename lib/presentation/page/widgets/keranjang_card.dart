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
  final int initialQuantity; // Ganti quantity menjadi initialQuantity
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback onDelete;

  const KeranjangCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.initialQuantity, // Ganti di sini
    required this.onAdd,
    required this.onRemove,
    required this.productId,
    required this.onDelete,
  });

  @override
  State<KeranjangCard> createState() => _KeranjangCardState();
}

class _KeranjangCardState extends State<KeranjangCard> {
  late int _currentQuantity;
  late TextEditingController noteController; // Declare TextEditingController

  @override
  void initState() {
    super.initState();
    _currentQuantity = widget.initialQuantity;
    noteController = TextEditingController(); // Initialize the controller
    _loadNote(); // Load the saved note when initializing the widget
  }

  @override
  void dispose() {
    noteController
        .dispose(); // Dispose the controller when the widget is removed
    super.dispose();
  }

  Future<void> _loadNote() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedNote = prefs.getString('note_${widget.productId}');
    if (savedNote != null) {
      setState(() {
        noteController.text = savedNote; // Set the saved note to the controller
      });
    }
  }

  Future<void> saveNoteToLocal(String productId, String note) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('note_$productId', note);
  }

  void _increment() {
    setState(() {
      _currentQuantity++;
    });
    widget.onAdd();
  }

  void _decrement() {
    if (_currentQuantity > 1) {
      setState(() {
        _currentQuantity--;
      });
      widget.onRemove();
    }
  }

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
                  height: 100.w,
                  fit: BoxFit.cover,
                  imageUrl: widget.imageUrl,
                ),
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
                        GestureDetector(
                          onTap: widget.onDelete,
                          child: Image.asset(
                            'assets/icons/delete.png',
                            width: 25.w,
                            height: 25.h,
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
                              onTap: _decrement,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.remove,
                                  color: AppColors.black,
                                  size: 24.sp,
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              '$_currentQuantity',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            SizedBox(width: 12.w),
                            GestureDetector(
                              onTap: _increment,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.add,
                                  color: AppColors.secondary,
                                  size: 24.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
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
