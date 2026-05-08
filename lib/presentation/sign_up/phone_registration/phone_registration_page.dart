import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:usta_book/bloc/phone_auth/phone_auth_bloc.dart';
import 'package:usta_book/core/localization/i18n/strings.g.dart';
import 'package:usta_book/core/ui_kit/components/button.dart';
import 'package:usta_book/core/ui_kit/components/inputs/inputs.dart';
import 'package:usta_book/core/ui_kit/typography.dart';
import 'package:usta_book/domain/repositories/phone_auth/i_phone_auth.dart';
import 'package:usta_book/presentation/sign_up/otp/otp_page.dart';

class PhoneRegistrationPage extends StatefulWidget {
  const PhoneRegistrationPage({super.key});

  static const String tag = '/phone-registration-page';

  @override
  State<PhoneRegistrationPage> createState() => _PhoneRegistrationPageState();
}

class _PhoneRegistrationPageState extends State<PhoneRegistrationPage> {
  final TextEditingController _controller = TextEditingController();

  String _toE164(String masked) {
    final digits = masked.replaceAll(RegExp(r'[^0-9]'), '');
    return '+998$digits';
  }

  bool _isComplete(String masked) {
    // Mask is "(##) ### ## ##" → 9 digits (after the locked +998 prefix).
    return masked.replaceAll(RegExp(r'[^0-9]'), '').length == 9;
  }

  void _submit() {
    final text = _controller.text;
    if (!_isComplete(text)) return;
    context.read<PhoneAuthBloc>().add(
          PhoneAuthSubmitPhone(_toE164(text)),
        );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return Scaffold(
      body: BlocConsumer<PhoneAuthBloc, PhoneAuthState>(
        listenWhen: (prev, curr) =>
            (curr is PhoneAuthCodeSentState && prev is! PhoneAuthCodeSentState) ||
            curr is PhoneAuthFailure,
        listener: (context, state) {
          if (state is PhoneAuthCodeSentState) {
            context.pushNamed(OtpPage.tag, extra: state.phone);
          } else if (state is PhoneAuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(_errorText(tr, state.error))),
            );
          }
        },
        builder: (context, state) {
          final loading = state is PhoneAuthSendingCode;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).viewPadding.top + 20),
                Text(tr.sign_up.welcome, style: Typographies.boldH1),
                const SizedBox(height: 8),
                Text(tr.sign_up.welcome_desc, style: Typographies.regularBody),
                const SizedBox(height: 36),
                InputField.phone(
                  fieldTitle: tr.input_field.phone_field,
                  controller: _controller,
                ),
                const SizedBox(height: 36),
                MainButton.primary(
                  title: tr.buttons.send_code_phone_number,
                  isLoading: loading,
                  onTap: loading ? null : _submit,
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
          );
        },
      ),
    );
  }

  String _errorText(Translations tr, PhoneAuthError e) {
    switch (e) {
      case PhoneAuthError.invalidPhone:
        return tr.sign_up.errors.invalid_phone;
      case PhoneAuthError.tooManyRequests:
        return tr.sign_up.errors.too_many_requests;
      case PhoneAuthError.networkError:
        return tr.sign_up.errors.network;
      case PhoneAuthError.quotaExceeded:
      case PhoneAuthError.unknown:
      case PhoneAuthError.invalidCode:
      case PhoneAuthError.codeExpired:
        return tr.sign_up.errors.unknown;
    }
  }
}
