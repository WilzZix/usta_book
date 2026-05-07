import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:usta_book/bloc/phone_auth/phone_auth_bloc.dart';
import 'package:usta_book/data/sources/local/shared_pref.dart';
import 'package:usta_book/domain/repositories/phone_auth/i_phone_auth.dart';

class _MockPhoneAuth extends Mock implements IPhoneAuth {}
class _MockSharedPref extends Mock implements ShredPrefService {}


void main() {
  late _MockPhoneAuth phoneAuth;
  late _MockSharedPref prefs;

  setUp(() {
    phoneAuth = _MockPhoneAuth();
    prefs = _MockSharedPref();
    when(() => prefs.setMasterUID(masterUID: any(named: 'masterUID')))
        .thenAnswer((_) async {});
  });

  PhoneAuthBloc build() => PhoneAuthBloc(phoneAuth, prefs);

  group('SubmitPhone', () {
    test('emits SendingCode then CodeSent on success', () async {
      when(() => phoneAuth.sendCode('+998946914977')).thenAnswer(
        (_) async => const PhoneAuthCodeSent(
          verificationId: 'VID-1',
          forceResendingToken: 7,
        ),
      );
      final bloc = build();
      final states = <PhoneAuthState>[];
      bloc.stream.listen(states.add);

      bloc.add(const PhoneAuthSubmitPhone('+998946914977'));
      await pumpEventQueue();

      expect(states.first, isA<PhoneAuthSendingCode>());
      expect(states.last, isA<PhoneAuthCodeSentState>());
      final sent = states.last as PhoneAuthCodeSentState;
      expect(sent.verificationId, 'VID-1');
      expect(sent.phone, '+998946914977');
      expect(sent.forceResendingToken, 7);
    });

    test('emits SendingCode then Failure on send failure', () async {
      when(() => phoneAuth.sendCode('+998946914977')).thenAnswer(
        (_) async => const PhoneAuthSendFailed(
          error: PhoneAuthError.networkError,
        ),
      );
      final bloc = build();
      final states = <PhoneAuthState>[];
      bloc.stream.listen(states.add);

      bloc.add(const PhoneAuthSubmitPhone('+998946914977'));
      await pumpEventQueue();

      expect(states.first, isA<PhoneAuthSendingCode>());
      expect(states.last, isA<PhoneAuthFailure>());
      expect(
        (states.last as PhoneAuthFailure).error,
        PhoneAuthError.networkError,
      );
    });

    test('AutoVerified writes uid to prefs and emits Success', () async {
      when(() => phoneAuth.sendCode('+998946914977')).thenAnswer(
        (_) async => const PhoneAuthAutoVerified(uid: 'uid-auto'),
      );
      final bloc = build();
      final states = <PhoneAuthState>[];
      bloc.stream.listen(states.add);

      bloc.add(const PhoneAuthSubmitPhone('+998946914977'));
      await pumpEventQueue();

      expect(states.last, isA<PhoneAuthSuccess>());
      verify(() => prefs.setMasterUID(masterUID: 'uid-auto')).called(1);
    });
  });

  group('SubmitOtp', () {
    /// Drives the bloc to PhoneAuthCodeSentState by submitting a phone first.
    Future<PhoneAuthBloc> reachCodeSent(int? token) async {
      when(() => phoneAuth.sendCode('+998946914977')).thenAnswer(
        (_) async => PhoneAuthCodeSent(
          verificationId: 'VID-1',
          forceResendingToken: token,
        ),
      );
      final bloc = build();
      bloc.add(const PhoneAuthSubmitPhone('+998946914977'));
      await pumpEventQueue();
      return bloc;
    }

    test('emits Verifying then Success and writes uid to prefs', () async {
      when(() => phoneAuth.verifyCode(
            verificationId: 'VID-1',
            smsCode: '123456',
          )).thenAnswer((_) async => 'uid-xyz');

      final bloc = await reachCodeSent(7);
      final states = <PhoneAuthState>[];
      bloc.stream.listen(states.add);

      bloc.add(const PhoneAuthSubmitOtp('123456'));
      await pumpEventQueue();

      expect(states.first, isA<PhoneAuthVerifying>());
      expect(states.last, isA<PhoneAuthSuccess>());
      verify(() => prefs.setMasterUID(masterUID: 'uid-xyz')).called(1);
    });

    test('on verifyCode failure: emits CodeSentState with verifyError set',
        () async {
      when(() => phoneAuth.verifyCode(
            verificationId: 'VID-1',
            smsCode: '000000',
          )).thenThrow(const PhoneAuthException(PhoneAuthError.invalidCode));

      final bloc = await reachCodeSent(null);
      final states = <PhoneAuthState>[];
      bloc.stream.listen(states.add);

      bloc.add(const PhoneAuthSubmitOtp('000000'));
      await pumpEventQueue();

      // Expected sequence: Verifying → CodeSentState(with verifyError set)
      expect(states.first, isA<PhoneAuthVerifying>());
      expect(states.last, isA<PhoneAuthCodeSentState>());
      final last = states.last as PhoneAuthCodeSentState;
      expect(last.verifyError, PhoneAuthError.invalidCode);
      expect(last.verificationId, 'VID-1');
    });
  });

  group('Resend', () {
    test('uses resendCode with token from current state', () async {
      // Drive to CodeSentState with token=7
      when(() => phoneAuth.sendCode('+998946914977')).thenAnswer(
        (_) async => const PhoneAuthCodeSent(
          verificationId: 'VID-1',
          forceResendingToken: 7,
        ),
      );
      when(() => phoneAuth.resendCode('+998946914977', 7)).thenAnswer(
        (_) async => const PhoneAuthCodeSent(
          verificationId: 'VID-2',
          forceResendingToken: 8,
        ),
      );
      final bloc = build();
      bloc.add(const PhoneAuthSubmitPhone('+998946914977'));
      await pumpEventQueue();

      final states = <PhoneAuthState>[];
      bloc.stream.listen(states.add);

      bloc.add(const PhoneAuthResend());
      await pumpEventQueue();

      expect(states.last, isA<PhoneAuthCodeSentState>());
      final sent = states.last as PhoneAuthCodeSentState;
      expect(sent.verificationId, 'VID-2');
      expect(sent.forceResendingToken, 8);
      verify(() => phoneAuth.resendCode('+998946914977', 7)).called(1);
    });

    test('falls back to sendCode when no resending token is available',
        () async {
      // Drive to CodeSentState with token=null
      when(() => phoneAuth.sendCode('+998946914977')).thenAnswer(
        (_) async => const PhoneAuthCodeSent(
          verificationId: 'VID-1',
          forceResendingToken: null,
        ),
      );
      final bloc = build();
      bloc.add(const PhoneAuthSubmitPhone('+998946914977'));
      await pumpEventQueue();

      bloc.add(const PhoneAuthResend());
      await pumpEventQueue();

      // sendCode is invoked twice (once for initial, once for resend)
      verify(() => phoneAuth.sendCode('+998946914977')).called(2);
      verifyNever(() => phoneAuth.resendCode(any(), any()));
    });
  });
}
