import 'package:flutter/material.dart';
import 'package:usta_book/core/ui_kit/colors.dart';
import 'package:usta_book/core/ui_kit/typography.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const String tag = '/home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool dayIsSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jadval', style: Typographies.boldH1),
        centerTitle: false,
        actions: [
          Container(
            padding: EdgeInsets.all(2),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      dayIsSelected = true;
                    });
                  },
                  child: Container(
                    height: 32,
                    width: 88,
                    decoration: BoxDecoration(
                      color: dayIsSelected ? LightAppColors.primary : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        'Kun',
                        style: Typographies.regularBody2.copyWith(
                          color: dayIsSelected
                              ? LightAppColors.secondaryBg
                              : LightTextColor.secondary,
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      dayIsSelected = false;
                    });
                  },
                  child: Container(
                    height: 32,
                    width: 88,
                    decoration: BoxDecoration(
                      color: dayIsSelected
                          ? LightAppColors.secondaryBg
                          : LightAppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        'Hafta',
                        style: Typographies.regularBody2.copyWith(
                          color: dayIsSelected
                              ? LightTextColor.secondary
                              : LightAppColors.secondaryBg,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Center(child: Text('Home')),
    );
  }
}
