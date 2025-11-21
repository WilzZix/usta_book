import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:usta_book/bloc/master/master_bloc.dart';
import 'package:usta_book/core/localization/i18n/strings.g.dart';
import 'package:usta_book/core/ui_kit/colors.dart';
import 'package:usta_book/core/ui_kit/components/button.dart';
import 'package:usta_book/core/ui_kit/components/inputs/inputs.dart';
import 'package:usta_book/core/ui_kit/typography.dart';
import 'package:usta_book/data/models/record_model.dart';
import 'package:usta_book/domain/enums/enums.dart';

import '../../core/ui_kit/components/app_icons.dart';
import 'components/select_service_type_bottom_sheet.dart';

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
    final tr = Translations.of(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: BlocListener<MasterBloc, MasterState>(
            listener: (context, state) {
              if (state is RecordAddedState) {
                showGeneralDialog(
                  context: context,
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Material(
                          type: MaterialType.transparency,
                          child: Container(
                            margin: EdgeInsets.only(
                              top: MediaQuery.of(context).padding.top,
                            ),
                            padding: const EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: StateColor.success,
                                width: 2,
                              ),
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.0),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10.0,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  tr.add_record.record_added_success_txt,
                                  style: Typographies.semiBoldH2,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  tr.add_record.recorded_name(
                                    name: nameController.text,
                                  ),
                                  style: Typographies.regularBody2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  barrierDismissible: true,
                  barrierLabel: MaterialLocalizations.of(
                    context,
                  ).modalBarrierDismissLabel,
                  transitionDuration: const Duration(milliseconds: 200),
                );
              }
            },
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top),
                  Text(
                    tr.add_record.add_new_record,
                    style: Typographies.boldH1,
                  ),
                  SizedBox(height: 24),
                  InputField.text(
                    fieldTitle: tr.add_record.name,
                    controller: nameController,
                    hintText: tr.add_record.name_hint,
                    validator: (value) {
                      if (value != null && value.isEmpty) {
                        return tr.add_record.validation_text;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  InputField.phone(
                    fieldTitle: tr.add_record.number,
                    controller: phoneController,
                    validator: (value) {
                      if (value != null && value.isEmpty) {
                        return tr.add_record.validation_text;
                      }
                      return null;
                    },
                  ),
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
                        lastDate: DateTime(2026),
                      );
                      if (result != null) {
                        dateController.text = DateFormat(
                          'dd/MM/yyyy',
                        ).format(result);
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
                      final TimeOfDay? result = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (result != null) {
                        final now = DateTime.now();
                        final dateTime = DateTime(
                          now.year,
                          now.month,
                          now.day,
                          result.hour,
                          result.minute,
                        );
                        final formattedTime24Hour = DateFormat(
                          'HH:mm',
                        ).format(dateTime);

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
                      final result = await SelectServiceTypeBottomSheet.show(
                        context: context,
                      );
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
                  MainButton.primary(
                    title: tr.add_record.save,
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
                              time: timeController.text,
                              status: ClientStatus.waiting,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
