part of 'stats_cubit.dart';

@immutable
sealed class StatsState {}

final class StatsInitial extends StatsState {}

final class StatsLoading extends StatsState {}

final class StatsLoaded extends StatsState {
  final StatsSummary summary;
  StatsLoaded(this.summary);
}

final class StatsError extends StatsState {
  final String msg;
  StatsError(this.msg);
}
