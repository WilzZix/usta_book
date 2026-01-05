import 'package:flutter/material.dart';

import '../../../core/ui_kit/colors.dart';
import '../../../core/ui_kit/components/app_icons.dart';
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
              Text('10 ta tashrif', style: Typographies.regularBody2.copyWith(color: LightTextColor.secondary)),
            ],
          ),
          Spacer(),
          AppIcons.icMenu,
        ],
      ),
    );
  }
}
