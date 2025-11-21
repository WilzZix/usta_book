import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:usta_book/domain/repositories/sign_up/i_sign_up.dart';

import '../../sources/firebase/firebase_service.dart';

@Singleton(as: ISignUp)
class SignUpRepository extends ISignUp {
  @override
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await FirebaseService.auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
      } else if (e.code == 'wrong-password') {}
    }
    return null;
  }
}
