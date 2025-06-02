// pages/cart/edit_note_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constant/colors.dart';
import '../../bloc/cart/cart_bloc.dart';
import '../../bloc/cart/cart_event.dart';
import '../../bloc/cart/cart_state.dart';

class EditNotePage extends StatefulWidget {
  final int itemId;
  final String productName;
  final String currentNote;

  const EditNotePage({
    super.key,
    required this.itemId,
    required this.productName,
    required this.currentNote,
  });

  @override
  State<EditNotePage> createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  late TextEditingController _noteController;
  bool _isChanged = false;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.currentNote);
    _noteController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _noteController.removeListener(_onTextChanged);
    _noteController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _isChanged = _noteController.text != widget.currentNote;
    });
  }

  void _saveNote() {
    if (_noteController.text.trim() != widget.currentNote) {
      context.read<CartBloc>().add(
            UpdateCartItemNotes(widget.itemId, _noteController.text.trim()),
          );
    } else {
      Navigator.pop(context);
    }
  }

  void _showDiscardDialog() {
    if (_isChanged) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: AppColors.white,
            title: const Text('Buang Perubahan?'),
            content: const Text(
              'Anda memiliki perubahan yang belum disimpan. Apakah Anda yakin ingin keluar tanpa menyimpan?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Close edit page
                },
                child: const Text(
                  'Buang',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          );
        },
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CartBloc, CartState>(
      listener: (context, state) {
        if (state is CartActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else if (state is CartError) {
          print(state.message);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: _showDiscardDialog,
          ),
          title: Text(
            'Edit Catatan',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            BlocBuilder<CartBloc, CartState>(
              builder: (context, state) {
                final isLoading = state is CartLoading;
                return TextButton(
                  onPressed: isLoading || !_isChanged ? null : _saveNote,
                  child: isLoading
                      ? SizedBox(
                          width: 20.w,
                          height: 20.h,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Simpan',
                          style: TextStyle(
                            color:
                                _isChanged ? AppColors.secondary : Colors.grey,
                            fontSize: 16.sp,
                            fontFamily: 'SemiBold',
                          ),
                        ),
                );
              },
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.all(16.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product info card
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.fastfood,
                        color: AppColors.secondary,
                        size: 24.sp,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          widget.productName,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontFamily: 'SemiBold',
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 8.h),

                // Note input section
                Text(
                  'Catatan untuk Penjual',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                SizedBox(height: 8.h),

                Text(
                  'Tambahkan catatan khusus untuk pesanan ini (opsional)',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),

                SizedBox(height: 16.h),

                // Text input field
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: TextField(
                    controller: _noteController,
                    maxLines: 5,
                    maxLength: 200,
                    decoration: InputDecoration(
                      hintText: 'Contoh: Tidak pedas, nasi terpisah, dll...',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14.sp,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16.w),
                      counterStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12.sp,
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.black87,
                    ),
                  ),
                ),

                SizedBox(height: 16.h),

                // Helper text
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16.sp,
                      color: Colors.grey[500],
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Catatan akan diteruskan kepada penjual untuk membantu menyiapkan pesanan sesuai keinginan Anda',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
