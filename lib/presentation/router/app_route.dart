import 'package:go_router/go_router.dart';
import 'package:usta_book/presentation/onboarding/choose_language.dart';

class AppRoute {
  static final router = GoRouter(
    initialLocation: SelectLanguage.tag,
    routes: [
      GoRoute(
        path: SelectLanguage.tag,
        name: SelectLanguage.tag,
        builder: (_, __) => SelectLanguage(),
      ),
    ],
  );
}
