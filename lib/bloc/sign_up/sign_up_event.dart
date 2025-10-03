part of 'sign_up_bloc.dart';

@immutable
sealed class SignUpEvent {}

class SignUpWithEmailAndPasswordEvent extends SignUpEvent {
  final String email;
  final String password;

  SignUpWithEmailAndPasswordEvent({
    required this.email,
    required this.password,
  });
}
