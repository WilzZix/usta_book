import '../../../data/models/record_model.dart';

abstract class IClients {
  Future<List<RecordModel>> getClients(String masterUID);

  Future<void> deleteClient(String masterUID, RecordModel record);
}
