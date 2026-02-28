import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:usta_book/core/ui_kit/components/app_icons.dart';
import 'package:usta_book/core/ui_kit/components/button.dart';
import 'package:usta_book/core/ui_kit/typography.dart';

import '../../../bloc/profile/profile_cubit.dart';
import '../../../core/localization/i18n/strings.g.dart';
import '../allow_notifications/allow_notifications.dart';
import 'components/dash_item.dart';
import 'components/language_item.dart';

class ChooseLanguage extends StatefulWidget {
  const ChooseLanguage({super.key});

  static final String tag = '/';

  @override
  State<ChooseLanguage> createState() => _ChooseLanguageState();
}

class _ChooseLanguageState extends State<ChooseLanguage> {
  int selectedItem = 1;
  TextEditingController phoneController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).viewPadding.top + 20),
            Text(tr.on_boarding.choose_language, style: Typographies.boldH1),
            SizedBox(height: 8),
            Text(tr.on_boarding.choose_lang_desc, style: Typographies.regularBody),
            SizedBox(height: 36),
            LanguageItem(
              title: "Русский",
              selected: selectedItem == 1,
              onTap: () {
                selectedItem = 1;
                setState(() {});
                context.read<ProfileCubit>().changeLocal(AppLocale.ru);
              },
              icon: AppIcons.icRus,
            ),
            SizedBox(height: 16),
            LanguageItem(
              title: "O'zbekcha",
              selected: selectedItem == 0,
              onTap: () {
                selectedItem = 0;
                setState(() {});
                context.read<ProfileCubit>().changeLocal(AppLocale.uz);
              },
              icon: AppIcons.icUzb,
            ),

            SizedBox(height: 32),
            Spacer(),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                DashItem(isDone: true),
                SizedBox(width: 8),
                DashItem(isDone: false),
                SizedBox(width: 8),
                DashItem(isDone: false),
              ],
            ),
            SizedBox(height: 32),
            MainButton.primary(
              title: tr.buttons.kContinue,
              onTap: () {
                context.pushNamed(AllowNotifications.tag);
              },
            ),
            SizedBox(height: MediaQuery.of(context).viewPadding.bottom + 8),
          ],
        ),
      ),
    );
  }
}
