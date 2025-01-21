import 'package:e_kantin/presentation/page/main/base_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constant/colors.dart';
import '../../../core/router/app_router.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../widgets/input_text_form_field.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> with TickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _logoSizeAnimation;

  bool _showLogo = false;
  bool _animateLogoUp = false;
  bool _showForm = false;

  @override
  void initState() {
    super.initState();
    setupAnimations();
    startAnimationSequence();
  }

  void setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _logoSizeAnimation = Tween<double>(begin: 1.0, end: 0.6).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  void startAnimationSequence() async {
    setState(() => _showLogo = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _animateLogoUp = true);
    _animationController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _showForm = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOut,
              top: _animateLogoUp
                  ? 50.h
                  : MediaQuery.of(context).size.height / 2 - 100.h,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: _showLogo ? 1.0 : 0.0,
                child: AnimatedBuilder(
                  animation: _logoSizeAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoSizeAnimation.value,
                      child: Image.asset(
                        'assets/icons/ic_logo.png',
                        width: 200.w,
                        height: 200.h,
                        fit: BoxFit.contain,
                      ),
                    );
                  },
                ),
              ),
            ),
            // Animated Form
            AnimatedPositioned(
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOut,
              top: _showForm ? 250.h : MediaQuery.of(context).size.height,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: _showForm ? 1.0 : 0.0,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    children: [
                      InputTextFormField(
                        controller: emailController,
                        hint: 'Email',
                        validation: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          // Add more validation if needed (e.g. email format check)
                          return null;
                        },
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 12.h, horizontal: 12.w),
                      ),
                      SizedBox(height: 12.h),
                      InputTextFormField(
                        controller: passwordController,
                        isSecureField: true,
                        hint: 'Password',
                        validation: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 12.h, horizontal: 12.w),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                    context, AppRouter.forgotPassword);
                              },
                              child: Text(
                                'Lupa Password?',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 12.sp),
                        padding: EdgeInsets.symmetric(vertical: 6.sp),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(16.sp),
                        ),
                        child: BlocConsumer<AuthBloc, AuthState>(
                          listener: (context, state) {
                            if (state is AuthSuccess) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const BasePage()));
                            } else if (state is AuthFailure) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(state.message)),
                              );
                            }
                          },
                          builder: (context, state) {
                            if (state is AuthLoading) {
                              return const CircularProgressIndicator();
                            }
                            return TextButton(
                              onPressed: () {
                                BlocProvider.of<AuthBloc>(context).add(
                                  LoginRequested(
                                    emailController.text,
                                    passwordController.text,
                                  ),
                                );
                              },
                              child: Text(
                                'Masuk',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.white,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Text(
                        'atau',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                      SizedBox(height: 12.sp),
                      Image.asset(
                        'assets/icons/ic_google.png',
                        width: 50.w,
                        height: 50.h,
                      ),
                      SizedBox(height: 12.sp),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, AppRouter.signUp);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Belum Punya Akun? ',
                              style: TextStyle(
                                  fontSize: 12.sp, color: AppColors.black),
                            ),
                            Text(
                              'Daftar',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.redAccent,
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
