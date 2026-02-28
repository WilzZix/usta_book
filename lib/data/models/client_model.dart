class ClientModel {
  final String clientName;
  final String lastVisitDate;
  final String price;
  final String serviceType;
  final String clientNumber;
  final int? visitCount;

  ClientModel({
    required this.clientName,
    required this.lastVisitDate,
    required this.price,
    required this.serviceType,
    required this.clientNumber,

    this.visitCount,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      clientName: json['client_name'],
      lastVisitDate: json['lastVisitDate'],
      price: json['price'],
      serviceType: json['service_type'],
      clientNumber: json['client_number'],
      visitCount: json['visit_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'client_name': clientName,
      'lastVisitDate': lastVisitDate,
      'price': price,
      'service_type': serviceType,
      'client_number': clientNumber,
      'visit_count': visitCount,
    };
  }

  ClientModel copyWith({
    String? clientName,
    String? lastVisitDate,
    String? price,
    String? serviceType,
    String? clientNumber,
    int? visitCount,
  }) {
    return ClientModel(
      clientName: clientName ?? this.clientName,
      price: price ?? this.price,
      lastVisitDate: lastVisitDate ?? this.lastVisitDate,
      serviceType: serviceType ?? this.serviceType,
      clientNumber: clientNumber ?? this.clientNumber,
      visitCount: visitCount ?? this.visitCount,
    );
  }
}
