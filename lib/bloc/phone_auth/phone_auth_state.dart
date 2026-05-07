part of 'phone_auth_bloc.dart';

sealed class PhoneAuthState {
  const PhoneAuthState();
}

class PhoneAuthIdle extends PhoneAuthState {
  const PhoneAuthIdle();
}

class PhoneAuthSendingCode extends PhoneAuthState {
  final String phone;
  const PhoneAuthSendingCode(this.phone);
}

class PhoneAuthCodeSentState extends PhoneAuthState {
  final String verificationId;
  final String phone;
  final int? forceResendingToken;

  /// Set when a verifyCode attempt failed but the user can retype.
  /// `null` means a fresh code was just sent.
  final PhoneAuthError? verifyError;

  const PhoneAuthCodeSentState({
    required this.verificationId,
    required this.phone,
    required this.forceResendingToken,
    this.verifyError,
  });

  PhoneAuthCodeSentState copyWith({PhoneAuthError? verifyError}) {
    return PhoneAuthCodeSentState(
      verificationId: verificationId,
      phone: phone,
      forceResendingToken: forceResendingToken,
      verifyError: verifyError,
    );
  }
}

class PhoneAuthVerifying extends PhoneAuthState {
  const PhoneAuthVerifying();
}

class PhoneAuthSuccess extends PhoneAuthState {
  const PhoneAuthSuccess();
}

class PhoneAuthFailure extends PhoneAuthState {
  final PhoneAuthError error;
  const PhoneAuthFailure(this.error);
}
