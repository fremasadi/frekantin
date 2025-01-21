import 'package:e_kantin/core/constant/colors.dart';
import 'package:e_kantin/data/repository/auth_repository.dart';
import 'package:e_kantin/data/repository/category_repository.dart';
import 'package:e_kantin/data/repository/user_repository.dart';
import 'package:e_kantin/presentation/bloc/auth/auth_state.dart';
import 'package:e_kantin/presentation/bloc/cart/cart_bloc.dart';
import 'package:e_kantin/presentation/bloc/cart/cart_event.dart';
import 'package:e_kantin/presentation/bloc/category/category_bloc.dart';
import 'package:e_kantin/presentation/bloc/category/category_state.dart';
import 'package:e_kantin/presentation/bloc/product/product_bloc.dart';
import 'package:e_kantin/presentation/bloc/productbycategory/ProductByCategoryBloc.dart';
import 'package:e_kantin/presentation/bloc/search_product/search_product_bloc.dart';
import 'package:e_kantin/presentation/bloc/user/user_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/router/app_router.dart';
import 'data/repository/cart_repository.dart';
import 'data/repository/product_repository.dart';
import 'presentation/bloc/auth/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi repositories
  final authRepository = AuthRepository();
  final categoryRepository = CategoryRepository();
  final productRepository = ProductRepository();
  final cartRepository = CartRepository();
  final userRepository = UserRepository();

  runApp(MyApp(
    authRepository: authRepository,
    categoryRepository: categoryRepository,
    productRepository: productRepository,
    cartRepository: cartRepository,
    userRepository: userRepository,
  ));
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final CategoryRepository categoryRepository;
  final ProductRepository productRepository;
  final CartRepository cartRepository;
  final UserRepository userRepository;

  const MyApp({
    super.key,
    required this.authRepository,
    required this.categoryRepository,
    required this.productRepository,
    required this.cartRepository,
    required this.userRepository,
  });

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, child) {
        return MultiBlocProvider(
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
                create: (context) => ProductBloc(repository: productRepository)
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
        );
      },
    );
  }
}
