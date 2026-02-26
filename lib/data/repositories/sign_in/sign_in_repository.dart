import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/repositories/sign_in/i_sign_in.dart';
import '../../sources/firebase/firebase_service.dart';

@Singleton(as: ISignIn)
class SignInRepository extends ISignIn {
  @override
  Future<UserCredential?> signInWithEmailAndPassword({required String email, required String password}) async {
    try {
      final credential = await FirebaseService.auth.signInWithEmailAndPassword(email: email, password: password);
      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
      } else if (e.code == 'wrong-password') {}
    }
    return null;
  }

  @override
  Future<UserCredential?> signUpWithEmailAndPassword({required String email, required String password}) async {
    try {
      final credential = await FirebaseService.auth.createUserWithEmailAndPassword(email: email, password: password);
      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
      } else if (e.code == 'wrong-password') {}
    }
    return null;
  }
}
