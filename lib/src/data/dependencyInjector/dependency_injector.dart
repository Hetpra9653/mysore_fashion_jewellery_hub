import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:mysore_fashion_jewellery_hub/src/data/entity/user_session.dart';
import 'package:mysore_fashion_jewellery_hub/src/data/repositories_implementation/auth/authentication_repository_impl.dart';
import 'package:mysore_fashion_jewellery_hub/src/data/repositories_implementation/category/category_repository_impl.dart';
import 'package:mysore_fashion_jewellery_hub/src/data/repositories_implementation/product/product_repository_impl.dart';
import 'package:mysore_fashion_jewellery_hub/src/domain/repositories/auth/authentication_repository.dart';
import 'package:mysore_fashion_jewellery_hub/src/domain/repositories/category/category_repository.dart';
import 'package:mysore_fashion_jewellery_hub/src/domain/repositories/product/product_repository.dart';
import 'package:mysore_fashion_jewellery_hub/src/domain/use_cases/category/get_all_category_usecase.dart';
import 'package:mysore_fashion_jewellery_hub/src/domain/use_cases/get_banner_image_usecase.dart';
import 'package:mysore_fashion_jewellery_hub/src/domain/use_cases/product/get_all_product_usecase.dart';
import 'package:mysore_fashion_jewellery_hub/src/domain/use_cases/product/get_product_from_id_usecase.dart';
import 'package:mysore_fashion_jewellery_hub/src/domain/use_cases/review/add_review_usecase.dart';
import 'package:mysore_fashion_jewellery_hub/src/domain/use_cases/user/add_user_usecase.dart';
import 'package:mysore_fashion_jewellery_hub/src/domain/use_cases/user/fetch_user_by_phone_number_usecase.dart';
import 'package:mysore_fashion_jewellery_hub/src/presentation/bloc/auth/auth_bloc.dart';
import 'package:mysore_fashion_jewellery_hub/src/presentation/bloc/cart/cart_bloc.dart';
import 'package:mysore_fashion_jewellery_hub/src/presentation/bloc/product/product_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/user/user_repository.dart';
import '../../domain/use_cases/auth/sign_out_usecase.dart';
import '../../domain/use_cases/auth/verify_number_usecase.dart';
import '../../domain/use_cases/auth/verify_otp_usecase.dart';
import '../../domain/use_cases/user/fetch_user_usecase.dart';
import '../../presentation/bloc/user/user_bloc.dart';
import '../repositories_implementation/user/user_repository_impl.dart';

final GetIt sl = GetIt.instance;

bool initialized = false;

Future<void> setup() async {
  final preferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(preferences);

  // userSession
  sl.registerSingleton(UserSession());

  // Firebase
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

  // Repository
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(firestore: sl()),
  );
  sl.registerLazySingleton<AuthenticationRepository>(
    () => AuthenticationRepositoryImplement(),
  );

  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(firestore: sl()),
  );

  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(firestore: sl()),
  );

  // Use Case
  sl.registerLazySingleton<FetchUserUseCase>(() => FetchUserUseCase(sl()));
  sl.registerLazySingleton<VerifyPhoneUseCase>(() => VerifyPhoneUseCase(sl()));
  sl.registerLazySingleton<VerifyOTPUseCase>(() => VerifyOTPUseCase(sl()));
  sl.registerLazySingleton<SignOutUseCase>(() => SignOutUseCase(sl()));
  sl.registerLazySingleton<GetAllCategoriesUseCase>(
    () => GetAllCategoriesUseCase(sl()),
  );
  sl.registerLazySingleton<GetAllProductsUseCase>(
    () => GetAllProductsUseCase(sl()),
  );
  sl.registerLazySingleton<GetCategoryByIdUseCase>(
    () => GetCategoryByIdUseCase(sl()),
  );
  sl.registerLazySingleton<GetProductByIdUseCase>(
    () => GetProductByIdUseCase(sl()),
  );

  sl.registerLazySingleton<GetCarouselImagesUseCase>(
    () => GetCarouselImagesUseCase(),
  );
  sl.registerLazySingleton<FetchUserByPhoneNumberUseCase>(
    () => FetchUserByPhoneNumberUseCase(sl()),
  );
  sl.registerLazySingleton<AddUserUseCase>(() => AddUserUseCase(sl()));

  sl.registerLazySingleton<AddReviewUseCase>(() => AddReviewUseCase(sl()));

  // BLoC
  sl.registerFactory(
    () => UserBloc(fetchUserUseCase: sl(), addUserUseCase: sl()),
  );
  sl.registerFactory(
    () => AuthenticationBloc(
      fetchUserByPhoneNumberUseCase: sl(),
      verifyPhoneUseCase: sl(),
      verifyOTPUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => ProductBloc(
      addReviewUseCase: sl(),
      getCarouselImages: sl(),
      getAllCategories: sl(),
      getCategoryById: sl(),
      getAllProducts: sl(),
      getProductById: sl(),
    ),
  );
  sl.registerFactory(() => CartBloc());

  initialized = true;
}
