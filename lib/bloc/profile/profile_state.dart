part of 'profile_cubit.dart';

@immutable
sealed class ProfileState {}

final class ProfileInitial extends ProfileState {}

class ProfileLanguageChanged extends ProfileState {
  final AppLocale local;

  ProfileLanguageChanged(this.local);
}

class ProfileError extends ProfileState {
  final String msg;

  ProfileError(this.msg);
}
