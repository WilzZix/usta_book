import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:usta_book/bloc/clients/clients_bloc.dart';
import 'package:usta_book/core/ui_kit/components/button.dart';

import '../../../core/localization/i18n/strings.g.dart';
import '../../../core/ui_kit/app_theme_extension.dart';
import '../../../core/ui_kit/colors.dart';
import '../../../core/ui_kit/components/app_icons.dart';
import '../../../core/ui_kit/components/bottom_sheet.dart';
import '../../../core/ui_kit/typography.dart';
import '../../../data/models/client_model.dart';
import '../../../data/models/record_model.dart';
import '../../../shared/mixins/phone_call_mixin.dart';
import '../add_new_appointment_page.dart';

class ClientItem extends StatefulWidget {
  const ClientItem({super.key, required this.data});

  final ClientModel data;

  @override
  State<ClientItem> createState() => _ClientItemState();
}

class _ClientItemState extends State<ClientItem> with PhoneCallMixin {
  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final custom = Theme.of(context).extension<AppThemeExtension>()!;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: custom.body,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: custom.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppIcons.icPerson,
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.data.clientName, style: Typographies.regularBody.copyWith(color: custom.primary)),
              SizedBox(height: 8),
              Text(widget.data.clientNumber, style: Typographies.regularBody2.copyWith(color: TextColor.secondary)),
              SizedBox(height: 8),
              Text(
                tr.clients.numberOfVisits(count: widget.data.visitCount ?? 0),
                style: Typographies.regularBody2.copyWith(color: TextColor.secondary),
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
                              style: Typographies.regularBody.copyWith(color: TextColor.primary),
                            ),
                            SizedBox(height: 8),
                            Text(
                              widget.data.clientNumber,
                              style: Typographies.regularBody2.copyWith(color: TextColor.secondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    BottomSheetItem(
                      title: 'Tashriflar soni',
                      description: '${widget.data.visitCount}',
                      style: Typographies.regularBody2.copyWith(color: TextColor.secondary),
                    ),
                    SizedBox(height: 12),
                    BottomSheetItem(
                      title: "So'ngi tashrifi",
                      description: widget.data.lastVisitDate,
                      style: Typographies.regularBody2.copyWith(color: TextColor.secondary),
                    ),
                    SizedBox(height: 12),
                    BottomSheetItem(
                      title: "Umumiy hisob",
                      description: widget.data.price,
                      style: Typographies.regularBody2.copyWith(color: AppColors.primary),
                    ),
                    SizedBox(height: 20),
                    MainButton.primary(
                      onTap: () {
                        context.push(AddNewAppointmentPage.tag, extra: widget.data);
                      },
                      title: 'Qabulga yozish',
                      icon: Icon(Icons.add, color: Colors.white),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ClientInfoItem(
                          title: "Bog'lanish",
                          icon: AppIcons.icPhone,
                          onTap: () async => makePhoneCall(widget.data.clientNumber),
                        ),
                        ClientInfoItem(title: "Tarix", icon: AppIcons.icPhone, onTap: () {}),
                        ClientInfoItem(title: "O'zgartirish", icon: AppIcons.icPhone, onTap: () {}),
                      ],
                    ),
                    SizedBox(height: 10),
                    MainButton.logout(
                      title: "Mijozni o'chirish",
                      icon: Icon(Icons.delete, color: StateColor.error),
                      onTap: () {
                        // context.read<ClientsBloc>().add(DeleterClientEvent(record: widget.data.lastVisitDate)
                      },
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
  const ClientInfoItem({super.key, required this.title, required this.icon, required this.onTap});

  final String title;
  final Widget icon;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    final custom = Theme.of(context).extension<AppThemeExtension>()!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: custom.body),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            icon,
            SizedBox(width: 8),
            Text(title, style: Typographies.regularBody2.copyWith(color: TextColor.secondary)),
          ],
        ),
      ),
    );
  }
}
