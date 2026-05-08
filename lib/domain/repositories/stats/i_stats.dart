import 'package:usta_book/data/models/stats_summary.dart';

abstract class IStatsRepository {
  Stream<StatsSummary?> watchSummary(String masterUID);
}
