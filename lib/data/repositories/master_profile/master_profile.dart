import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:usta_book/data/models/master_profile.dart';
import 'package:usta_book/data/models/record_model.dart';
import 'package:usta_book/data/models/service_model.dart';
import 'package:usta_book/domain/repositories/master_profile/i_master_profile.dart';

@LazySingleton(as: IMasterProfile)
class MasterProfileImpl extends IMasterProfile {
  @override
  Future<void> updateMasterProfile(String masterUID, MasterProfile profile) async {
    try {
      final FirebaseFirestore db = FirebaseFirestore.instance;
      final WriteBatch batch = db.batch();

      // 1. Ссылка на документ самого мастера
      final DocumentReference masterRef = db.collection('masters').doc(masterUID);

      // Данные профиля мастера
      final Map<String, dynamic> masterData = profile.toFirestore();
      masterData['updatedAt'] = FieldValue.serverTimestamp();

      // Добавляем в батч операцию создания/обновления мастера
      // set с merge: true создаст документ, если его нет, или обновит существующий
      batch.set(masterRef, masterData, SetOptions(merge: true));

      // 2. Ссылка на НОВУЮ запись в подколлекции 'records'
      // .doc() без параметров генерирует новый ID для записи
      final DocumentReference newRecordRef = masterRef.collection('records').doc();

      // Здесь должны быть данные ЗАПИСИ (например, время визита),
      // но если вы хотите продублировать туда профиль:
      batch.set(newRecordRef, masterData);

      // 3. Выполняем обе операции одним запросом
      await batch.commit();
    } on FirebaseException catch (e) {
      print("Ошибка Firebase: ${e.code}");
      rethrow;
    } catch (e) {
      print("Общая ошибка: $e");
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
      // Return an empty list on failure
      return [];
    }
  }

  @override
  Future<MasterProfile?> getMasterProfile(String masterUID) async {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentSnapshot doc = await db.collection('masters').doc(masterUID).get();
    return MasterProfile.fromFirestore(doc);
  }

  @override
  Future<void> addRecord(String masterUID, RecordModel record) async {
    try {
      final FirebaseFirestore db = FirebaseFirestore.instance;
      // 1. Get the reference to the specific 'records' subcollection
      final CollectionReference recordsCollection = db.collection('masters').doc(masterUID).collection('records');

      // 2. Формируем данные для записи и добавляем метку времени обновления
      final Map<String, dynamic> data = record.toJson();
      data['updatedAt'] = FieldValue.serverTimestamp();

      // 3. Используем set() с merge: true, чтобы обновить только переданные поля,
      // не перезаписывая весь документ.
      await recordsCollection.add(data);
    } on FirebaseException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateRecord(String masterUID, RecordModel record) async {
    try {
      final FirebaseFirestore db = FirebaseFirestore.instance;
      final CollectionReference recordsCollection = db.collection('masters').doc(masterUID).collection('records');

      final Map<String, dynamic> data = record.toJson();
      data['updatedAt'] = FieldValue.serverTimestamp();

      // query orqali record’ni topamiz (unikal maydonlar orqali)
      final snapshot = await recordsCollection
          .where('client_name', isEqualTo: record.clientName)
          .where('date', isEqualTo: record.date)
          .where('time', isEqualTo: record.time)
          .get();

      if (snapshot.docs.isEmpty) {
        throw Exception("Record topilmadi");
      }

      // Topilgan document’larni yangilash
      for (var doc in snapshot.docs) {
        await doc.reference.update(data);
      }
    } on FirebaseException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}
