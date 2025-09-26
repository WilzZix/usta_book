import 'package:flutter/material.dart';
import 'package:usta_book/core/ui_kit/components/button.dart';
import 'package:usta_book/core/ui_kit/typography.dart';

import '../../core/localization/i18n/strings.g.dart';

class SelectLanguage extends StatefulWidget {
  const SelectLanguage({super.key});

  static final String tag = '/select-language';

  @override
  State<SelectLanguage> createState() => _SelectLanguageState();
}

class _SelectLanguageState extends State<SelectLanguage> {
  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).viewPadding.top + 20),
          Text(tr.on_boarding.choose_language, style: Typographies.boldH1),
          SizedBox(height: 8),
          Text(
            tr.on_boarding.choose_lang_desc,
            style: Typographies.regularBody,
          ),
          SizedBox(height: 36),
          Spacer(),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: MainButton.primary(title: tr.buttons.kContinue),
          ),
        ],
      ),
    );
  }
}
