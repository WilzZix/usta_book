import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _firebaseAuth;
  late final StreamSubscription<User?> _userSubscription;

  // Изменяем конструктор
  AuthCubit(this._firebaseAuth) : super(AuthUnknown()) {
    _userSubscription = _firebaseAuth.authStateChanges().listen((user) {
      _handleAuthChange(user);
    });
  }

  void _handleAuthChange(User? user) async {
    if (user == null) {
      emit(const AuthUnauthenticated());
    } else {
      // 1. Пользователь вошел в Firebase. Теперь проверяем, завершен ли профиль.
      final isComplete = await _isProfileComplete(user.uid);

      if (isComplete) {
        // Профиль завершен -> ПОЛНАЯ АВТОРИЗАЦИЯ
        emit(AuthAuthenticated(firebaseUser: user));
      } else {
        // Профиль НЕ завершен -> ОТПРАВЛЯЕМ на шаги регистрации (OTP/ProfileSettings)
        emit(AuthProfileIncomplete(firebaseUser: user));
      }
    }
  }

  Future<bool> _isProfileComplete(String uid) async {
    //TODO check if register is completed
    return true;
  }

  void setProfileComplete() {
    // Мы знаем, что пользователь УЖЕ вошел,
    // и его данные есть в текущем состоянии
    if (state is AuthProfileIncomplete) {
      final user = (state as AuthProfileIncomplete).firebaseUser;
      // Обновляем статус на ПОЛНУЮ АВТОРИЗАЦИЮ
      emit(AuthAuthenticated(firebaseUser: user));
    }
  }

  // Метод для выхода
  Future<void> logOut() async {
    await _firebaseAuth.signOut();
    // Состояние автоматически обновится через _userSubscription
  }

  // Обязательный метод для закрытия потока
  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}
