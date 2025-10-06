import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:usta_book/domain/usecases/sign_up_usecase.dart';

part 'sign_up_event.dart';

part 'sign_up_state.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  SignUpBloc(this.signUpUseCase) : super(SignUpInitial()) {
    on<SignUpWithEmailAndPasswordEvent>(_signedUpWithEmailAndPassword);
  }

  final SignUpUseCase signUpUseCase;

  Future<void> _signedUpWithEmailAndPassword(
    SignUpWithEmailAndPasswordEvent event,
    Emitter<SignUpState> emit,
  ) async {
    try {
      await signUpUseCase.signUpWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      emit(SignedUpSuccessState());
    } catch (e) {
      emit(SignedUpFailureState(msg: e.toString()));
    }
  }
}
