import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mysore_fashion_jewellery_hub/src/core/constants/app_constants.dart';
import 'package:mysore_fashion_jewellery_hub/src/presentation/pages/cart/cart_page.dart';
import 'package:mysore_fashion_jewellery_hub/src/presentation/pages/landing_screen.dart';
import 'package:mysore_fashion_jewellery_hub/src/presentation/pages/lrf/Profile_screen.dart';
import 'package:mysore_fashion_jewellery_hub/src/presentation/pages/lrf/otp_page.dart';
import 'package:mysore_fashion_jewellery_hub/src/presentation/pages/lrf/sign_up_page.dart';
import 'package:mysore_fashion_jewellery_hub/src/presentation/pages/product_detail/product_detail_screen.dart';
import 'package:mysore_fashion_jewellery_hub/src/presentation/pages/splash_screen.dart';

import '../../data/models/product.dart';
import '../../presentation/pages/address/add_address.dart';


class AppRouteName {
  static const String splash = 'splash';
  static const String notFound = 'notFound';
  static const String login = 'login';
  static const String signUp = 'signUp';
  static const String landingPage = 'landingPage';
  static const String home = 'home';
  static const String otp = 'otp';
  static const String profile = 'profile';
  static const String productDetails = 'productDetails';
  static const String cart = 'cart';
  static const String categories = 'categories';
  static const String brands = 'brands';
  static const String addAddress = 'addAddress';
}


class AppRoutes {
  static const String splash = '/';
  static const String notFound = '/not-found';
  static const String login = '/login';
  static const String signUp = '/signUp';
  static const String landingPage = '/landingPage';
  static const String home = '/home';
  static const String otp = '/otp';
  static const String profile = '/profile';
  static const String productDetails = '/productDetails';
  static const String cart = '/cart';
  static const String categories = '/categories';
  static const String brands = '/brands';
  static const String addAddress = '/add-address';
}

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) {
        return SplashScreen();
      },
      pageBuilder: defaultPageBuilder(SplashScreen()),
    ),

    ///create a route for landing page
    GoRoute(
      path: AppRoutes.landingPage,
      builder: (context, state) {
        return LandingPage();
      },
      pageBuilder: defaultPageBuilder(LandingPage()),
    ),

    GoRoute(
      path: AppRoutes.otp,
      builder: (context, state) {
        // Extract the phone number from extra
        final Map<String, dynamic>? extra =
            state.extra as Map<String, dynamic>?;
        final String phoneNumber = extra?[AppConstants.phoneNumber] ?? '';
        final bool isFromLogin = extra?[AppConstants.isFromLogin] ?? false;
        return OtpPage(phoneNumber: phoneNumber, isFromLogin: isFromLogin);
      },
      pageBuilder: (context, state) {
        final Map<String, dynamic>? extra =
            state.extra as Map<String, dynamic>?;
        final String phoneNumber = extra?[AppConstants.phoneNumber] ?? '';
        final bool isFromLogin = extra?[AppConstants.isFromLogin] ?? false;
        return defaultPageBuilder(
          OtpPage(phoneNumber: phoneNumber, isFromLogin: isFromLogin),
        )(context, state);
      },
    ),

    GoRoute(
      path: AppRoutes.signUp,
      builder: (context, state) {
        // Extract the phone number from extra
        final Map<String, dynamic>? extra =
            state.extra as Map<String, dynamic>?;
        final String phoneNumber = extra?[AppConstants.phoneNumber] ?? '';
        return SignUpPage(phoneNumber: phoneNumber);
      },
      pageBuilder: (context, state) {
        final Map<String, dynamic>? extra =
            state.extra as Map<String, dynamic>?;
        final String phoneNumber = extra?[AppConstants.phoneNumber] ?? '';
        return defaultPageBuilder(SignUpPage(phoneNumber: phoneNumber))(
          context,
          state,
        );
      },
    ),

    ///Profile Screen
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) {
        return ProfileScreen();
      },
      pageBuilder: defaultPageBuilder(ProfileScreen()),
    ),

    ///Product Details Screen
    GoRoute(
      path: AppRoutes.productDetails,
      builder: (context, state) {
        final Map<String, dynamic>? extra =
            state.extra as Map<String, dynamic>?;
        final String productId = extra?[AppConstants.productId] ?? '';
        return ProductDetailPage(productId: productId);
      },
      pageBuilder: (context, state) {
        final Map<String, dynamic>? extra =
            state.extra as Map<String, dynamic>?;
        final String productId = extra?[AppConstants.productId] ?? '';

        return defaultPageBuilder(ProductDetailPage(productId: productId))(
          context,
          state,
        );
      },
    ),

    /// add Address Screen
    GoRoute(
      path: AppRoutes.addAddress,
      builder: (context, state) {
        // Extract the phone number from extra
        final Map<String, dynamic>? extra =
            state.extra as Map<String, dynamic>?;
        final bool isEdit = extra?[AppConstants.isEdit] ?? '';
        return AddAddressScreen(isEdit: isEdit);
      },
      pageBuilder: (context, state) {
        final Map<String, dynamic>? extra =
            state.extra as Map<String, dynamic>?;
        final bool isEdit = extra?[AppConstants.isEdit] ?? '';
        return defaultPageBuilder(AddAddressScreen(isEdit: isEdit))(context, state);
      },
    ),
  ],
);

CustomTransitionPage buildPageWithDefaultTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder:
        (context, animation, secondaryAnimation, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.3, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(animation),
            child: child,
          ),
        ),
  );
}

Page<dynamic> Function(BuildContext, GoRouterState) defaultPageBuilder<T>(
  Widget child,
) => (BuildContext context, GoRouterState state) {
  return buildPageWithDefaultTransition<T>(
    context: context,
    state: state,
    child: child,
  );
};
