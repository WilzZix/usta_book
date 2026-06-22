import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:usta_book/data/models/record_model.dart';
import 'package:usta_book/domain/enums/enums.dart';

import '../../data/sources/local/shared_pref.dart';
import '../../domain/repositories/appointment/i_appointment.dart';

part 'statistics_state.dart';

class StatisticsCubit extends Cubit<StatisticsState> {
  StatisticsCubit(this._appointment, this._prefs) : super(StatisticsLoading());

  final IAppointment _appointment;
  final ShredPrefService _prefs;

  Future<void> loadStats(StatsPeriod period) async {
    emit(StatisticsLoading());
    try {
      final masterUID = _prefs.getMasterUID();
      final all = await _appointment.getAllRecords(masterUID);
      final filtered = _filter(all, period);
      emit(StatisticsLoaded(records: filtered, period: period));
    } catch (e) {
      emit(StatisticsError(msg: e.toString()));
    }
  }

  List<RecordModel> _filter(List<RecordModel> records, StatsPeriod period) {
    final now = DateTime.now();
    return records.where((r) {
      final date = StatisticsLoaded._parseDate(r.date);
      if (date == null) return false;
      switch (period) {
        case StatsPeriod.today:
          return date.year == now.year &&
              date.month == now.month &&
              date.day == now.day;
        case StatsPeriod.week:
          final monday = DateTime(now.year, now.month, now.day)
              .subtract(Duration(days: now.weekday - 1));
          final sunday = monday.add(const Duration(days: 6));
          return !date.isBefore(monday) && !date.isAfter(sunday);
        case StatsPeriod.month:
          return date.year == now.year && date.month == now.month;
      }
    }).toList();
  }
}
