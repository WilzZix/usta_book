import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:usta_book/core/localization/i18n/strings.g.dart';
import 'package:usta_book/core/ui_kit/components/button.dart';
import 'package:usta_book/core/ui_kit/components/inputs/inputs.dart';
import 'package:usta_book/core/ui_kit/typography.dart';
import 'package:usta_book/presentation/sign_up/otp/otp_page.dart';

class PhoneRegistrationPage extends StatefulWidget {
  const PhoneRegistrationPage({super.key});

  static const String tag = '/phone-registration-page';

  @override
  State<PhoneRegistrationPage> createState() => _PhoneRegistrationPageState();
}

class _PhoneRegistrationPageState extends State<PhoneRegistrationPage> {
  TextEditingController controller = TextEditingController();

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
            InputField.phone(
              fieldTitle: tr.input_field.phone_field,
              controller: controller,
            ),
            SizedBox(height: 36),
            MainButton.primary(
              title: tr.buttons.send_code_phone_number,
              onTap: () {
                context.pushNamed(OtpPage.tag);
              },
            ),
            Spacer(),
            Text(
              tr.sign_up.user_privacy,
              style: Typographies.regularBody,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: MediaQuery.of(context).viewPadding.bottom + 8),
          ],
        ),
      ),
    );
  }
}
