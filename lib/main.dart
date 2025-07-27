import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mysore_fashion_jewellery_hub/src/presentation/bloc/auth/auth_bloc.dart';
import 'package:mysore_fashion_jewellery_hub/src/presentation/bloc/product/product_bloc.dart';
import 'package:mysore_fashion_jewellery_hub/src/presentation/bloc/user/user_bloc.dart';
import 'package:mysore_fashion_jewellery_hub/src/data/dependencyInjector/dependency_injector.dart';
import 'package:mysore_fashion_jewellery_hub/src/core/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAppCheck.instance.activate(
    androidProvider:
        kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
    appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.appAttest,
    webProvider: ReCaptchaV3Provider(
      '6Lcq9igrAAAAABIRJoGZ51vRv4PDX17Ce1noRJJE',
    ),
  );


  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await setup();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<AuthenticationBloc>()),
        BlocProvider(create: (context) => sl<UserBloc>()),
        BlocProvider(create: (context) => sl<ProductBloc>()),
      ],
      child: ScreenUtilInit(
        designSize: Size(430, 932),
        child: MaterialApp.router(
          title: 'Mysore Fashion Jewellery Hub',
          routerConfig: router,
        ),
      ),
    );
  }
}
