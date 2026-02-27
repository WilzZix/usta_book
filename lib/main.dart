import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:usta_book/bloc/auth/auth_cubit.dart';
import 'package:usta_book/bloc/profile/profile_cubit.dart';
import 'package:usta_book/core/di/di.dart';
import 'package:usta_book/core/di/inject.dart';

import 'bloc/clients/clients_bloc.dart';
import 'bloc/master/master_bloc.dart';
import 'bloc/schedule/schedule_cubit.dart';

import 'bloc/sign_up_and_sing_in/sign_up_and_sing_in_bloc.dart';
import 'bloc/theme/theme_cubit.dart';
import 'core/localization/i18n/strings.g.dart';
import 'core/ui_kit/app_themes.dart';
import 'data/sources/firebase/firebase_service.dart';
import 'data/sources/local/shared_pref.dart';
import 'firebase_options.dart';
import 'presentation/router/app_route.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initDi();
  final prefService = ShredPrefService();
  await prefService.init();

  final savedLanguage = prefService.getLanguage();
  if (savedLanguage != null) {
    LocaleSettings.setLocaleRaw(savedLanguage);
  } else {
    LocaleSettings.useDeviceLocale();
  }
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
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

    _router = AppRoute.router(context.read<AuthCubit>());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        _router.refresh();
      },
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => SignUpAndSingInBloc(inject(), inject())),
          BlocProvider(create: (context) => MasterBloc(inject(), inject())),
          BlocProvider(create: (context) => ScheduleCubit(inject(), inject())),
          BlocProvider(create: (context) => ClientsBloc(inject(), inject())..add(GetClientsEvent())),
          BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()),
          BlocProvider<ProfileCubit>(create: (context) => ProfileCubit()),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp.router(
              themeMode: themeMode,
              theme: AppThemes.createTheme(Brightness.light),
              darkTheme: AppThemes.createTheme(Brightness.dark),
              routerDelegate: _router.routerDelegate,
              routeInformationParser: _router.routeInformationParser,
              routeInformationProvider: _router.routeInformationProvider,
              locale: TranslationProvider.of(context).flutterLocale,
              supportedLocales: AppLocaleUtils.supportedLocales,
              localizationsDelegates: GlobalMaterialLocalizations.delegates,
            );
          },
        ),
      ),
    );
  }
}
