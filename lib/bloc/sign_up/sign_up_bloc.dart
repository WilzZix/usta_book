import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:usta_book/data/sources/local/shared_pref.dart';
import 'package:usta_book/domain/usecases/sign_up_usecase.dart';

part 'sign_up_event.dart';

part 'sign_up_state.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  SignUpBloc(this.signUpUseCase, this.shredPrefService)
    : super(SignUpInitial()) {
    on<SignUpWithEmailAndPasswordEvent>(_signedUpWithEmailAndPassword);
  }

  final SignUpUseCase signUpUseCase;
  final ShredPrefService shredPrefService;

  Future<void> _signedUpWithEmailAndPassword(
    SignUpWithEmailAndPasswordEvent event,
    Emitter<SignUpState> emit,
  ) async {
    try {
      final userCred = await signUpUseCase.signUpWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      shredPrefService.setMasterUID(masterUID: userCred!.user!.uid);
      emit(SignedUpSuccessState());
    } catch (e) {
      emit(SignedUpFailureState(msg: e.toString()));
    }
  }
}
