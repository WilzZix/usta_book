import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:usta_book/domain/repositories/sign_up/i_sign_up.dart';

@injectable
class SignUpUseCase {
  final ISignUp iSignUp;

  SignUpUseCase({required this.iSignUp});

  Future<UserCredential?> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await iSignUp.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}
