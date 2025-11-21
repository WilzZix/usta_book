import 'package:flutter/material.dart';
import 'package:usta_book/core/ui_kit/colors.dart';
import 'package:usta_book/core/ui_kit/components/app_icons.dart';

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({super.key, required this.controller});

  final TextEditingController controller;

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      height: 50,
      child: TextFormField(
        controller: widget.controller,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          fillColor: LightAppColors.body,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide.none, // Hide the default border line
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 16, left: 16),
            child: AppIcons.icSearchLupa,
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 16, right: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppIcons.icVerticalDivider,
                SizedBox(width: 20),
                AppIcons.icSearchBar,
              ],
            ),
          ),
          hintText: 'Mijoz ismi yoki telefon raqam',
        ),
      ),
    );
  }
}
