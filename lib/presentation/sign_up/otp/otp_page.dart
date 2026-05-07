import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:usta_book/bloc/phone_auth/phone_auth_bloc.dart';
import 'package:usta_book/core/localization/i18n/strings.g.dart';
import 'package:usta_book/core/ui_kit/components/button.dart';
import 'package:usta_book/core/ui_kit/components/inputs/otp.dart';
import 'package:usta_book/core/ui_kit/typography.dart';
import 'package:usta_book/domain/repositories/phone_auth/i_phone_auth.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key, required this.phone});
  final String phone;

  static const String tag = '/otp-page';

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  String _code = '';
  int _clearSignal = 0;
  int _resendKey = 0;

  void _confirm() {
    if (_code.length != 6) return;
    context.read<PhoneAuthBloc>().add(PhoneAuthSubmitOtp(_code));
  }

  void _resend() {
    setState(() => _resendKey++);
    context.read<PhoneAuthBloc>().add(const PhoneAuthResend());
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(tr.sign_up.back, style: Typographies.regularBody),
      ),
      body: BlocListener<PhoneAuthBloc, PhoneAuthState>(
        listenWhen: (prev, curr) {
          // Surface verify errors that arrive embedded in CodeSentState.
          if (curr is PhoneAuthCodeSentState && curr.verifyError != null) {
            return prev is! PhoneAuthCodeSentState ||
                prev.verifyError != curr.verifyError;
          }
          return false;
        },
        listener: (context, state) {
          if (state is PhoneAuthCodeSentState && state.verifyError != null) {
            setState(() => _clearSignal++);
            ScaffoldMessenger.of(context)
              ..clearSnackBars()
              ..showSnackBar(
                SnackBar(content: Text(_errorText(tr, state.verifyError!))),
              );
          }
          // PhoneAuthSuccess → AuthCubit handles redirect via authStateChanges.
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 36),
              Text(tr.sign_up.welcome, style: Typographies.boldH1),
              const SizedBox(height: 8),
              Text(
                tr.sign_up.enter_otp_code(phone: widget.phone),
                style: Typographies.regularBody,
              ),
              const SizedBox(height: 36),
              OtpInput(
                clearSignal: _clearSignal,
                onChanged: (v) => setState(() => _code = v),
              ),
              const SizedBox(height: 12),
              OtpTimerWidget(
                key: ValueKey(_resendKey),
                seconds: 60,
                onResend: _resend,
              ),
              const SizedBox(height: 36),
              BlocBuilder<PhoneAuthBloc, PhoneAuthState>(
                builder: (context, state) {
                  final verifying = state is PhoneAuthVerifying;
                  return MainButton.primary(
                    title: tr.buttons.confirm_and_continue,
                    isLoading: verifying,
                    onTap: verifying ? null : _confirm,
                  );
                },
              ),
              const Spacer(),
              Text(
                tr.sign_up.user_privacy,
                style: Typographies.regularBody,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: MediaQuery.of(context).viewPadding.bottom + 8),
            ],
          ),
        ),
      ),
    );
  }

  String _errorText(Translations tr, PhoneAuthError e) {
    switch (e) {
      case PhoneAuthError.invalidCode:
        return tr.sign_up.errors.invalid_code;
      case PhoneAuthError.codeExpired:
        return tr.sign_up.errors.code_expired;
      case PhoneAuthError.networkError:
        return tr.sign_up.errors.network;
      case PhoneAuthError.tooManyRequests:
        return tr.sign_up.errors.too_many_requests;
      case PhoneAuthError.invalidPhone:
      case PhoneAuthError.quotaExceeded:
      case PhoneAuthError.unknown:
        return tr.sign_up.errors.unknown;
    }
  }
}

/// Countdown widget. After expiry, shows a "Resend" tappable.
class OtpTimerWidget extends StatefulWidget {
  final int seconds;
  final VoidCallback onResend;

  const OtpTimerWidget({
    super.key,
    this.seconds = 60,
    required this.onResend,
  });

  @override
  State<OtpTimerWidget> createState() => _OtpTimerWidgetState();
}

class _OtpTimerWidgetState extends State<OtpTimerWidget> {
  late final int _remaining = widget.seconds;
  late final Stream<int> _stream = _countdown(widget.seconds);

  Stream<int> _countdown(int from) async* {
    for (int i = from; i >= 0; i--) {
      yield i;
      if (i > 0) await Future<void>.delayed(const Duration(seconds: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return StreamBuilder<int>(
      stream: _stream,
      initialData: _remaining,
      builder: (context, snap) {
        final r = snap.data ?? 0;
        if (r == 0) {
          return Center(
            child: TextButton(
              onPressed: widget.onResend,
              child: Text(tr.sign_up.resend),
            ),
          );
        }
        final mm = (r ~/ 60).toString().padLeft(2, '0');
        final ss = (r % 60).toString().padLeft(2, '0');
        return Center(
          child: Text(
            tr.sign_up.timer(time: '$mm:$ss'),
            style: Typographies.regularBody2,
          ),
        );
      },
    );
  }
}
