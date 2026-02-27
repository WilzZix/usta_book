import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
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
      return;
    } else {
      ProfileStatus profileStatus = await _profileStatus(user.uid);

      switch (profileStatus) {
        case ProfileStatus.incomplete:
          emit(AuthProfileIncomplete(firebaseUser: user));
        case ProfileStatus.completed:
          emit(AuthAuthenticated(firebaseUser: user));
        case ProfileStatus.notFound:
          emit(AuthProfileIncomplete(firebaseUser: user));
      }
    }
  }

  Future<ProfileStatus> _profileStatus(String uid) async {
    try {
      MasterProfile? profile = await profileImpl.getMasterProfile(uid);

      // 1. Если документа нет в Firestore — возвращаем notFound
      if (profile == null) {
        return ProfileStatus.notFound;
      }

      // 2. Если документ есть, проверяем, завершен ли профиль
      if (profile.profileCompleted) {
        return ProfileStatus.completed;
      } else {
        return ProfileStatus.incomplete;
      }
    } catch (e) {
      return ProfileStatus.notFound;
    }
  }

  void setProfileComplete() {
    try {
      // Мы знаем, что пользователь УЖЕ вошел,
      // и его данные есть в текущем состоянии
      if (state is AuthProfileIncomplete) {
        final user = (state as AuthProfileIncomplete).firebaseUser;
        // Обновляем статус на ПОЛНУЮ АВТОРИЗАЦИЮ
        emit(AuthAuthenticated(firebaseUser: user));
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // Метод для выхода
  Future<void> logOut() async {
    emit(UserLoggingOutState(AuthStatus.unauthenticated));
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

enum ProfileStatus { incomplete, completed, notFound }
