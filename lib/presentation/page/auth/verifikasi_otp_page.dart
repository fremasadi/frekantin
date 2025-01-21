import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constant/colors.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../widgets/input_form_button.dart';
import 'newpassword_page.dart';

class VerifikasiOtpPage extends StatefulWidget {
  const VerifikasiOtpPage({super.key, required this.email});

  final String email;

  @override
  State<VerifikasiOtpPage> createState() => _VerifikasiOtpPageState();
}

class _VerifikasiOtpPageState extends State<VerifikasiOtpPage> {
  String otp = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'Verifikasi',
          style: TextStyle(
              fontSize: 16.sp, fontFamily: 'SemiBold', color: AppColors.black),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Memverifikasi OTP...')),
            );
          } else if (state is OtpVerified) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => NewPasswordPage(
                    email: widget.email), // Gunakan widget.email
              ),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: EdgeInsets.all(12.0.sp),
            child: Column(
              children: [
                SizedBox(
                  height: 40.h,
                ),
                Center(
                  child: Image.asset(
                    'assets/icons/ic_whatsapp.png',
                    width: 75.w,
                    height: 75.h,
                  ),
                ),
                SizedBox(
                  height: 16.h,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.0.sp),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: 'Kami telah mengirimkan kode OTP 6 digit ke email ',
                      style: TextStyle(
                        color: AppColors.black,
                        fontSize: 14.sp,
                      ),
                      children: [
                        TextSpan(
                          text: widget.email,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 14.sp,
                            fontFamily: 'Bold',
                          ),
                        ),
                        TextSpan(
                          text: '. Silahkan cek pesan pada gmail anda.',
                          style: TextStyle(
                            color: AppColors.black,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 25.h,
                ),
                OtpTextField(
                  numberOfFields: 6,
                  borderColor: AppColors.greyPrice,
                  focusedBorderColor: AppColors.primary,
                  showFieldAsBox: false,
                  fieldWidth: 30.w,
                  borderWidth: 4.0,
                  onSubmit: (String otpValue) {
                    otp = otpValue; // Simpan OTP ke dalam variabel
                  },
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
                      if (otp.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Masukkan OTP terlebih dahulu!')),
                        );
                        return;
                      }
                      context
                          .read<AuthBloc>()
                          .add(VerifyOtpEvent(widget.email, otp));
                    },
                    titleText: 'Verifikasi',
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
