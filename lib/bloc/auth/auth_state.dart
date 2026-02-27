part of 'auth_cubit.dart';

// Состояния AuthCubit
enum AuthStatus { unknown, authenticated, unauthenticated, authIncomplete, masterProfileNotFound }

@immutable
abstract class AuthState {
  // Флаг для удобства доступа
  final AuthStatus status;

  const AuthState(this.status);
}

// 1. Неизвестное/Загрузка
class AuthUnknown extends AuthState {
  const AuthUnknown() : super(AuthStatus.unknown);
}

// 2. Пользователь не вошел
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated() : super(AuthStatus.unauthenticated);
}

// 3. Пользователь вошел в Firebase, но его профиль в приложении не завершен (должен пройти OTP/ProfileSettings)
class AuthProfileIncomplete extends AuthState {
  final User firebaseUser;

  const AuthProfileIncomplete({required this.firebaseUser}) : super(AuthStatus.authIncomplete);
}

// 4. Пользователь полностью авторизован и профиль завершен (может пользоваться приложением)
class AuthAuthenticated extends AuthState {
  final User firebaseUser;

  const AuthAuthenticated({required this.firebaseUser}) : super(AuthStatus.authenticated);
}

class UserLoggingOutState extends AuthState {
  const UserLoggingOutState(super.status);
}

class UserLogoutError extends AuthState {
  const UserLogoutError(super.status);
}
