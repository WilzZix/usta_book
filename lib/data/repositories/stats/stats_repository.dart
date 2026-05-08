import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:usta_book/data/models/stats_summary.dart';
import 'package:usta_book/domain/repositories/stats/i_stats.dart';

@LazySingleton(as: IStatsRepository)
class StatsRepository implements IStatsRepository {
  @override
  Stream<StatsSummary?> watchSummary(String masterUID) {
    return FirebaseFirestore.instance
        .collection('masters')
        .doc(masterUID)
        .collection('stats')
        .doc('summary')
        .snapshots()
        .map((doc) {
      final data = doc.data();
      if (data == null) return null;
      return StatsSummary.fromMap(data);
    });
  }
}
