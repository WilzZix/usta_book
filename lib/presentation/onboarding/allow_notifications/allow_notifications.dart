import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:usta_book/core/localization/i18n/strings.g.dart';
import 'package:usta_book/core/ui_kit/components/app_icons.dart';
import 'package:usta_book/core/ui_kit/components/button.dart';
import 'package:usta_book/core/ui_kit/typography.dart';
import 'package:usta_book/presentation/onboarding/choose_language/components/dash_item.dart';

import '../complete_onboarding/complete_onboarding_page.dart';

class AllowNotifications extends StatefulWidget {
  const AllowNotifications({super.key});

  static final String tag = '/allow-notification';

  @override
  State<AllowNotifications> createState() => _AllowNotificationsState();
}

class _AllowNotificationsState extends State<AllowNotifications> {
  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).viewPadding.top + 20),
            Text(tr.on_boarding.always_be_aware, style: Typographies.boldH1),
            SizedBox(height: 8),
            Text(
              tr.on_boarding.always_be_aware_desc,
              style: Typographies.regularBody,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 36),
            AppIcons.icNotification,
            SizedBox(height: 16),
            Spacer(),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                DashItem(isDone: true),
                SizedBox(width: 8),
                DashItem(isDone: true),
                SizedBox(width: 8),
                DashItem(isDone: false),
              ],
            ),
            SizedBox(height: 32),
            MainButton.primary(
              title: tr.buttons.allow,
              onTap: () {
                context.pushNamed(CompleteOnboardingPage.tag);
              },
            ),
            SizedBox(height: MediaQuery.of(context).viewPadding.bottom + 8),
          ],
        ),
      ),
    );
  }
}
