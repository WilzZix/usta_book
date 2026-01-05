import '../../domain/enums/enums.dart';
import '../../domain/extension/extensions.dart';

class RecordModel {
  final String clientName;
  final String date;
  final String price;
  final String serviceType;
  final String clientNumber;
  final String time;
  final ClientStatus? status;
  final int? visitCount;

  RecordModel({
    required this.clientName,
    required this.date,
    required this.price,
    required this.serviceType,
    required this.clientNumber,
    required this.time,
    this.visitCount,
    this.status,
  });

  factory RecordModel.fromJson(Map<String, dynamic> json) {
    return RecordModel(
      clientName: json['client_name'],
      date: json['date'],
      price: json['price'],
      serviceType: json['service_type'],
      clientNumber: json['client_number'],
      time: json['time'],
      status: ClientStatusX.fromString(json['status']),
      visitCount: json['visit_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'client_name': clientName,
      'date': date,
      'price': price,
      'service_type': serviceType,
      'client_number': clientNumber,
      'time': time,
      'status': status!.name,
      'visit_count': visitCount,
    };
  }

  RecordModel copyWith({
    String? clientName,
    String? date,
    String? price,
    String? serviceType,
    String? clientNumber,
    String? time,
    ClientStatus? status,
    int? visitCount,
  }) {
    return RecordModel(
      clientName: clientName ?? this.clientName,
      date: date ?? this.date,
      price: price ?? this.price,
      serviceType: serviceType ?? this.serviceType,
      clientNumber: clientNumber ?? this.clientNumber,
      time: time ?? this.time,
      status: status ?? this.status,
      visitCount: visitCount ?? this.visitCount,
    );
  }
}
