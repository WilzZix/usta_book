import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:usta_book/data/sources/local/shared_pref.dart';
import 'package:usta_book/domain/usecases/sign_in_usecase.dart';

part 'sign_up_and_sing_in_event.dart';

part 'sign_up_and_sing_in_state.dart';

class SignUpAndSingInBloc extends Bloc<SignUpAndSingInEvent, SignUpAndSingInState> {
  SignUpAndSingInBloc(this.signInUseCase, this.shredPrefService) : super(SignUpInitial()) {
    on<SignInWithEmailAndPasswordEvent>(_signedInWithEmailAndPassword);
    on<SignUpWithEmailAndPasswordEvent>(_signedUpWithEmailAndPassword);
  }

  final SignInUseCase signInUseCase;
  final ShredPrefService shredPrefService;

  Future<void> _signedInWithEmailAndPassword(
    SignInWithEmailAndPasswordEvent event,
    Emitter<SignUpAndSingInState> emit,
  ) async {
    emit(SignInLoadingState());

    try {
      UserCredential? userCred = await signInUseCase.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      if (userCred?.user != null) {
        await shredPrefService.setMasterUID(masterUID: userCred?.user?.uid ?? '');
        emit(SignedInSuccessState());
      } else {
        emit(SignedInFailureState(msg: 'User not found'));
      }
    } on FirebaseAuthException catch (e) {
      String message = '';

      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email is already registered.';
          break;
        case 'weak-password':
          message = 'The password provided is too weak.';
          break;
        case 'invalid-email':
          message = 'The email address is badly formatted.';
          break;
        case 'network-request-failed':
          message = 'Please check your internet connection.';
          break;
        default:
          message = e.message ?? 'An unknown error occurred.';
      }
      emit(SignedInFailureState(msg: message));
    } catch (e) {
      // Catch generic errors (like SharedPrefs failing)
      emit(SignedInFailureState(msg: 'Something went wrong: ${e.toString()}'));
    }
  }

  Future<void> _signedUpWithEmailAndPassword(
    SignUpWithEmailAndPasswordEvent event,
    Emitter<SignUpAndSingInState> emit,
  ) async {
    emit(SignInLoadingState());

    try {
      UserCredential? userCred = await signInUseCase.signUpWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      if (userCred?.user != null) {
        await shredPrefService.setMasterUID(masterUID: userCred?.user?.uid ?? '');
        emit(SignedUpSuccessState());
      } else {
        emit(SignedUpFailureState(msg: 'User not found'));
      }
    } on FirebaseAuthException catch (e) {
      String message = '';

      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email is already registered.';
          break;
        case 'weak-password':
          message = 'The password provided is too weak.';
          break;
        case 'invalid-email':
          message = 'The email address is badly formatted.';
          break;
        case 'network-request-failed':
          message = 'Please check your internet connection.';
          break;
        default:
          message = e.message ?? 'An unknown error occurred.';
      }
      emit(SignedUpFailureState(msg: message));
    } catch (e) {
      // Catch generic errors (like SharedPrefs failing)
      emit(SignedUpFailureState(msg: 'Something went wrong: ${e.toString()}'));
    }
  }
}
