import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:usta_book/core/localization/i18n/strings.g.dart';
import 'package:usta_book/core/ui_kit/components/bottom_sheet.dart';
import 'package:usta_book/core/ui_kit/components/button.dart';
import 'package:usta_book/core/ui_kit/components/inputs/inputs.dart';
import 'package:usta_book/core/ui_kit/typography.dart';

import '../../../bloc/sign_up_and_sing_in/sign_up_and_sing_in_bloc.dart';

class EmailAndPassword extends StatefulWidget {
  const EmailAndPassword({super.key});

  static const String tag = '/email-and-password-page';

  @override
  State<EmailAndPassword> createState() => _EmailAndPasswordState();
}

class _EmailAndPasswordState extends State<EmailAndPassword> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      BlocProvider.of<SignUpAndSingInBloc>(
        context,
      ).add(SignInWithEmailAndPasswordEvent(email: emailController.text, password: passwordController.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).viewPadding.top + 20),
              Text(tr.sign_up.welcome, style: Typographies.boldH1),
              SizedBox(height: 8),
              Text(tr.sign_up.welcome_desc, style: Typographies.regularBody),
              SizedBox(height: 36),
              InputField.email(
                fieldTitle: tr.input_field.email_field,
                controller: emailController,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter an email';
                  // Simple Regex for email validation
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 8),
              InputField.password(
                fieldTitle: tr.input_field.password_field,
                controller: passwordController,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter a password';
                  if (value.length < 6) return 'Password must be at least 6 characters';
                  return null;
                },
              ),
              SizedBox(height: 36),
              BlocListener<SignUpAndSingInBloc, SignUpAndSingInState>(
                child: MainButton.primary(title: tr.buttons.send_code_phone_number, onTap: _submitForm),
                listener: (BuildContext context, SignUpAndSingInState state) {
                  if (state is SignedInFailureState) {
                    if (state.msg.contains('User not found')) {
                      UstaBookBottomSheet.show(
                        context: context,
                        body: Column(
                          children: [
                            Text('Хотите зарегится с этими кредами?', style: Typographies.regularBody2),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                MainButton.secondary(
                                  title: tr.buttons.no,
                                  onTap: () {
                                    context.pop();
                                  },
                                ),
                                MainButton.primary(
                                  title: tr.buttons.kContinue,
                                  onTap: () {
                                    BlocProvider.of<SignUpAndSingInBloc>(context).add(
                                      SignUpWithEmailAndPasswordEvent(
                                        email: emailController.text,
                                        password: passwordController.text,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        header: state.msg,
                      );
                    } else {
                      UstaBookBottomSheet.show(context: context, body: Text(state.msg), header: 'Sign in error');
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
