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

    // --- ОБНОВЛЕННАЯ ЛОГИКА REDIRECT ---
    redirect: (BuildContext context, GoRouterState state) {
      // 1. Читаем текущий статус Auth из BLoC/Cubit
      final authState = context
          .read<AuthCubit>()
          .state; // Получаем объект состояния

      // 2. Определяем статус через проверку типов
      final bool isAuthenticated = authState is AuthAuthenticated;
      final bool isAuthIncomplete = authState is AuthProfileIncomplete;

      final String targetPath = state.matchedLocation;

      // Публичные пути, доступные всем
      final publicPaths = [
        ChooseLanguage.tag,
        EmailAndPassword.tag,
        PhoneRegistrationPage.tag,
        '/${PhoneRegistrationPage.tag.replaceAll('/', '')}/${OtpPage.tag.replaceAll('/', '')}',
        AllowNotifications.tag,
        CompleteOnboardingPage.tag,
      ];

      final bool isPublicPath = publicPaths.any(
        (path) => targetPath.startsWith(path),
      );

      // Пути, необходимые для завершения регистрации
      final bool isRegistrationStep =
          targetPath.startsWith(PhoneRegistrationPage.tag) ||
          targetPath.startsWith(ProfileSettings.tag) ||
          targetPath.startsWith(
            '/${PhoneRegistrationPage.tag.replaceAll('/', '')}/${OtpPage.tag.replaceAll('/', '')}',
          ) ||
          targetPath.startsWith(OtpPage.tag);

      // Вывод для отладки
      if (kDebugMode) {
        print(
          'Redirect: Status=$authState, Target=$targetPath, Auth=$isAuthenticated, Incomplete=$isAuthIncomplete',
        );
      }

      // 1. Состояние неизвестно (ждем загрузки)
      if (authState is AuthUnknown) {
        return targetPath == SplashScreen.tag ? null : SplashScreen.tag;
      }

      // 2. Статус известен. Если мы на Splash, перенаправляем.
      if (targetPath == SplashScreen.tag) {
        if (isAuthenticated) return HomePage.tag;
        if (isAuthIncomplete) return ProfileSettings.tag;
        return ChooseLanguage.tag;
      }

      // 3. ОБРАБОТКА НЕЗАВЕРШЕННОЙ АВТОРИЗАЦИИ (AuthProfileIncomplete)
      if (isAuthIncomplete) {
        if (isRegistrationStep) {
          return null;
        }
        return ProfileSettings.tag;
      }

      // 4. ОБРАБОТКА НЕАВТОРИЗОВАННОГО ПОЛЬЗОВАТЕЛЯ (AuthUnauthenticated)
      if (authState is AuthUnauthenticated) {
        if (!isPublicPath) {
          return ChooseLanguage.tag;
        }
        return null;
      }

      // 5. ОБРАБОТКА ПОЛНОСТЬЮ АВТОРИЗОВАННОГО ПОЛЬЗОВАТЕЛЯ (AuthAuthenticated)
      if (isAuthenticated) {
        if (isPublicPath || isRegistrationStep) {
          return HomePage.tag;
        }
        return null;
      }

      return null;
    },

    // --- МАРШРУТЫ (Routes) ---
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
      // ... (Все остальные маршруты, которые являются 'public' или 'registration steps')
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
      // Убедитесь, что ProfileSettings находится на верхнем уровне, если он нужен для завершения регистрации
      GoRoute(
        path: ProfileSettings.tag,
        name: ProfileSettings.tag,
        builder: (_, __) => ProfileSettings(),
      ),
      // Правильная вложенность для OTP (дочерний маршрут)
      GoRoute(
        path: PhoneRegistrationPage.tag,
        name: PhoneRegistrationPage.tag,
        builder: (_, __) => PhoneRegistrationPage(),
        routes: [
          GoRoute(
            // Путь здесь - это только 'otp-page', так как он вложен в /phone-registration-page
            path: OtpPage.tag.replaceAll('/', ''),
            name: OtpPage.tag,
            builder: (_, __) => OtpPage(),
          ),
        ],
      ),
    ],
  );
}
