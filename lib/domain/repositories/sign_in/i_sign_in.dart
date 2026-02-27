import 'package:firebase_auth/firebase_auth.dart';

abstract class ISignIn {
  Future<UserCredential?> signInWithEmailAndPassword({required String email, required String password});

  Future<UserCredential?> signUpWithEmailAndPassword({required String email, required String password});
}
