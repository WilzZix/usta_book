import 'package:bloc/bloc.dart';
import 'package:usta_book/data/sources/local/shared_pref.dart';
import 'package:usta_book/domain/repositories/phone_auth/i_phone_auth.dart';

part 'phone_auth_event.dart';
part 'phone_auth_state.dart';

class PhoneAuthBloc extends Bloc<PhoneAuthEvent, PhoneAuthState> {
  final IPhoneAuth _phoneAuth;
  final ShredPrefService _prefs;

  PhoneAuthBloc(this._phoneAuth, this._prefs) : super(const PhoneAuthIdle()) {
    on<PhoneAuthSubmitPhone>(_onSubmitPhone);
    on<PhoneAuthSubmitOtp>(_onSubmitOtp);
    on<PhoneAuthResend>(_onResend);
  }

  Future<void> _onSubmitPhone(
    PhoneAuthSubmitPhone event,
    Emitter<PhoneAuthState> emit,
  ) async {
    emit(PhoneAuthSendingCode(event.phoneE164));
    final result = await _phoneAuth.sendCode(event.phoneE164);
    await _handleSendResult(result, event.phoneE164, emit);
  }

  Future<void> _onResend(
    PhoneAuthResend event,
    Emitter<PhoneAuthState> emit,
  ) async {
    final s = state;
    if (s is! PhoneAuthCodeSentState) return;
    emit(PhoneAuthSendingCode(s.phone));
    final result = s.forceResendingToken != null
        ? await _phoneAuth.resendCode(s.phone, s.forceResendingToken!)
        : await _phoneAuth.sendCode(s.phone);
    await _handleSendResult(result, s.phone, emit);
  }

  Future<void> _handleSendResult(
    PhoneAuthSendResult result,
    String phone,
    Emitter<PhoneAuthState> emit,
  ) async {
    switch (result) {
      case PhoneAuthCodeSent(:final verificationId, :final forceResendingToken):
        emit(PhoneAuthCodeSentState(
          verificationId: verificationId,
          phone: phone,
          forceResendingToken: forceResendingToken,
        ));
      case PhoneAuthAutoVerified(:final uid):
        await _prefs.setMasterUID(masterUID: uid);
        emit(const PhoneAuthSuccess());
      case PhoneAuthSendFailed(:final error):
        emit(PhoneAuthFailure(error));
    }
  }

  Future<void> _onSubmitOtp(
    PhoneAuthSubmitOtp event,
    Emitter<PhoneAuthState> emit,
  ) async {
    final s = state;
    if (s is! PhoneAuthCodeSentState) return;
    emit(const PhoneAuthVerifying());
    try {
      final uid = await _phoneAuth.verifyCode(
        verificationId: s.verificationId,
        smsCode: event.code,
      );
      await _prefs.setMasterUID(masterUID: uid);
      emit(const PhoneAuthSuccess());
    } on PhoneAuthException catch (e) {
      emit(s.copyWith(verifyError: e.error));
    }
  }
}
