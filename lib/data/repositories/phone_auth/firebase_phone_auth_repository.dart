import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:usta_book/domain/repositories/phone_auth/i_phone_auth.dart';

@Singleton(as: IPhoneAuth)
class FirebasePhoneAuthRepository implements IPhoneAuth {
  final FirebaseAuth _auth;
  FirebasePhoneAuthRepository(this._auth);

  @override
  Future<PhoneAuthSendResult> sendCode(String phoneE164) =>
      _send(phoneE164, null);

  @override
  Future<PhoneAuthSendResult> resendCode(
    String phoneE164,
    int forceResendingToken,
  ) =>
      _send(phoneE164, forceResendingToken);

  Future<PhoneAuthSendResult> _send(String phoneE164, int? token) {
    final completer = Completer<PhoneAuthSendResult>();

    _auth.verifyPhoneNumber(
      phoneNumber: phoneE164,
      timeout: const Duration(seconds: 60),
      forceResendingToken: token,
      verificationCompleted: (PhoneAuthCredential credential) async {
        if (completer.isCompleted) return;
        try {
          final cred = await _auth.signInWithCredential(credential);
          if (completer.isCompleted) return;
          final uid = cred.user?.uid;
          if (uid == null) {
            completer.complete(
              const PhoneAuthSendFailed(error: PhoneAuthError.unknown),
            );
          } else {
            completer.complete(PhoneAuthAutoVerified(uid: uid));
          }
        } catch (_) {
          if (completer.isCompleted) return;
          completer.complete(
            const PhoneAuthSendFailed(error: PhoneAuthError.unknown),
          );
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        if (completer.isCompleted) return;
        completer.complete(
          PhoneAuthSendFailed(
            error: _mapSendError(e.code),
            rawCode: e.code,
          ),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        if (completer.isCompleted) return;
        completer.complete(
          PhoneAuthCodeSent(
            verificationId: verificationId,
            forceResendingToken: resendToken,
          ),
        );
      },
      codeAutoRetrievalTimeout: (_) {},
    );

    return completer.future;
  }

  @override
  Future<String> verifyCode({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final result = await _auth.signInWithCredential(credential);
      final uid = result.user?.uid;
      if (uid == null) {
        throw const PhoneAuthException(PhoneAuthError.unknown);
      }
      return uid;
    } on FirebaseAuthException catch (e) {
      throw PhoneAuthException(_mapVerifyError(e.code), rawCode: e.code);
    }
  }

  PhoneAuthError _mapSendError(String code) {
    switch (code) {
      case 'invalid-phone-number':
        return PhoneAuthError.invalidPhone;
      case 'too-many-requests':
        return PhoneAuthError.tooManyRequests;
      case 'quota-exceeded':
        return PhoneAuthError.quotaExceeded;
      case 'network-request-failed':
        return PhoneAuthError.networkError;
      default:
        return PhoneAuthError.unknown;
    }
  }

  PhoneAuthError _mapVerifyError(String code) {
    switch (code) {
      case 'invalid-verification-code':
        return PhoneAuthError.invalidCode;
      case 'session-expired':
        return PhoneAuthError.codeExpired;
      case 'network-request-failed':
        return PhoneAuthError.networkError;
      case 'too-many-requests':
        return PhoneAuthError.tooManyRequests;
      default:
        return PhoneAuthError.unknown;
    }
  }
}
