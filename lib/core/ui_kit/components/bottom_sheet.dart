import 'package:flutter/material.dart';
import 'package:usta_book/core/ui_kit/colors.dart';

import 'app_icons.dart';

class UstaBookBottomSheet extends StatefulWidget {
  const UstaBookBottomSheet({super.key, required this.body, required this.header});

  final Widget body;
  final String header;

  static void show({required BuildContext context, required Widget body, required String header}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: LightAppColors.secondaryBg,
      builder: (context) {
        return UstaBookBottomSheet(body: body, header: header);
      },
    );
  }

  @override
  State<UstaBookBottomSheet> createState() => _UstaBookBottomSheetState();
}

class _UstaBookBottomSheetState extends State<UstaBookBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20),
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(widget.header), AppIcons.icClose]),
            Divider(),
            widget.body,
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}
