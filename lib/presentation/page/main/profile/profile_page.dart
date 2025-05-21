import 'package:e_kantin/core/constant/colors.dart';
import 'package:e_kantin/core/router/app_router.dart';
import 'package:e_kantin/presentation/page/main/profile/edit_password_page.dart';
import 'package:e_kantin/presentation/page/main/profile/editprofile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../bloc/auth/auth_bloc.dart';
import '../../../bloc/auth/auth_event.dart';
import '../../../bloc/auth/auth_state.dart';
import '../../../bloc/user/user_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back,
              size: 28.sp,
              color: AppColors.primary,
            )),
        backgroundColor: AppColors.white,
        centerTitle: false,
        title: Text(
          'Profilku',
          style: TextStyle(
            fontSize: 16.sp,
            fontFamily: 'SemiBold',
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                BlocBuilder<UserBloc, UserState>(
                  builder: (context, state) {
                    if (state is UserLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (state is UserLoaded) {
                      final user = state.user;
                      return Row(
                        children: [
                          CircleAvatar(
                            radius: 30.sp,
                            backgroundImage: user.safeImage.isNotEmpty
                                ? NetworkImage(user.safeImage)
                                : const AssetImage(
                                        'assets/images/img_profile.jpg')
                                    as ImageProvider,
                          ),
                          SizedBox(
                            width: 12.sp,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontFamily: 'SemiBold',
                                ),
                              ),
                              Text(
                                user.email,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    } else if (state is UserError) {
                      return Center(
                        child: Text(
                          'Error: ${state.message}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const EditProfilePage()));
                  },
                  icon: Icon(
                    Icons.edit,
                    color: Colors.blue,
                    size: 24.sp,
                  ),
                )
              ],
            ),
            SizedBox(
              height: 8.sp,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0.sp),
              child: Text(
                'Akun',
                style: TextStyle(fontSize: 12.sp, fontFamily: 'Medium'),
              ),
            ),
            GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const EditPasswordPage()));
                },
                child: _buildRow('assets/icons/ic_editsecure.png', 'Keamanan')),
            // _buildRow('assets/icons/ic_notification.png', 'Notification'),
            BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is LogoutSuccess) {
                  Navigator.pushReplacementNamed(context, AppRouter.checkLog);
                } else if (state is LogoutFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Logout gagal. Silakan coba lagi.')),
                  );
                }
              },
              child: Center(
                child: Container(
                  margin: EdgeInsets.only(top: 16.sp),
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.sp, vertical: 2.sp),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(16.sp),
                  ),
                  child: TextButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(LogoutRequested());
                    },
                    child: Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontFamily: 'SemiBold',
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Padding _buildRow(String imgUrl, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Image.asset(
            imgUrl,
            color: Colors.black54,
            width: 25.w,
            height: 25.h,
          ),
          SizedBox(
            width: 12.w,
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              fontFamily: 'Medium',
              color: Colors.black54,
            ),
          ),
          const Spacer(),
          Icon(
            Icons.arrow_forward_ios,
            size: 14.sp,
            color: Colors.black54,
          )
        ],
      ),
    );
  }
}
