import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:usta_book/core/ui_kit/colors.dart';
import 'package:usta_book/core/ui_kit/typography.dart';

enum InputFieldType {
  phone,
  date,
  time,
  text,
  selectableInput,
  email,
  password,
}

class InputField extends StatefulWidget {
  const InputField._({
    super.key,

    required this.fieldTitle,
    required this.fieldType,
    this.inputFormatter,
    this.suffixIcon,
    this.readOnly = false,
    this.hintText,
    required this.controller,
    required this.textInputType,
    this.onTap,
    this.obscureText,
    this.validator,
  });

  InputField.phone({
    Key? key,
    required String fieldTitle,
    List<TextInputFormatter>? inputFormatter,
    String? hintText,
    required TextEditingController controller,
    String? Function(String?)? validator,
  }) : this._(
         validator: validator,
         controller: controller,
         fieldType: InputFieldType.phone,
         textInputType: TextInputType.phone,
         key: key,
         fieldTitle: fieldTitle,
         hintText: '+998 (00) 123 45 67',
         inputFormatter: [phoneMaskFormatter],
       );

  InputField.email({
    Key? key,
    required String fieldTitle,
    List<TextInputFormatter>? inputFormatter,
    String? hintText,
    required TextEditingController controller,
    String? Function(String?)? validator,
  }) : this._(
         validator: validator,
         controller: controller,
         fieldType: InputFieldType.email,
         textInputType: TextInputType.emailAddress,
         key: key,
         fieldTitle: fieldTitle,
         hintText: 'example@email.com',
         inputFormatter: [emailMaskFormatter],
       );

  InputField.password({
    Key? key,
    required String fieldTitle,
    List<TextInputFormatter>? inputFormatter,
    String? hintText,
    required TextEditingController controller,
    String? Function(String?)? validator,
  }) : this._(
         validator: validator,
         controller: controller,
         fieldType: InputFieldType.password,
         textInputType: TextInputType.visiblePassword,
         key: key,
         fieldTitle: fieldTitle,
         hintText: '************',
         inputFormatter: [emailMaskFormatter],
         obscureText: true,
       );

  InputField.date({
    Key? key,
    required String fieldTitle,
    List<TextInputFormatter>? inputFormatter,
    required Widget suffixIcon,
    required TextEditingController controller,
    String? Function(String?)? validator,
  }) : this._(
         validator: validator,
         controller: controller,
         fieldType: InputFieldType.date,
         textInputType: TextInputType.datetime,
         key: key,
         fieldTitle: fieldTitle,
         inputFormatter: [dateMaskFormatter],
         suffixIcon: suffixIcon,
         hintText: '01/01/2000',
       );

  InputField.time({
    Key? key,
    required String fieldTitle,
    List<TextInputFormatter>? inputFormatter,
    required Widget suffixIcon,
    required TextEditingController controller,
    String? Function(String?)? validator,
  }) : this._(
         validator: validator,
         controller: controller,
         fieldType: InputFieldType.time,
         hintText: '13:30',
         key: key,
         fieldTitle: fieldTitle,
         suffixIcon: suffixIcon,
         inputFormatter: [timeMaskFormatter],
         textInputType: TextInputType.datetime,
       );

  const InputField.text({
    Key? key,
    required String fieldTitle,
    String? hintText,
    required TextEditingController controller,
    String? Function(String?)? validator,
  }) : this._(
         validator: validator,
         controller: controller,
         key: key,
         fieldTitle: fieldTitle,
         textInputType: TextInputType.text,
         fieldType: InputFieldType.text,
         hintText: hintText,
       );

  const InputField.selectableInput({
    Key? key,
    required String fieldTitle,
    String? hintText,
    required Widget suffixIcon,
    required TextEditingController controller,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) : this._(
         validator: validator,
         controller: controller,
         key: key,
         fieldTitle: fieldTitle,
         readOnly: true,
         suffixIcon: suffixIcon,
         hintText: hintText,
         textInputType: TextInputType.text,
         fieldType: InputFieldType.text,
         onTap: onTap,
       );
  final String fieldTitle;
  final InputFieldType fieldType;
  final List<TextInputFormatter>? inputFormatter;
  final Widget? suffixIcon;
  final bool? readOnly;
  final String? hintText;
  final TextEditingController controller;
  final TextInputType? textInputType;
  final VoidCallback? onTap;
  final bool? obscureText;
  final String? Function(String?)? validator;

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.fieldTitle,
          style: Typographies.regularBody.copyWith(
            color: LightTextColor.secondary,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: widget.validator,
          controller: widget.controller,
          onTap: widget.onTap,
          readOnly: widget.readOnly ?? false,
          inputFormatters: widget.inputFormatter,
          keyboardType: widget.textInputType,
          obscureText: widget.obscureText ?? false,
          decoration: InputDecoration(
            fillColor: LightAppColors.body,
            suffixIcon: Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 16, right: 16),
              child: widget.suffixIcon,
            ),
            hintText: widget.hintText,
          ),
        ),
      ],
    );
  }
}

var phoneMaskFormatter = MaskTextInputFormatter(
  mask: '+### (##) ###-##-##',
  filter: {"#": RegExp(r'[0-9]')},
  type: MaskAutoCompletionType.lazy, // or .eager
);
final emailMaskFormatter = MaskTextInputFormatter(
  // A very basic example, adjust as needed
  filter: {"#": RegExp(r'[a-zA-Z0-9.\-_]')},
  // Allow common email characters
  type: MaskAutoCompletionType.lazy,
);
var dateMaskFormatter = MaskTextInputFormatter(
  mask: '##/##/####',
  filter: {"#": RegExp(r'[0-9]')},
);
var timeMaskFormatter = MaskTextInputFormatter(
  mask: '##:##',
  filter: {"#": RegExp(r'[0-9]')},
  type: MaskAutoCompletionType.lazy,
);
