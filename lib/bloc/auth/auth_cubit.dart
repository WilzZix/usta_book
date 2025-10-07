import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

part 'auth_state.dart';

// Состояния AuthCubit
enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthCubit extends Cubit<AuthStatus> {
  final FirebaseAuth _firebaseAuth;
  late final StreamSubscription<User?> _userSubscription;

  AuthCubit(this._firebaseAuth) : super(AuthStatus.unknown) {
    // Подписываемся на поток изменений состояния Firebase Auth
    _userSubscription = _firebaseAuth.authStateChanges().listen((user) {
      if (user == null) {
        emit(AuthStatus.unauthenticated);
      } else {
        emit(AuthStatus.authenticated);
      }
    });
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
