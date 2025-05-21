import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constant/colors.dart';
import '../../../../data/repository/edit_profile_repository.dart';
import '../../../bloc/user/edit_profile_bloc.dart';
import '../../../bloc/user/user_bloc.dart';

import '../../widgets/input_text_form_field.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Form key untuk validasi

  bool _isInitialized = false;

  void _initializeUser(UserState state) {
    if (state is UserLoaded && !_isInitialized) {
      nameController.text = state.user.name;
      emailController.text = state.user.email;
      _isInitialized = true; // Supaya tidak di-set ulang tiap build
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EditProfileBloc(repository: EditProfileRepository()),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, size: 28.sp, color: AppColors.primary),
            onPressed: () => Navigator.pop(context),
          ),
          backgroundColor: AppColors.white,
          centerTitle: false,
          title: Text(
            'Edit Profile',
            style: TextStyle(fontSize: 16.sp, fontFamily: 'SemiBold'),
          ),
        ),
        body: BlocListener<EditProfileBloc, EditProfileState>(
          listener: (context, state) {
            if (state is EditProfileSuccess) {
              // Refresh user data after successful update
              context.read<UserBloc>().add(FetchUserEvent());

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );

              // Tunggu sebentar agar user dapat melihat pesan sukses
              Future.delayed(const Duration(seconds: 1), () {
                Navigator.pop(context);
              });
            } else if (state is EditProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: BlocBuilder<UserBloc, UserState>(
            builder: (context, state) {
              _initializeUser(state);

              if (state is UserLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is UserLoaded) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        InputTextFormField(
                          controller: nameController,
                          hint: 'Nama',
                          validation: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nama tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10.h),
                        InputTextFormField(
                          controller: emailController,
                          hint: 'Email',
                          validation: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email tidak boleh kosong';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value)) {
                              return 'Email tidak valid';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20.h),
                        BlocBuilder<EditProfileBloc, EditProfileState>(
                          builder: (context, editProfileState) {
                            bool isLoading =
                                editProfileState is EditProfileLoading;

                            return ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                minimumSize: Size(double.infinity, 48.h),
                              ),
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      if (_formKey.currentState?.validate() ??
                                          false) {
                                        context.read<EditProfileBloc>().add(
                                              SubmitEditProfile(
                                                username: nameController.text,
                                                email: emailController.text,
                                              ),
                                            );
                                      }
                                    },
                              child: isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : Text(
                                      'Simpan',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontFamily: 'SemiBold',
                                        color: AppColors.white,
                                      ),
                                    ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state is UserError) {
                return Center(
                  child: Text('Gagal memuat data: ${state.message}'),
                );
              }

              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }
}
