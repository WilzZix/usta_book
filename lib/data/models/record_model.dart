class RecordModel {
  final String clientName;
  final String date;
  final String price;
  final String serviceType;
  final String clientNumber;

  RecordModel({
    required this.clientName,
    required this.date,
    required this.price,
    required this.serviceType,
    required this.clientNumber,
  });

  factory RecordModel.fromJson(Map<String, dynamic> json) {
    return RecordModel(
      clientName: json['client_name'],
      date: json['date'],
      price: json['price'],
      serviceType: json['service_type'],
      clientNumber: json['client_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'client_name': clientName,
      'date': date,
      'price': price,
      'service_type': serviceType,
      'client_number': clientNumber,
    };
  }
}
