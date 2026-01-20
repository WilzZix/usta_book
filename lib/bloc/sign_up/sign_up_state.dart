part of 'sign_up_bloc.dart';

@immutable
sealed class SignUpState {}

final class SignUpInitial extends SignUpState {}

class SignedUpSuccessState extends SignUpState {
  SignedUpSuccessState();
}

class SignUpLoadingState extends SignUpState {}

class SignedUpFailureState extends SignUpState {
  final String msg;

  SignedUpFailureState({required this.msg});
}
