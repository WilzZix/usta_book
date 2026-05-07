enum PhoneAuthError {
  invalidPhone,
  tooManyRequests,
  quotaExceeded,
  networkError,
  invalidCode,
  codeExpired,
  unknown,
}

sealed class PhoneAuthSendResult {
  const PhoneAuthSendResult();
}

class PhoneAuthCodeSent extends PhoneAuthSendResult {
  final String verificationId;
  final int? forceResendingToken;
  const PhoneAuthCodeSent({
    required this.verificationId,
    this.forceResendingToken,
  });
}

/// Android-only: SMS auto-retrieval signed the user in immediately.
/// The implementation is responsible for completing the FirebaseAuth sign-in
/// before returning this result. [uid] is the resulting user's uid.
class PhoneAuthAutoVerified extends PhoneAuthSendResult {
  final String uid;
  const PhoneAuthAutoVerified({required this.uid});
}

class PhoneAuthSendFailed extends PhoneAuthSendResult {
  final PhoneAuthError error;
  final String? rawCode;
  const PhoneAuthSendFailed({required this.error, this.rawCode});
}

abstract class IPhoneAuth {
  /// Sends an SMS OTP to [phoneE164] (e.g. "+998946914977").
  Future<PhoneAuthSendResult> sendCode(String phoneE164);

  /// Resends OTP using a [forceResendingToken] from a previous [PhoneAuthCodeSent].
  Future<PhoneAuthSendResult> resendCode(
    String phoneE164,
    int forceResendingToken,
  );

  /// Verifies [smsCode] against [verificationId] and signs the user in.
  /// Returns the resulting user's uid on success.
  /// Throws [PhoneAuthException] on failure.
  Future<String> verifyCode({
    required String verificationId,
    required String smsCode,
  });
}

class PhoneAuthException implements Exception {
  final PhoneAuthError error;
  final String? rawCode;
  const PhoneAuthException(this.error, {this.rawCode});

  @override
  String toString() => 'PhoneAuthException($error, raw=$rawCode)';
}
