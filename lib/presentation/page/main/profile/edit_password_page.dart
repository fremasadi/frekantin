import 'package:e_kantin/core/constant/colors.dart';
import 'package:e_kantin/presentation/page/widgets/input_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../bloc/user/edit_password_bloc.dart';

class EditPasswordPage extends StatefulWidget {
  const EditPasswordPage({super.key});

  @override
  State<EditPasswordPage> createState() => _EditPasswordPageState();
}

class _EditPasswordPageState extends State<EditPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<EditPasswordBloc>().add(
            SubmitEditPassword(
              currentPassword: currentPasswordController.text,
              newPassword: newPasswordController.text,
              confirmPassword: confirmPasswordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ganti Kata Sandi',
          style: TextStyle(
            fontSize: 16.sp,
            fontFamily: 'SemiBold',
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocConsumer<EditPasswordBloc, EditPasswordState>(
        listener: (context, state) {
          if (state is EditPasswordSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            Navigator.pop(context);
          } else if (state is EditPasswordError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: EdgeInsets.all(16.w),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  InputTextFormField(
                    controller: currentPasswordController,
                    hint: 'Kata sandi lama',
                    isSecureField: true,
                    validation: (value) => value == null || value.isEmpty
                        ? 'Harap isi kata sandi lama'
                        : null,
                  ),
                  SizedBox(height: 16.h),
                  InputTextFormField(
                    controller: newPasswordController,
                    hint: 'Kata sandi baru',
                    isSecureField: true,
                    validation: (value) => value == null || value.length < 8
                        ? 'Minimal 8 karakter'
                        : null,
                  ),
                  SizedBox(height: 16.h),
                  InputTextFormField(
                    controller: confirmPasswordController,
                    hint: 'Konfirmasi kata sandi',
                    isSecureField: true,
                    validation: (value) => value != newPasswordController.text
                        ? 'Konfirmasi tidak cocok'
                        : null,
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton(
                    onPressed: state is EditPasswordLoading
                        ? null
                        : () => _submit(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: Size(double.infinity, 48.h),
                    ),
                    child: state is EditPasswordLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Simpan Perubahan',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontFamily: 'SemiBold',
                              color: AppColors.white,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
