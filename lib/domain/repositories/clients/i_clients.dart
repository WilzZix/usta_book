import '../../../data/models/client_model.dart';
import '../../../data/models/record_model.dart';

abstract class IClients {
  Future<List<ClientModel>> getClients(String masterUID);

  Future<void> deleteClient(String masterUID, RecordModel record);
  Future<void> editClient(String masterUID, RecordModel record);
}
