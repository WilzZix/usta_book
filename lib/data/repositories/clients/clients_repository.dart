import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:injectable/injectable.dart';
import 'package:usta_book/data/models/record_model.dart';
import 'package:usta_book/domain/repositories/clients/i_clients.dart';

import '../../models/client_model.dart';

@Singleton(as: IClients)
class ClientsRepository implements IClients {
  @override
  Future<List<ClientModel>> getClients(String masterUID) async {
    final snapshot = await FirebaseFirestore.instance.collection('masters').doc(masterUID).collection('clients').get();

    return snapshot.docs.map((doc) => ClientModel.fromJson(doc.data())).toList();
  }

  @override
  Future<void> deleteClient(String masterUID, RecordModel record) async {
    try {
      var query = await FirebaseFirestore.instance
          .collection('masters')
          .doc(masterUID)
          .collection('records')
          .where('client_name', isEqualTo: record.clientName)
          .get();

      for (var doc in query.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Future<void> editClient(String masterUID, RecordModel record) async {
    try {
      var query = await FirebaseFirestore.instance
          .collection('masters')
          .doc(masterUID)
          .collection('records')
          .where('client_name', isEqualTo: record.clientName)
          .get();

      for (var doc in query.docs) {
        await doc.reference.update(record.toJson());
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
