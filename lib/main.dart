import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/localization/i18n/strings.g.dart';
import 'core/ui_kit/colors.dart';
import 'presentation/router/app_route.dart';

void main() {
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
    return MaterialApp.router(
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
    );
  }
}
