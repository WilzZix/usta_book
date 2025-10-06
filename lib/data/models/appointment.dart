import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  final String? id;
  final String clientId;
  final String clientName;
  final String clientPhone;
  final DateTime dateTime;
  final String service;
  final double? price;
  final String status;
  final Timestamp createdAt;

  Appointment({
    this.id,
    required this.clientId,
    required this.clientName,
    required this.clientPhone,
    required this.dateTime,
    required this.service,
    this.price,
    this.status = 'scheduled',
    required this.createdAt,
  });

  // Преобразование объекта Dart в Map для записи в Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'clientId': clientId,
      'clientName': clientName,
      'clientPhone': clientPhone,
      'dateTime': Timestamp.fromDate(dateTime),
      // Преобразуем DateTime в Timestamp
      'service': service,
      'price': price,
      'status': status,
      'createdAt': createdAt,
      // Используем FieldValue.serverTimestamp() при создании
    };
  }
}
