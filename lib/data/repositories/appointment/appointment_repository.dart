import 'package:usta_book/domain/repositories/appointment/i_appointment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/appointment.dart';

class AppointmentRepo extends IAppointment {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Добавляет новую запись (appointment) для мастера.
  /// Возвращает ID созданного документа.
  @override
  Future<String> addAppointment(
    String masterUID,
    Appointment appointment,
  ) async {
    try {
      // 1. Создаем ссылку на коллекцию 'appointments' внутри документа мастера
      final CollectionReference appointmentsRef = _db
          .collection('masters')
          .doc(masterUID)
          .collection('appointments');

      // 2. Формируем данные для записи, используя метод toFirestore()
      // При этом 'createdAt' должен быть FieldValue.serverTimestamp() для первой записи
      final Map<String, dynamic> data = appointment.toFirestore();
      data['createdAt'] = FieldValue.serverTimestamp();

      // 3. Записываем данные в Firestore и получаем ссылку на новый документ
      final DocumentReference docRef = await appointmentsRef.add(data);

      return docRef.id;
    } on FirebaseException catch (e) {
      rethrow; // Перебрасываем ошибку для обработки в UI
    } catch (e) {
      rethrow;
    }
  }
}
