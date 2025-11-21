import 'package:injectable/injectable.dart';
import 'package:usta_book/data/models/record_model.dart';
import 'package:usta_book/domain/repositories/appointment/i_appointment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../domain/enums/enums.dart';
import '../../models/appointment.dart';

@Singleton(as: IAppointment)
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
    } on FirebaseException {
      rethrow; // Перебрасываем ошибку для обработки в UI
    } catch (e) {
      rethrow;
    }
  }

  String formatToday(DateTime date) {
    final now = date;
    final day = now.day.toString().padLeft(2, '0');
    final month = now.month.toString().padLeft(2, '0');
    final year = now.year;
    return "$day/$month/$year"; // <-- ТОЧНО ТАКОЙ ЖЕ ФОРМАТ
  }

  @override
  Future<List<RecordModel>> getTodayAppointment(
    DateTime date,
    String? masterUID,
  ) async {
    final String today = formatToday(date);

    final snapshot = await FirebaseFirestore.instance
        .collection('masters')
        .doc(masterUID)
        .collection('records')
        .where('date', isEqualTo: today)
        .where(
          'status',
          whereIn: [ClientStatus.waiting.name, ClientStatus.inProgress.name],
        )
        .get();

    return snapshot.docs
        .map((doc) => RecordModel.fromJson(doc.data()))
        .toList();
  }
}
