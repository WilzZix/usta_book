part of 'phone_auth_bloc.dart';

sealed class PhoneAuthEvent {
  const PhoneAuthEvent();
}

class PhoneAuthSubmitPhone extends PhoneAuthEvent {
  final String phoneE164;
  const PhoneAuthSubmitPhone(this.phoneE164);
}

class PhoneAuthSubmitOtp extends PhoneAuthEvent {
  final String code;
  const PhoneAuthSubmitOtp(this.code);
}

class PhoneAuthResend extends PhoneAuthEvent {
  const PhoneAuthResend();
}
