import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:usta_book/bloc/auth/auth_cubit.dart';
import 'package:usta_book/core/di/di.dart';
import 'package:usta_book/core/di/inject.dart';

import 'bloc/master/master_bloc.dart';
import 'bloc/sign_up/sign_up_bloc.dart';
import 'core/localization/i18n/strings.g.dart';
import 'core/ui_kit/colors.dart';
import 'data/sources/firebase/firebase_service.dart';
import 'data/sources/local/shared_pref.dart';
import 'firebase_options.dart';
import 'presentation/router/app_route.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initDi();
  await ShredPrefService().init();
  runApp(
    BlocProvider<AuthCubit>(
      create: (context) => AuthCubit(FirebaseService.auth),
      child: TranslationProvider(child: const MyApp()),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // Инициализируем роутер
    _router = AppRoute.router;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthStatus>(
      listener: (context, state) {
        // Вызываем обновление роутера при каждом изменении AuthStatus
        _router.refresh();
      },
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => SignUpBloc(inject(), inject())),
          BlocProvider(create: (context) => MasterBloc(inject(), inject())),
        ],
        child: MaterialApp.router(
          theme: ThemeData(
            scaffoldBackgroundColor: LightAppColors.body,
            appBarTheme: AppBarTheme(color: LightAppColors.body),
            inputDecorationTheme: InputDecorationTheme(
              errorStyle: TextStyle(color: StateColor.error),
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
          routerDelegate: _router.routerDelegate,
          routeInformationParser: _router.routeInformationParser,
          routeInformationProvider: _router.routeInformationProvider,
          locale: TranslationProvider.of(context).flutterLocale,
          supportedLocales: AppLocaleUtils.supportedLocales,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
        ),
      ),
    );
  }
}
