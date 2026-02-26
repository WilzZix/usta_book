part of 'sign_up_and_sing_in_bloc.dart';

@immutable
sealed class SignUpAndSingInState {}

final class SignUpInitial extends SignUpAndSingInState {}

///Sing in
class SignedInSuccessState extends SignUpAndSingInState {
  SignedInSuccessState();
}

class SignInLoadingState extends SignUpAndSingInState {}

class SignedInFailureState extends SignUpAndSingInState {
  final String msg;

  SignedInFailureState({required this.msg});
}

///Sing up
class SignedUpSuccessState extends SignUpAndSingInState {
  SignedUpSuccessState();
}

class SignUpLoadingState extends SignUpAndSingInState {}

class SignedUpFailureState extends SignUpAndSingInState {
  final String msg;

  SignedUpFailureState({required this.msg});
}
