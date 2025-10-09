import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:usta_book/bloc/auth/auth_cubit.dart';
import 'package:usta_book/presentation/home/home_page.dart';
import 'package:usta_book/presentation/onboarding/choose_language/choose_language.dart';
import 'package:usta_book/presentation/sign_up/email_and_password/email_and_password.dart';
import 'package:usta_book/presentation/sign_up/otp/otp_page.dart';
import 'package:usta_book/presentation/sign_up/phone_registration/phone_registration_page.dart';
import 'package:usta_book/presentation/sign_up/profile_settings/profile_settings.dart';

import '../onboarding/allow_notifications/allow_notifications.dart';
import '../onboarding/complete_onboarding/complete_onboarding_page.dart';
import '../splash/splash_page.dart';

class AppRoute {
  static final router = GoRouter(
    initialLocation: SplashScreen.tag,
    debugLogDiagnostics: kDebugMode,
    overridePlatformDefaultLocation: true,
    redirect: (BuildContext context, GoRouterState state) {
      // 1. Читаем текущий статус Auth из BLoC/Cubit
      final authStatus = context.read<AuthCubit>().state;

      final bool isAuthenticated = authStatus == AuthStatus.authenticated;
      final String targetPath =
          state.matchedLocation; // Используем matchedLocation для точного пути

      // Пути, не требующие авторизации (онбординг, регистрация, вход)
      final bool isPublicPath =
          targetPath.startsWith(ChooseLanguage.tag) ||
          targetPath.startsWith(PhoneRegistrationPage.tag) ||
          targetPath.startsWith(EmailAndPassword.tag);

      // Вывод для отладки
      if (kDebugMode) {
        print(
          'Redirect: Status=$authStatus, Target=$targetPath, Auth=$isAuthenticated',
        );
      }

      // 1. Состояние неизвестно (ждем загрузки)
      if (authStatus == AuthStatus.unknown) {
        return targetPath == SplashScreen.tag ? null : SplashScreen.tag;
      }
      // 2. Статус известен. Если мы на Splash, перенаправляем.
      if (targetPath == SplashScreen.tag) {
        return isAuthenticated ? HomePage.tag : ChooseLanguage.tag;
      }

      if (!isAuthenticated) {
        // Если пытается попасть на защищенный путь, перенаправляем на Вход/Регистрацию
        if (!isPublicPath) {
          return ChooseLanguage.tag; // Начинаем с онбординга/выбора языка
        }
        return null; // Остаемся на публичном пути
      }
      // 3. Если пользователь ЗАЛОГИНЕН (Авторизован)
      else {
        // Если пытается попасть на публичный путь (Вход, Регистрация, Онбординг)
        if (isPublicPath) {
          return HomePage.tag; // Перенаправляем на Главный экран (Расписание)
        }
        return null; // Остаемся на защищенном пути
      }
    },
    routes: [
      GoRoute(
        path: HomePage.tag,
        name: HomePage.tag,
        builder: (_, __) => HomePage(),
      ),
      GoRoute(
        path: SplashScreen.tag,
        name: SplashScreen.tag,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: ChooseLanguage.tag,
        name: ChooseLanguage.tag,
        builder: (_, __) => ChooseLanguage(),
      ),
      GoRoute(
        path: AllowNotifications.tag,
        name: AllowNotifications.tag,
        builder: (_, __) => AllowNotifications(),
      ),
      GoRoute(
        path: CompleteOnboardingPage.tag,
        name: CompleteOnboardingPage.tag,
        builder: (_, __) => CompleteOnboardingPage(),
      ),
      GoRoute(
        path: EmailAndPassword.tag,
        name: EmailAndPassword.tag,
        builder: (_, __) => EmailAndPassword(),
      ),
      GoRoute(
        path: PhoneRegistrationPage.tag,
        name: PhoneRegistrationPage.tag,
        builder: (_, __) => PhoneRegistrationPage(),
        routes: [
          GoRoute(
            path: OtpPage.tag,
            name: OtpPage.tag,
            builder: (_, __) => OtpPage(),
          ),
          GoRoute(
            path: ProfileSettings.tag,
            name: ProfileSettings.tag,
            builder: (_, __) => ProfileSettings(),
          ),
        ],
      ),
    ],
  );
}
