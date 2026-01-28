import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:usta_book/core/ui_kit/colors.dart';
import 'package:usta_book/core/ui_kit/typography.dart';
import 'package:usta_book/data/models/client_model.dart';
import 'package:usta_book/data/models/record_model.dart';

import '../../bloc/master/master_bloc.dart';
import '../../core/localization/i18n/strings.g.dart';
import '../../core/ui_kit/components/app_icons.dart';
import '../../core/ui_kit/components/button.dart';
import '../../core/ui_kit/components/inputs/inputs.dart';
import '../../domain/enums/enums.dart';
import '../add_new_record/components/select_service_type_bottom_sheet.dart';

class AddNewAppointmentPage extends StatefulWidget {
  const AddNewAppointmentPage({super.key, required this.record});

  final ClientModel record;
  static const String tag = '/add-new-appointment';

  @override
  State<AddNewAppointmentPage> createState() => _AddNewAppointmentPageState();
}

class _AddNewAppointmentPageState extends State<AddNewAppointmentPage> {
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController serviceTypeController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    serviceTypeController.text = widget.record.serviceType;
    priceController.text = widget.record.price;
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return Scaffold(
      backgroundColor: AppColors.body,
      appBar: AppBar(title: Text('Qabulga yozish', style: Typographies.regularBody), centerTitle: false),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.white),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text('Parametrlar'),
                  SizedBox(height: 16),
                  InputField.selectableInput(
                    hintText: '01/01/2025',
                    fieldTitle: tr.add_record.date,
                    suffixIcon: AppIcons.icFieldCalendar,
                    controller: dateController,
                    onTap: () async {
                      final result = await showDatePicker(
                        context: context,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2045),
                      );
                      if (result != null) {
                        dateController.text = DateFormat('dd/MM/yyyy').format(result);
                      }
                    },
                    validator: (value) {
                      if (value != null && value.isEmpty) {
                        return tr.add_record.validation_text;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  InputField.selectableInput(
                    onTap: () async {
                      final TimeOfDay? result = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                      if (result != null) {
                        final now = DateTime.now();
                        final dateTime = DateTime(now.year, now.month, now.day, result.hour, result.minute);
                        final formattedTime24Hour = DateFormat('HH:mm').format(dateTime);

                        timeController.text = formattedTime24Hour;
                      }
                    },
                    fieldTitle: tr.add_record.time,
                    hintText: '12:00',
                    suffixIcon: AppIcons.icWatch,
                    controller: timeController,
                    validator: (value) {
                      if (value != null && value.isEmpty) {
                        return tr.add_record.validation_text;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  InputField.selectableInput(
                    onTap: () async {
                      final result = await SelectServiceTypeBottomSheet.show(context: context);
                      if (result != null) {
                        serviceTypeController.text = result;
                      }
                    },
                    fieldTitle: tr.add_record.service_type,
                    hintText: tr.add_record.service_hint,
                    controller: serviceTypeController,
                    suffixIcon: AppIcons.icArrowRight,
                    validator: (value) {
                      if (value != null && value.isEmpty) {
                        return tr.add_record.validation_text;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  InputField.text(
                    fieldTitle: tr.add_record.price,
                    hintText: tr.add_record.price_hint,
                    controller: priceController,
                    validator: (value) {
                      if (value != null && value.isEmpty) {
                        return tr.add_record.validation_text;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  BlocBuilder<MasterBloc, MasterState>(
                    builder: (context, state) {
                      return MainButton.primary(
                        isLoading: state is AddingRecordState,
                        title: tr.add_record.save,
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<MasterBloc>().add(
                              AddRecordEvent(
                                record: RecordModel(
                                  clientName: widget.record.clientName,
                                  date: dateController.text,
                                  price: priceController.text,
                                  serviceType: serviceTypeController.text,
                                  clientNumber: widget.record.clientNumber,
                                  time: timeController.text,
                                  status: ClientStatus.waiting,
                                ),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
