import 'package:usta_book/data/models/record_model.dart';

import '../../../data/models/appointment.dart';

abstract class IAppointment {
  Future<String> addAppointment(String masterUID, Appointment appointment);

  Future<List<RecordModel>> getTodayAppointment(
    DateTime date,
    String? masterUID,
  );

  Future<List<RecordModel>> getRangeAppointments(
    List<DateTime> dates,
    String? masterUID,
  );
}
