import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:usta_book/data/models/stats_summary.dart';
import 'package:usta_book/data/sources/local/shared_pref.dart';
import 'package:usta_book/domain/repositories/stats/i_stats.dart';

part 'stats_state.dart';

class StatsCubit extends Cubit<StatsState> {
  final IStatsRepository _repo;
  final ShredPrefService _prefs;
  StreamSubscription<StatsSummary?>? _sub;

  StatsCubit(this._repo, this._prefs) : super(StatsInitial());

  void start() {
    final uid = _prefs.getMasterUID();
    if (uid == null || uid.isEmpty) {
      emit(StatsError('No master UID'));
      return;
    }
    _sub?.cancel();
    emit(StatsLoading());
    _sub = _repo.watchSummary(uid).listen(
      (summary) {
        emit(StatsLoaded(summary ?? StatsSummary.empty()));
      },
      onError: (e) => emit(StatsError(e.toString())),
    );
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
