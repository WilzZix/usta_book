import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:usta_book/data/models/master_profile.dart';

import '../../data/repositories/master_profile/master_profile.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _firebaseAuth;
  late final StreamSubscription<User?> _userSubscription;
  MasterProfileImpl profileImpl = MasterProfileImpl();

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
    try {
      MasterProfile? profile = await profileImpl.getMasterProfile(uid);

      // Если профиль НЕ найден (null), он НЕ завершен.
      if (profile == null) {
        return false;
      }

      // Если профиль найден, возвращаем статус завершенности.
      return profile.profileCompleted;
    } catch (e) {
      // В случае ошибки (например, сбоя сети или проблем с Firestore)
      // Лучше вернуть false или обработать ошибку в зависимости от логики приложения
      return false;
    }
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
    emit(UserLoggingOutState(AuthStatus.authenticated));
    try {
      await _firebaseAuth.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(UserLogoutError(AuthStatus.authenticated));
    }
  }

  // Обязательный метод для закрытия потока
  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}
