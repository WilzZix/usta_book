import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:usta_book/bloc/master/master_bloc.dart';
import 'package:usta_book/core/ui_kit/components/button.dart';
import 'package:usta_book/core/ui_kit/components/inputs/inputs.dart';
import 'package:usta_book/core/ui_kit/typography.dart';
import 'package:usta_book/data/models/record_model.dart';

import '../../core/ui_kit/components/app_icons.dart';

class AddNewRecordPage extends StatefulWidget {
  const AddNewRecordPage({super.key});

  static final String tag = '/add-new-record';

  @override
  State<AddNewRecordPage> createState() => _AddNewRecordPageState();
}

class _AddNewRecordPageState extends State<AddNewRecordPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController serviceTypeController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top + 20),
                Text("Yangi mijoz qoshish", style: Typographies.boldH1),
                SizedBox(height: 24),
                InputField.text(
                  fieldTitle: 'Mijoz ismi',
                  controller: nameController,
                  hintText: 'Ism Familiya',
                ),
                SizedBox(height: 16),
                InputField.phone(
                  fieldTitle: 'Mijoz raqami',
                  controller: phoneController,
                ),
                InputField.date(
                  fieldTitle: 'Sana',
                  suffixIcon: AppIcons.icFieldCalendar,
                  controller: dateController,
                ),
                SizedBox(height: 16),
                InputField.time(
                  fieldTitle: 'Vaqt',
                  suffixIcon: AppIcons.icWatch,
                  controller: timeController,
                ),
                SizedBox(height: 16),
                InputField.selectableInput(
                  fieldTitle: 'Xizmat turi',
                  controller: serviceTypeController,
                  suffixIcon: AppIcons.icArrowRight,
                ),
                SizedBox(height: 16),
                InputField.text(
                  fieldTitle: 'Narx',
                  controller: priceController,
                ),
                SizedBox(height: 16),
                MainButton.primary(
                  title: 'Saqlash',
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      context.read<MasterBloc>().add(
                        AddRecordEvent(
                          record: RecordModel(
                            clientName: nameController.text,
                            date: dateController.text,
                            price: priceController.text,
                            serviceType: serviceTypeController.text,
                            clientNumber: phoneController.text,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
