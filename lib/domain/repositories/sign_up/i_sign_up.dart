import 'package:firebase_auth/firebase_auth.dart';

abstract class ISignUp {
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
}
