import 'package:flutter/material.dart';
import 'package:usta_book/core/ui_kit/colors.dart';
import 'package:usta_book/core/ui_kit/components/button.dart';
import 'package:usta_book/core/ui_kit/typography.dart';

import '../../core/localization/i18n/strings.g.dart';
import 'components/language_item.dart';

class SelectLanguage extends StatefulWidget {
  const SelectLanguage({super.key});

  static final String tag = '/select-language';

  @override
  State<SelectLanguage> createState() => _SelectLanguageState();
}

class _SelectLanguageState extends State<SelectLanguage> {
  int selectedItem = 0;

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
            Text(
              tr.on_boarding.choose_lang_desc,
              style: Typographies.regularBody,
            ),
            SizedBox(height: 36),
            LanguageItem(
              title: "O'zbekcha",
              selected: selectedItem == 0,
              onTap: () {
                selectedItem = 0;
                setState(() {});
              },
            ),
            SizedBox(height: 16),
            LanguageItem(
              title: "Русский",
              selected: selectedItem == 1,
              onTap: () {
                selectedItem = 1;
                setState(() {});
              },
            ),
            SizedBox(height: 16),
            Spacer(),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: LightAppColors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: LightAppColors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: LightAppColors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 32),
            MainButton.primary(title: tr.buttons.kContinue),
            SizedBox(height: MediaQuery.of(context).viewPadding.bottom),
          ],
        ),
      ),
    );
  }
}
