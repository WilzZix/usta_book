import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:usta_book/core/di/di.dart';
import 'package:usta_book/core/di/inject.dart';

import 'bloc/sign_up/sign_up_bloc.dart';
import 'core/localization/i18n/strings.g.dart';
import 'core/ui_kit/colors.dart';
import 'firebase_options.dart';
import 'presentation/router/app_route.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initDi();
  runApp(TranslationProvider(child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignUpBloc(inject()),
      child: MaterialApp.router(
        theme: ThemeData(
          scaffoldBackgroundColor: LightAppColors.body,
          appBarTheme: AppBarTheme(color: LightAppColors.body),
          inputDecorationTheme: InputDecorationTheme(
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: LightAppColors.primary),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: StateColor.error),
              borderRadius: BorderRadius.circular(8),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: LightAppColors.border),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: LightAppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: LightAppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: StateColor.error),
            ),
          ),
        ),
        routerDelegate: AppRoute.router.routerDelegate,
        routeInformationParser: AppRoute.router.routeInformationParser,
        routeInformationProvider: AppRoute.router.routeInformationProvider,
        locale: TranslationProvider.of(context).flutterLocale,
        supportedLocales: AppLocaleUtils.supportedLocales,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
      ),
    );
  }
}
