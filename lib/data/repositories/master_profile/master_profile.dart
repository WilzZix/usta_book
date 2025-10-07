import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:usta_book/data/models/master_profile.dart';
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
      await masterDocRef.update(data,);

      print('Профиль мастера $masterUID успешно обновлен.');
    } on FirebaseException catch (e) {
      print('Ошибка Firebase при обновлении профиля: ${e.code}');
      rethrow;
    } catch (e) {
      print('Непредвиденная ошибка: $e');
      rethrow;
    }
  }
}
