import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/sources/local/shared_pref.dart';
import '../../domain/repositories/appointment/i_appointment.dart';

@injectable
class AppointmentBadgesCubit extends Cubit<Set<DateTime>> {
  final IAppointment appointment;
  final ShredPrefService prefs;

  AppointmentBadgesCubit(this.appointment, this.prefs) : super(const {});

  Future<void> refresh() async {
    final uid = prefs.getMasterUID();
    if (uid == null || uid.isEmpty) return;
    final today = DateTime.now();
    final dates = List<DateTime>.generate(
      30,
      (i) => DateTime(today.year, today.month, today.day + i),
    );
    try {
      final records = await appointment.getRangeAppointments(dates, uid);
      final set = <DateTime>{};
      for (final r in records) {
        final d = _parseDate(r.date);
        if (d != null) set.add(DateTime(d.year, d.month, d.day));
      }
      emit(set);
    } catch (_) {
      // keep previous state on error
    }
  }

  static DateTime? _parseDate(String s) {
    final p = s.split('/');
    if (p.length != 3) return null;
    final dd = int.tryParse(p[0]);
    final mm = int.tryParse(p[1]);
    final yy = int.tryParse(p[2]);
    if (dd == null || mm == null || yy == null) return null;
    return DateTime(yy, mm, dd);
  }
}
