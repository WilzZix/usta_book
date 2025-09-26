import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:usta_book/presentation/onboarding/choose_language/choose_language.dart';

import '../onboarding/allow_notifications/allow_notifications.dart';
import '../onboarding/complete_onboarding/complete_onboarding_page.dart';

class AppRoute {
  static final router = GoRouter(
    initialLocation: ChooseLanguage.tag,
    debugLogDiagnostics: kDebugMode,
    overridePlatformDefaultLocation: true,
    routes: [
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
    ],
  );
}
