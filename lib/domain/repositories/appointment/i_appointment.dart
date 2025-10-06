import '../../../data/models/appointment.dart';

abstract class IAppointment {
  Future<String> addAppointment(String masterUID, Appointment appointment);
}
