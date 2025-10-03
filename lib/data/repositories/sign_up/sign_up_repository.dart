import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:usta_book/domain/repositories/sign_up/i_sign_up.dart';

@Singleton(as: ISignUp)
class SignUpRepository extends ISignUp {
  @override
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    late UserCredential credential;
    try {
      credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
    return credential;
  }
}
