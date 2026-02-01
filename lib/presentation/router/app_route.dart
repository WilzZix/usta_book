import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:usta_book/bloc/auth/auth_cubit.dart';
import 'package:usta_book/data/models/client_model.dart';
import 'package:usta_book/presentation/add_new_record/add_new_record_page.dart';
import 'package:usta_book/presentation/clients/clients_list_page.dart';
import 'package:usta_book/presentation/home/home_page.dart';
import 'package:usta_book/presentation/onboarding/choose_language/choose_language.dart';
import 'package:usta_book/presentation/sign_up/email_and_password/email_and_password.dart';
import 'package:usta_book/presentation/sign_up/otp/otp_page.dart';
import 'package:usta_book/presentation/sign_up/phone_registration/phone_registration_page.dart';
import 'package:usta_book/presentation/sign_up/profile_settings/profile_settings.dart';

import '../bottom_nav_bar/bottom_nav_bar.dart';
import '../clients/add_new_appointment_page.dart';
import '../onboarding/allow_notifications/allow_notifications.dart';
import '../onboarding/complete_onboarding/complete_onboarding_page.dart';
import '../splash/splash_page.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRoute {
  static GoRouter router(AuthCubit authCubit) {
    return GoRouter(
      initialLocation: SplashScreen.tag,
      debugLogDiagnostics: kDebugMode,
      overridePlatformDefaultLocation: true,
      refreshListenable: GoRouterRefreshStream(authCubit.stream),
      redirect: (BuildContext context, GoRouterState state) {
        final authState = authCubit.state;
        final String targetPath = state.matchedLocation;

        if (kDebugMode) {
          print('Redirect Logic: Current State: $authState, Path: $targetPath');
        }

        // 1. Loading
        if (authState is AuthUnknown) {
          return targetPath == SplashScreen.tag ? null : SplashScreen.tag;
        }

        // 2. Guest / Logout State
        if (authState is AuthUnauthenticated) {
          final publicPaths = [
            ChooseLanguage.tag,
            EmailAndPassword.tag,
            PhoneRegistrationPage.tag,
            AllowNotifications.tag,
            CompleteOnboardingPage.tag,
            // Handle the nested OTP path explicitly
            '/${PhoneRegistrationPage.tag.replaceAll('/', '')}/${OtpPage.tag.replaceAll('/', '')}',
          ];

          // Use full equality for the primary check to avoid "starts with" confusion
          final bool isOnPublicPage = publicPaths.contains(targetPath) ||
              targetPath.contains(OtpPage.tag.replaceAll('/', ''));

          if (!isOnPublicPage) {
            return ChooseLanguage.tag; // This forces navigation on logout
          }
          return null;
        }

        // 3. Profile Incomplete
        if (authState is AuthProfileIncomplete) {
          // If not on profile settings or registration pages, force to profile settings
          final bool isRegistrationStep = targetPath.startsWith(PhoneRegistrationPage.tag) ||
              targetPath.startsWith(ProfileSettings.tag) ||
              targetPath.contains(OtpPage.tag.replaceAll('/', ''));

          if (!isRegistrationStep) {
            return ProfileSettings.tag;
          }
          return null;
        }

        // 4. Authenticated
        if (authState is AuthAuthenticated) {
          // If user is logged in but hits a login/splash page, send them home
          final authPages = [ChooseLanguage.tag, EmailAndPassword.tag, SplashScreen.tag];
          if (authPages.contains(targetPath)) {
            return MainHomeScreen.tag;
          }
          return null;
        }

        return null;
      },

      routes: [
        GoRoute(path: ClientsListPage.tag, name: ClientsListPage.tag, builder: (_, __) => ClientsListPage()),
        GoRoute(
          path: AddNewAppointmentPage.tag,
          name: AddNewAppointmentPage.tag,
          builder: (_, state) => AddNewAppointmentPage(record: state.extra as ClientModel),
        ),
        GoRoute(path: MainHomeScreen.tag, name: MainHomeScreen.tag, builder: (_, __) => MainHomeScreen()),
        GoRoute(path: AddNewRecordPage.tag, name: AddNewRecordPage.tag, builder: (_, __) => AddNewRecordPage()),
        GoRoute(path: HomePage.tag, name: HomePage.tag, builder: (_, __) => HomePage()),
        GoRoute(path: SplashScreen.tag, name: SplashScreen.tag, builder: (_, __) => const SplashScreen()),
        // ... (Все остальные маршруты, которые являются 'public' или 'registration steps')
        GoRoute(path: ChooseLanguage.tag, name: ChooseLanguage.tag, builder: (_, __) => ChooseLanguage()),
        GoRoute(path: AllowNotifications.tag, name: AllowNotifications.tag, builder: (_, __) => AllowNotifications()),
        GoRoute(
          path: CompleteOnboardingPage.tag,
          name: CompleteOnboardingPage.tag,
          builder: (_, __) => CompleteOnboardingPage(),
        ),
        GoRoute(path: EmailAndPassword.tag, name: EmailAndPassword.tag, builder: (_, __) => EmailAndPassword()),
        // Убедитесь, что ProfileSettings находится на верхнем уровне, если он нужен для завершения регистрации
        GoRoute(path: ProfileSettings.tag, name: ProfileSettings.tag, builder: (_, __) => ProfileSettings()),
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
}
