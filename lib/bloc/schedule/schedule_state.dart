part of 'schedule_cubit.dart';

@immutable
sealed class ScheduleState {}

class TodayAppointmentsLoading extends ScheduleState {}

class TodayAppointmentLoaded extends ScheduleState {
  final List<RecordModel> data;

  TodayAppointmentLoaded({required this.data});
}

class TodayAppointmentLoadError extends ScheduleState {
  final String msg;

  TodayAppointmentLoadError({required this.msg});
}
