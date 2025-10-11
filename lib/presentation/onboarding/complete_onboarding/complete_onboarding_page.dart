import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:usta_book/core/ui_kit/components/app_icons.dart';
import 'package:usta_book/presentation/sign_up/email_and_password/email_and_password.dart';

import '../../../core/localization/i18n/strings.g.dart';
import '../../../core/ui_kit/components/button.dart';
import '../../../core/ui_kit/typography.dart';
import '../choose_language/components/dash_item.dart';

class CompleteOnboardingPage extends StatefulWidget {
  const CompleteOnboardingPage({super.key});

  static final String tag = '/complete-onboarding';

  @override
  State<CompleteOnboardingPage> createState() => _CompleteOnboardingPageState();
}

class _CompleteOnboardingPageState extends State<CompleteOnboardingPage> {
  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).viewPadding.top + 20),
            Text(tr.on_boarding.manage_costumers, style: Typographies.boldH1),
            SizedBox(height: 8),
            Text(
              tr.on_boarding.manage_costumers_desc,
              style: Typographies.regularBody,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 36),
            AppIcons.icCalendar,
            SizedBox(height: 16),
            Spacer(),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                DashItem(isDone: true),
                SizedBox(width: 8),
                DashItem(isDone: true),
                SizedBox(width: 8),
                DashItem(isDone: true),
              ],
            ),
            SizedBox(height: 32),
            MainButton.primary(
              title: tr.buttons.begin,
              onTap: () {
                context.pushNamed(EmailAndPassword.tag);
              },
            ),
            SizedBox(height: MediaQuery.of(context).viewPadding.bottom + 8),
          ],
        ),
      ),
    );
  }
}
