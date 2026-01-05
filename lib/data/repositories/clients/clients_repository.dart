import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:usta_book/data/models/record_model.dart';
import 'package:usta_book/domain/repositories/clients/i_clients.dart';

@Singleton(as: IClients)
class ClientsRepository implements IClients {
  @override
  Future<List<RecordModel>> getClients(String masterUID) async {
    final snapshot = await FirebaseFirestore.instance.collection('masters').doc(masterUID).collection('records').get();

    return snapshot.docs.map((doc) => RecordModel.fromJson(doc.data())).toList();
  }
}
