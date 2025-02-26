import 'package:e_kantin/core/constant/colors.dart';
import 'package:e_kantin/presentation/page/auth/verifikasi_otp_page.dart';
import 'package:e_kantin/presentation/page/widgets/input_form_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/util/email_validasi.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back,
            color: AppColors.primary,
            size: 22.sp,
          ),
        ),
        title: Text(
          'Lupa Password',
          style: TextStyle(
              fontSize: 16.sp, fontFamily: 'SemiBold', color: AppColors.black),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Mengirim OTP...')),
            );
          } else if (state is OtpSent) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    VerifikasiOtpPage(email: _controller.text),
              ),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(12.0.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/images/img_forgotpassword.png',
                      width: 300.w,
                      height: 300.h,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Text(
                    'Lupa Password',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: 'SemiBold',
                    ),
                  ),
                  SizedBox(
                    height: 4.h,
                  ),
                  Text(
                    'Masukkan email anda yang terikat  dengan akun anda dan kami akan mengirimkan  konfirmasi untuk mengatur ulang kata sandi anda.',
                    style: TextStyle(fontSize: 12.sp),
                  ),
                  SizedBox(
                    height: 22.h,
                  ),
                  TextFormField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 60.h,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().screenWidth * .3),
                    child: InputFormButton(
                      color: AppColors.primary,
                      onClick: () {
                        final email = _controller.text.trim();
                        if (email.isEmpty || !isValidEmail(email)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Email tidak valid')),
                          );
                          return;
                        }
                        context.read<AuthBloc>().add(SendOtpEvent(email));
                      },
                      titleText: 'Lanjut',
                    ),
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Sudah Ingat Password? ',
                        style:
                            TextStyle(fontSize: 12.sp, color: AppColors.black),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Login',
                          style: TextStyle(
                              fontSize: 12.sp,
                              fontFamily: 'SemiBold',
                              color: AppColors.primary),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
