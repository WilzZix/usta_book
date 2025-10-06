import 'package:firebase_auth/firebase_auth.dart';

abstract class ISignUp {
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
}
