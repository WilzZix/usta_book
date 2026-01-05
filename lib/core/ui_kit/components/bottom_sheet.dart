import 'package:flutter/material.dart';

class UstaBookBottomSheet extends StatefulWidget {
  const UstaBookBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return UstaBookBottomSheet();
      },
    );
  }

  @override
  State<UstaBookBottomSheet> createState() => _UstaBookBottomSheetState();
}

class _UstaBookBottomSheetState extends State<UstaBookBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
