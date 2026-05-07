import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:usta_book/data/repositories/phone_auth/firebase_phone_auth_repository.dart';
import 'package:usta_book/domain/repositories/phone_auth/i_phone_auth.dart';

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}
class _MockUserCredential extends Mock implements UserCredential {}
class _MockUser extends Mock implements User {}
class _FakePhoneAuthCredential extends Fake implements PhoneAuthCredential {}

void main() {
  late _MockFirebaseAuth auth;
  late FirebasePhoneAuthRepository repo;

  setUpAll(() {
    registerFallbackValue(_FakePhoneAuthCredential());
    registerFallbackValue(Duration.zero);
  });

  setUp(() {
    auth = _MockFirebaseAuth();
    repo = FirebasePhoneAuthRepository(auth);
  });

  group('sendCode', () {
    test('returns PhoneAuthCodeSent when codeSent fires', () async {
      when(
        () => auth.verifyPhoneNumber(
          phoneNumber: any(named: 'phoneNumber'),
          verificationCompleted: any(named: 'verificationCompleted'),
          verificationFailed: any(named: 'verificationFailed'),
          codeSent: any(named: 'codeSent'),
          codeAutoRetrievalTimeout: any(named: 'codeAutoRetrievalTimeout'),
          timeout: any(named: 'timeout'),
          forceResendingToken: any(named: 'forceResendingToken'),
        ),
      ).thenAnswer((invocation) async {
        final codeSent = invocation.namedArguments[#codeSent]
            as void Function(String, int?);
        codeSent('VID-123', 42);
      });

      final result = await repo.sendCode('+998946914977');
      expect(result, isA<PhoneAuthCodeSent>());
      final r = result as PhoneAuthCodeSent;
      expect(r.verificationId, 'VID-123');
      expect(r.forceResendingToken, 42);
    });

    test('returns PhoneAuthSendFailed with invalidPhone on invalid-phone-number',
        () async {
      when(
        () => auth.verifyPhoneNumber(
          phoneNumber: any(named: 'phoneNumber'),
          verificationCompleted: any(named: 'verificationCompleted'),
          verificationFailed: any(named: 'verificationFailed'),
          codeSent: any(named: 'codeSent'),
          codeAutoRetrievalTimeout: any(named: 'codeAutoRetrievalTimeout'),
          timeout: any(named: 'timeout'),
          forceResendingToken: any(named: 'forceResendingToken'),
        ),
      ).thenAnswer((invocation) async {
        final failed = invocation.namedArguments[#verificationFailed]
            as void Function(FirebaseAuthException);
        failed(FirebaseAuthException(code: 'invalid-phone-number'));
      });

      final result = await repo.sendCode('bad');
      expect(result, isA<PhoneAuthSendFailed>());
      expect((result as PhoneAuthSendFailed).error, PhoneAuthError.invalidPhone);
    });

    test('maps too-many-requests to tooManyRequests', () async {
      when(
        () => auth.verifyPhoneNumber(
          phoneNumber: any(named: 'phoneNumber'),
          verificationCompleted: any(named: 'verificationCompleted'),
          verificationFailed: any(named: 'verificationFailed'),
          codeSent: any(named: 'codeSent'),
          codeAutoRetrievalTimeout: any(named: 'codeAutoRetrievalTimeout'),
          timeout: any(named: 'timeout'),
          forceResendingToken: any(named: 'forceResendingToken'),
        ),
      ).thenAnswer((invocation) async {
        final failed = invocation.namedArguments[#verificationFailed]
            as void Function(FirebaseAuthException);
        failed(FirebaseAuthException(code: 'too-many-requests'));
      });

      final result = await repo.sendCode('+998946914977');
      expect((result as PhoneAuthSendFailed).error,
          PhoneAuthError.tooManyRequests);
    });

    test('returns PhoneAuthAutoVerified with uid when verificationCompleted fires',
        () async {
      final cred = _MockUserCredential();
      final user = _MockUser();
      when(() => cred.user).thenReturn(user);
      when(() => user.uid).thenReturn('uid-android-auto');
      when(() => auth.signInWithCredential(any())).thenAnswer((_) async => cred);
      when(
        () => auth.verifyPhoneNumber(
          phoneNumber: any(named: 'phoneNumber'),
          verificationCompleted: any(named: 'verificationCompleted'),
          verificationFailed: any(named: 'verificationFailed'),
          codeSent: any(named: 'codeSent'),
          codeAutoRetrievalTimeout: any(named: 'codeAutoRetrievalTimeout'),
          timeout: any(named: 'timeout'),
          forceResendingToken: any(named: 'forceResendingToken'),
        ),
      ).thenAnswer((invocation) async {
        final completed = invocation.namedArguments[#verificationCompleted]
            as void Function(PhoneAuthCredential);
        completed(_FakePhoneAuthCredential());
      });

      final result = await repo.sendCode('+998946914977');
      expect(result, isA<PhoneAuthAutoVerified>());
      expect((result as PhoneAuthAutoVerified).uid, 'uid-android-auto');
    });
  });

  group('verifyCode', () {
    test('returns uid string on success', () async {
      final cred = _MockUserCredential();
      final user = _MockUser();
      when(() => cred.user).thenReturn(user);
      when(() => user.uid).thenReturn('uid-xyz');
      when(() => auth.signInWithCredential(any()))
          .thenAnswer((_) async => cred);

      final uid = await repo.verifyCode(
        verificationId: 'VID-123',
        smsCode: '123456',
      );
      expect(uid, 'uid-xyz');
    });

    test('throws PhoneAuthException(invalidCode) on invalid-verification-code',
        () async {
      when(() => auth.signInWithCredential(any())).thenThrow(
        FirebaseAuthException(code: 'invalid-verification-code'),
      );

      await expectLater(
        () => repo.verifyCode(verificationId: 'VID', smsCode: '000000'),
        throwsA(
          isA<PhoneAuthException>().having(
            (e) => e.error,
            'error',
            PhoneAuthError.invalidCode,
          ),
        ),
      );
    });

    test('throws PhoneAuthException(codeExpired) on session-expired', () async {
      when(() => auth.signInWithCredential(any())).thenThrow(
        FirebaseAuthException(code: 'session-expired'),
      );

      await expectLater(
        () => repo.verifyCode(verificationId: 'VID', smsCode: '000000'),
        throwsA(
          isA<PhoneAuthException>().having(
            (e) => e.error,
            'error',
            PhoneAuthError.codeExpired,
          ),
        ),
      );
    });
  });
}
