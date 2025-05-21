import 'dart:io';

import 'package:e_kantin/core/constant/colors.dart';
import 'package:e_kantin/data/repository/auth_repository.dart';
import 'package:e_kantin/data/repository/category_repository.dart';
import 'package:e_kantin/data/repository/order_repository.dart';
import 'package:e_kantin/data/repository/table_repository.dart';
import 'package:e_kantin/data/repository/user_repository.dart';
import 'package:e_kantin/presentation/bloc/auth/auth_state.dart';
import 'package:e_kantin/presentation/bloc/cart/cart_bloc.dart';
import 'package:e_kantin/presentation/bloc/cart/cart_event.dart';
import 'package:e_kantin/presentation/bloc/category/category_bloc.dart';
import 'package:e_kantin/presentation/bloc/category/category_state.dart';
import 'package:e_kantin/presentation/bloc/content/content_bloc.dart';
import 'package:e_kantin/presentation/bloc/order/order_bloc.dart';
import 'package:e_kantin/presentation/bloc/product/product_bloc.dart';
import 'package:e_kantin/presentation/bloc/productbycategory/product_by_category.dart';
import 'package:e_kantin/presentation/bloc/review/review_bloc.dart';
import 'package:e_kantin/presentation/bloc/search_product/search_product_bloc.dart';
import 'package:e_kantin/presentation/bloc/table_number/table_number_bloc.dart';
import 'package:e_kantin/presentation/bloc/user/edit_password_bloc.dart';
import 'package:e_kantin/presentation/bloc/user/user_bloc.dart';
import 'package:e_kantin/presentation/page/main/profile/edit_password_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/router/app_router.dart';
import 'data/repository/cart_repository.dart';
import 'data/repository/content_repository.dart';
import 'data/repository/edit_password_repository.dart';
import 'data/repository/product_repository.dart';
import 'data/repository/review_repository.dart';
import 'data/service/notification_service.dart';
import 'presentation/bloc/auth/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    FirebaseOptions firebaseOptions = Platform.isIOS
        ? const FirebaseOptions(
            apiKey: 'AIzaSyDs1BXE6XgW7RaCwLx9jrSnfuAmnlQSZ3I',
            appId: '1:1043350175679:ios:eda4a92cb5b984c34fab0a',
            messagingSenderId: '1043350175679',
            projectId: 'fre-kantin',
          )
        : const FirebaseOptions(
            apiKey: 'AIzaSyCNjnbWpe0UZ6ykxAz0mTVjctZwO2T-WjA',
            appId: '1:1043350175679:android:595d191fc9ca134b4fab0a',
            messagingSenderId: '1043350175679',
            projectId: 'fre-kantin',
          );
    await Firebase.initializeApp(options: firebaseOptions);
  } catch (e) {
    throw ('error init firebase main');
  }

  final notificationService = NotificationService();
  await notificationService.initialize();
  AuthRepository().updateFcmToken(); // Perbarui token jika berubah

  // Inisialisasi repositories
  final authRepository = AuthRepository();
  final categoryRepository = CategoryRepository();
  final productRepository = ProductRepository();
  final cartRepository = CartRepository();
  final userRepository = UserRepository();
  final reviewRepository = ReviewRepository(); // Tambahkan ini
  final contentRepository = ContentRepository();

  runApp(MyApp(
    authRepository: authRepository,
    categoryRepository: categoryRepository,
    productRepository: productRepository,
    cartRepository: cartRepository,
    userRepository: userRepository,
    reviewRepository: reviewRepository,
    // Tambahkan ini
    contentRepository: contentRepository, // Tambahkan ini
  ));
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final CategoryRepository categoryRepository;
  final ProductRepository productRepository;
  final CartRepository cartRepository;
  final UserRepository userRepository;
  final ReviewRepository reviewRepository; // Tambahkan ini
  final ContentRepository contentRepository; // Tambahkan ini

  const MyApp({
    super.key,
    required this.authRepository,
    required this.categoryRepository,
    required this.productRepository,
    required this.cartRepository,
    required this.userRepository,
    required this.reviewRepository,
    required this.contentRepository, // Tambahkan ini
  });

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      minTextAdapt: true,
      builder: (context, child) {
        return MultiRepositoryProvider(
          providers: [
            RepositoryProvider.value(value: reviewRepository),
            RepositoryProvider.value(value: contentRepository), // Tambahkan ini
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>(
                create: (context) => AuthBloc(authRepository),
              ),
              BlocProvider<UserBloc>(
                  create: (context) =>
                      UserBloc(userRepository)..add(FetchUserEvent())),
              BlocProvider<CategoryBloc>(
                lazy: false,
                create: (context) =>
                    CategoryBloc(categoryRepository)..add(FetchCategories()),
              ),
              BlocProvider<ProductBloc>(
                  lazy: false,
                  create: (context) =>
                      ProductBloc(repository: productRepository)
                        ..fetchProducts()),
              BlocProvider<CartBloc>(
                lazy: false,
                create: (context) => CartBloc(cartRepository)..add(LoadCart()),
              ),
              BlocProvider<ProductByCategoryBloc>(
                create: (context) =>
                    ProductByCategoryBloc(repository: productRepository),
              ),
              BlocProvider(
                create: (context) =>
                    SearchProductBloc(productRepository: ProductRepository()),
              ),
              BlocProvider(
                create: (context) =>
                    EditPasswordBloc(repository: EditPasswordRepository()),
                child: const EditPasswordPage(),
              ),
              BlocProvider(
                create: (context) =>
                    OrderBloc(orderRepository: OrderRepository()),
              ),
              BlocProvider(
                create: (context) =>
                    TableNumberBloc(repository: TableNumberRepository()),
              ),
              BlocProvider<ReviewBloc>(
                create: (context) =>
                    ReviewBloc(repository: ReviewRepository(), productId: 0),
              ),
              BlocProvider<ImageContentBloc>(
                create: (context) =>
                    ImageContentBloc(repository: contentRepository)
                      ..add(FetchActiveImagesEvent()),
              ),
            ],
            child: BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthSuccess) {
                  context.read<CategoryBloc>().add(FetchCategories());
                  context.read<ProductBloc>().fetchProducts();
                  context.read<CartBloc>().add(LoadCart());
                }
              },
              child: MaterialApp(
                builder: (context, child) {
                  final MediaQueryData data = MediaQuery.of(context);
                  return MediaQuery(
                    data: data.copyWith(
                      textScaler: const TextScaler.linear(1.10),
                    ),
                    child: child!,
                  );
                },
                theme: ThemeData(
                  scaffoldBackgroundColor: AppColors.white,
                  fontFamily: 'Poppins',
                ),
                initialRoute: AppRouter.checkLog,
                onGenerateRoute: AppRouter.onGenerateRoute,
                debugShowCheckedModeBanner: false,
              ),
            ),
          ),
        );
      },
    );
  }
}
