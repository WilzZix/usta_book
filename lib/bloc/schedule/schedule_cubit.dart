import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:usta_book/data/models/record_model.dart';

import '../../data/sources/local/shared_pref.dart';
import '../../domain/repositories/appointment/i_appointment.dart';

part 'schedule_state.dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  ScheduleCubit(this.appointment, this.shredPrefService)
    : super(TodayAppointmentsLoading());
  final IAppointment appointment;
  final ShredPrefService shredPrefService;

  Future<void> getTodayAppointments({required DateTime date}) async {
    emit(TodayAppointmentsLoading());
    try {
      final data = await appointment.getTodayAppointment(
        date,
        shredPrefService.getMasterUID(),
      );
      emit(TodayAppointmentLoaded(data: data.reversed.toList()));
    } catch (e) {
      emit(TodayAppointmentLoadError(msg: e.toString()));
    }
  }
}
