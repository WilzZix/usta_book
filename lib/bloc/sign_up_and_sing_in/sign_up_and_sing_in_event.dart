part of 'sign_up_and_sing_in_bloc.dart';

@immutable
sealed class SignUpAndSingInEvent {}

class SignInWithEmailAndPasswordEvent extends SignUpAndSingInEvent {
  final String email;
  final String password;

  SignInWithEmailAndPasswordEvent({required this.email, required this.password});
}

class SignUpWithEmailAndPasswordEvent extends SignUpAndSingInEvent {
  final String email;
  final String password;

  SignUpWithEmailAndPasswordEvent({required this.email, required this.password});
}
