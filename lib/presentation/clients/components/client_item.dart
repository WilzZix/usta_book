import 'package:flutter/material.dart';
import 'package:usta_book/core/ui_kit/components/button.dart';

import '../../../core/localization/i18n/strings.g.dart';
import '../../../core/ui_kit/colors.dart';
import '../../../core/ui_kit/components/app_icons.dart';
import '../../../core/ui_kit/components/bottom_sheet.dart';
import '../../../core/ui_kit/typography.dart';
import '../../../data/models/record_model.dart';

class ClientItem extends StatefulWidget {
  const ClientItem({super.key, required this.data});

  final RecordModel data;

  @override
  State<ClientItem> createState() => _ClientItemState();
}

class _ClientItemState extends State<ClientItem> {
  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: LightAppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppIcons.icPerson,
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.data.clientName, style: Typographies.regularBody.copyWith(color: LightTextColor.primary)),
              SizedBox(height: 8),
              Text(
                widget.data.clientNumber,
                style: Typographies.regularBody2.copyWith(color: LightTextColor.secondary),
              ),
              SizedBox(height: 8),
              Text(
                tr.clients.numberOfVisits(count: widget.data.visitCount ?? 0),
                style: Typographies.regularBody2.copyWith(color: LightTextColor.secondary),
              ),
            ],
          ),
          Spacer(),
          GestureDetector(
            onTap: () {
              UstaBookBottomSheet.show(
                context: context,
                body: Column(
                  children: [
                    Row(
                      children: [
                        AppIcons.icPerson,
                        SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.data.clientName,
                              style: Typographies.regularBody.copyWith(color: LightTextColor.primary),
                            ),
                            SizedBox(height: 8),
                            Text(
                              widget.data.clientNumber,
                              style: Typographies.regularBody2.copyWith(color: LightTextColor.secondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    BottomSheetItem(
                      title: 'Tashriflar soni',
                      description: '${widget.data.visitCount}',
                      style: Typographies.regularBody2.copyWith(color: LightTextColor.secondary),
                    ),
                    SizedBox(height: 12),
                    BottomSheetItem(
                      title: "So'ngi tashrifi",
                      description: widget.data.date,
                      style: Typographies.regularBody2.copyWith(color: LightTextColor.secondary),
                    ),
                    SizedBox(height: 12),
                    BottomSheetItem(
                      title: "Umumiy hisob",
                      description: widget.data.price,
                      style: Typographies.regularBody2.copyWith(color: LightAppColors.primary),
                    ),
                    SizedBox(height: 20),
                    MainButton.primary(
                      title: 'Qabulga yozish',
                      icon: Icon(Icons.add, color: Colors.white),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ClientInfoItem(title: "Bog'lanish", icon: AppIcons.icPhone),
                        ClientInfoItem(title: "Tarix", icon: AppIcons.icPhone),
                        ClientInfoItem(title: "O'zgartirish", icon: AppIcons.icPhone),
                      ],
                    ),
                    SizedBox(height: 10),
                    MainButton.logout(
                      title: "Mijozni o'chirish",
                      icon: Icon(Icons.delete, color: StateColor.error),
                    ),
                  ],
                ),
                header: "Mijoz ma'lumotlari",
              );
            },
            child: AppIcons.icMenu,
          ),
        ],
      ),
    );
  }
}

class BottomSheetItem extends StatelessWidget {
  const BottomSheetItem({super.key, required this.title, required this.description, this.style});

  final String title;
  final String description;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(title, style: Typographies.regularBody),
        Text(description, style: style ?? Typographies.regularBody2),
      ],
    );
  }
}

class ClientInfoItem extends StatelessWidget {
  const ClientInfoItem({super.key, required this.title, required this.icon});

  final String title;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: LightAppColors.body),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          icon,
          SizedBox(width: 8),
          Text(title, style: Typographies.regularBody2.copyWith(color: LightTextColor.secondary)),
        ],
      ),
    );
  }
}
