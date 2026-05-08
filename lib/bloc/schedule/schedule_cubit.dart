import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:usta_book/data/models/record_model.dart';

import '../../data/sources/local/shared_pref.dart';
import '../../domain/repositories/appointment/i_appointment.dart';

part 'schedule_state.dart';

enum ScheduleMode { day, week }

class ScheduleCubit extends Cubit<ScheduleState> {
  ScheduleCubit(this.appointment, this.shredPrefService)
    : super(TodayAppointmentsLoading());
  final IAppointment appointment;
  final ShredPrefService shredPrefService;

  ScheduleMode _mode = ScheduleMode.day;
  ScheduleMode get mode => _mode;

  Future<void> getTodayAppointments({required DateTime date}) async {
    return loadDay(date);
  }

  Future<void> loadDay(DateTime date) async {
    _mode = ScheduleMode.day;
    emit(TodayAppointmentsLoading());
    try {
      final data = await appointment.getTodayAppointment(
        date,
        shredPrefService.getMasterUID(),
      );
      emit(TodayAppointmentLoaded(
        data: _sortByTime(data),
        selectedDate: date,
        mode: ScheduleMode.day,
      ));
    } catch (e) {
      emit(TodayAppointmentLoadError(msg: e.toString()));
    }
  }

  Future<void> loadWeek(DateTime anyDateInWeek) async {
    _mode = ScheduleMode.week;
    emit(TodayAppointmentsLoading());
    try {
      final monday = _startOfWeek(anyDateInWeek);
      final dates = List<DateTime>.generate(
        7,
        (i) => DateTime(monday.year, monday.month, monday.day + i),
      );
      final data = await appointment.getRangeAppointments(
        dates,
        shredPrefService.getMasterUID(),
      );
      emit(TodayAppointmentLoaded(
        data: _sortByTime(data),
        selectedDate: anyDateInWeek,
        mode: ScheduleMode.week,
      ));
    } catch (e) {
      emit(TodayAppointmentLoadError(msg: e.toString()));
    }
  }

  static DateTime _startOfWeek(DateTime d) {
    final daysFromMonday = (d.weekday - 1).clamp(0, 6);
    return DateTime(d.year, d.month, d.day - daysFromMonday);
  }

  static List<RecordModel> _sortByTime(List<RecordModel> data) {
    final sorted = [...data]..sort((a, b) {
      final atA = _parseAt(a.date, a.time);
      final atB = _parseAt(b.date, b.time);
      if (atA == null && atB == null) return 0;
      if (atA == null) return 1;
      if (atB == null) return -1;
      return atA.compareTo(atB);
    });
    return sorted;
  }

  static DateTime? _parseAt(String date, String time) {
    final d = date.split('/');
    final t = time.split(':');
    if (d.length != 3 || t.length != 2) return null;
    final yy = int.tryParse(d[2]);
    final mm = int.tryParse(d[1]);
    final dd = int.tryParse(d[0]);
    final h = int.tryParse(t[0]);
    final mi = int.tryParse(t[1]);
    if ([yy, mm, dd, h, mi].any((v) => v == null)) return null;
    return DateTime(yy!, mm!, dd!, h!, mi!);
  }
}
