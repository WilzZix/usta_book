import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:usta_book/core/localization/i18n/strings.g.dart';
import 'package:usta_book/core/ui_kit/components/button.dart';
import 'package:usta_book/core/ui_kit/components/inputs/inputs.dart';
import 'package:usta_book/core/ui_kit/typography.dart';
import 'package:usta_book/presentation/sign_up/otp/otp_page.dart';

class EmailAndPassword extends StatefulWidget {
  const EmailAndPassword({super.key});

  static const String tag = '/email-and-password-page';

  @override
  State<EmailAndPassword> createState() => _EmailAndPasswordState();
}

class _EmailAndPasswordState extends State<EmailAndPassword> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
            ),
            SizedBox(height: 8),
            InputField.password(
              fieldTitle: tr.input_field.password_field,
              controller: passwordController,
            ),
            SizedBox(height: 36),
            MainButton.primary(
              title: tr.buttons.send_code_phone_number,
              onTap: () {
                context.pushNamed(OtpPage.tag);
              },
            ),
          ],
        ),
      ),
    );
  }
}
