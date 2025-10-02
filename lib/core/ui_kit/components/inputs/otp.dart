import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpInput extends StatefulWidget {
  const OtpInput({super.key});

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  TextEditingController controller1 = TextEditingController();
  TextEditingController controller2 = TextEditingController();
  TextEditingController controller3 = TextEditingController();
  TextEditingController controller4 = TextEditingController();
  FocusNode focusNode1 = FocusNode();
  FocusNode focusNode2 = FocusNode();
  FocusNode focusNode3 = FocusNode();
  FocusNode focusNode4 = FocusNode();
  GlobalKey key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: key,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: SizedBox(
                height: 76,
                width: 76,
                child: TextFormField(
                  textAlign: TextAlign.center,
                  focusNode: focusNode1,
                  inputFormatters: [LengthLimitingTextInputFormatter(1)],
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (value) {
                    FocusScope.of(context).requestFocus(focusNode2);
                  },
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      FocusScope.of(context).requestFocus(focusNode2);
                    }
                  },
                  controller: controller1,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: SizedBox(
                height: 76,
                width: 76,
                child: TextFormField(
                  textAlign: TextAlign.center,
                  focusNode: focusNode2,
                  keyboardType: TextInputType.number,
                  inputFormatters: [LengthLimitingTextInputFormatter(1)],
                  controller: controller2,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (value) {
                    FocusScope.of(context).requestFocus(focusNode3);
                  },
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      FocusScope.of(context).requestFocus(focusNode3);
                    }
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: SizedBox(
                height: 76,
                width: 76,
                child: TextFormField(
                  textAlign: TextAlign.center,
                  focusNode: focusNode3,
                  keyboardType: TextInputType.number,
                  inputFormatters: [LengthLimitingTextInputFormatter(1)],
                  controller: controller3,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (value) {
                    FocusScope.of(context).requestFocus(focusNode4);
                  },
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      FocusScope.of(context).requestFocus(focusNode4);
                    }
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: SizedBox(
                height: 76,
                width: 76,
                child: TextFormField(
                  textAlign: TextAlign.center,
                  focusNode: focusNode4,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      FocusScope.of(context).unfocus();
                    }
                  },
                  inputFormatters: [LengthLimitingTextInputFormatter(1)],
                  keyboardType: TextInputType.number,
                  controller: controller4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
