import 'package:e_kantin/core/constant/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../widgets/input_form_button.dart';
import '../widgets/input_text_form_field.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  Image.asset('assets/icons/ic_logo.png', height: 80),
                  const SizedBox(height: 20),
                  Text(
                    "Silakan gunakan alamat email Anda untuk membuat akun baru",
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  InputTextFormField(
                    controller: firstNameController,
                    hint: 'nama',
                    textInputAction: TextInputAction.next,
                    validation: (String? val) {
                      return val == null || val.isEmpty
                          ? 'This field can\'t be empty'
                          : null;
                    },
                  ),

                  const SizedBox(height: 12),
                  InputTextFormField(
                    controller: emailController,
                    hint: 'Email',
                    textInputAction: TextInputAction.next,
                    validation: (String? val) {
                      return val == null || val.isEmpty
                          ? 'This field can\'t be empty'
                          : null;
                    },
                  ),
                  const SizedBox(height: 12),
                  InputTextFormField(
                    controller: passwordController,
                    hint: 'Password',
                    textInputAction: TextInputAction.next,
                    isSecureField: true,
                    validation: (String? val) {
                      return val == null || val.isEmpty
                          ? 'This field can\'t be empty'
                          : null;
                    },
                  ),
                  const SizedBox(height: 12),
                  InputTextFormField(
                    controller: confirmPasswordController,
                    hint: 'Konfirmasi Password',
                    isSecureField: true,
                    textInputAction: TextInputAction.go,
                    validation: (String? val) {
                      return val == null || val.isEmpty
                          ? 'This field can\'t be empty'
                          : null;
                    },
                  ),
                  const SizedBox(height: 40),
                  InputFormButton(
                    color: AppColors.primary,
                    onClick: () {
                      if (_formKey.currentState!.validate()) {
                        if (passwordController.text !=
                            confirmPasswordController.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Passwords do not match')));
                        } else {}
                      }
                    },
                    titleText: 'Daftar',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
