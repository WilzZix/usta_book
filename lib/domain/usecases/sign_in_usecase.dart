import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

import '../repositories/sign_in/i_sign_in.dart';

@injectable
class SignInUseCase {
  final ISignIn iSignIn;

  SignInUseCase({required this.iSignIn});

  Future<UserCredential?> signInWithEmailAndPassword({required String email, required String password}) async {
    return await iSignIn.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential?> signUpWithEmailAndPassword({required String email, required String password}) async {
    return await iSignIn.signUpWithEmailAndPassword(email: email, password: password);
  }
}
