part of 'schedule_cubit.dart';

@immutable
sealed class ScheduleState {}

class TodayAppointmentsLoading extends ScheduleState {}

class TodayAppointmentLoaded extends ScheduleState {
  final List<RecordModel> data;
  final DateTime selectedDate;
  final ScheduleMode mode;

  TodayAppointmentLoaded({
    required this.data,
    required this.selectedDate,
    required this.mode,
  });

  bool get isPast {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    return selected.isBefore(today);
  }
}

class TodayAppointmentLoadError extends ScheduleState {
  final String msg;

  TodayAppointmentLoadError({required this.msg});
}
