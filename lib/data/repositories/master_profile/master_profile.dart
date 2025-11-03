import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:usta_book/data/models/master_profile.dart';
import 'package:usta_book/data/models/record_model.dart';
import 'package:usta_book/data/models/service_model.dart';
import 'package:usta_book/domain/repositories/master_profile/i_master_profile.dart';

@LazySingleton(as: IMasterProfile)
class MasterProfileImpl extends IMasterProfile {
  @override
  Future<void> updateMasterProfile(
    String masterUID,
    MasterProfile profile,
  ) async {
    try {
      final FirebaseFirestore _db = FirebaseFirestore.instance;
      // 1. Создаем ссылку на документ в коллекции 'masters'
      final DocumentReference masterDocRef = _db
          .collection('masters')
          .doc(masterUID);

      // 2. Формируем данные для записи и добавляем метку времени обновления
      final Map<String, dynamic> data = profile.toFirestore();
      data['updatedAt'] = FieldValue.serverTimestamp();

      // 3. Используем set() с merge: true, чтобы обновить только переданные поля,
      // не перезаписывая весь документ.
      await masterDocRef.update(data);

      print('Профиль мастера $masterUID успешно обновлен.');
    } on FirebaseException catch (e) {
      print('Ошибка Firebase при обновлении профиля: ${e.code}');
      rethrow;
    } catch (e) {
      print('Непредвиденная ошибка: $e');
      rethrow;
    }
  }

  @override
  Future<List<ServiceModel>> getAvailableServices() async {
    try {
      final FirebaseFirestore db = FirebaseFirestore.instance;
      // 1. Execute the Query
      final QuerySnapshot snapshot = await db.collection('services').get();

      // 2. Map the Documents to the Model Class
      final List<ServiceModel> services = snapshot.docs.map((doc) {
        final String documentId = doc.id;
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Use the existing factory method
        return ServiceModel.fromFirestore(data, documentId);
      }).toList();

      return services;
    } catch (e) {
      print("Error fetching services list: $e");
      // Return an empty list on failure
      return [];
    }
  }

  @override
  Future<MasterProfile?> getMasterProfile(String masterUID) async {
    final FirebaseFirestore _db = FirebaseFirestore.instance;
    DocumentSnapshot doc = await _db.collection('masters').doc(masterUID).get();
    return MasterProfile.fromFirestore(doc);
  }

  @override
  Future<void> addRecord(String masterUID, RecordModel record) async {
    try {
      final FirebaseFirestore _db = FirebaseFirestore.instance;
      // 1. Создаем ссылку на документ в коллекции 'records'
      final DocumentReference masterDocRef = _db
          .collection('masters')
          .doc(masterUID)
          .collection('records')
          .doc('ptcgfVPKv9P3Px5htuXX');

      // 2. Формируем данные для записи и добавляем метку времени обновления
      final Map<String, dynamic> data = record.toJson();
      data['updatedAt'] = FieldValue.serverTimestamp();

      // 3. Используем set() с merge: true, чтобы обновить только переданные поля,
      // не перезаписывая весь документ.
      await masterDocRef.update(data);
    } on FirebaseException catch (e) {
      print('Ошибка Firebase при обновлении профиля: ${e.code}');
      rethrow;
    } catch (e) {
      print('Непредвиденная ошибка: $e');
      rethrow;
    }
  }
}
